#include <QApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QPixmapCache>
#include <QStandardPaths>
#include <QString>
#include <QStringList>
#include <QStyle>
#include <QTextCodec>
#include <QThread>
#include <QtDebug>
#include <QtGlobal>
#include <cstdio>
#include <memory>
#include <stdexcept>

#include "config.h"
#include "controllers/controllermanager.h"
#include "coreservices.h"
#include "errordialoghandler.h"
#include "mixxxapplication.h"
#ifdef MIXXX_USE_QML
#include "mixer/playermanager.h"
#include "qml/qmlapplication.h"
#include "waveform/guitick.h"
#include "waveform/visualsmanager.h"
#include "waveform/waveformwidgetfactory.h"
#endif
#include "mixxxmainwindow.h"
#if defined(__WINDOWS__)
#include "nativeeventhandlerwin.h"
#endif
#include "skin/skin.h"
#include "skin/skinloader.h"
#include "sources/soundsourceproxy.h"
#include "util/cmdlineargs.h"
#include "util/console.h"
#include "util/logging.h"
#include "util/sandbox.h"
#include "util/versionstore.h"

namespace {

constexpr int kFatalErrorOnStartupExitCode = 1;
constexpr int kParseCmdlineArgsErrorExitCode = 2;

constexpr char kScaleFactorEnvVar[] = "QT_SCALE_FACTOR";
const QString kConfigGroup = QStringLiteral("[Config]");
const QString kScaleFactorKey = QStringLiteral("ScaleFactor");
const QString kNotifyMaxDbgTimeKey = QStringLiteral("notify_max_dbg_time");

constexpr int kPixmapCacheLimitAt100PercentZoom = 32 * 1024;

#if defined(Q_OS_ANDROID)
const QStringList kSkipAndroidQmlDirs = {
        QStringLiteral("Mixxx"),
};

// Materialize the Android QML shell and packaged QML skins into the application's
// private storage. This deliberately avoids the shared-storage path used by the
// old implementation, which requires MANAGE_EXTERNAL_STORAGE on Android 11+.
// QML skins rely on ordinary relative file URLs (../skins/...), so a real
// filesystem tree is the most deterministic way to preserve those semantics.
bool copyAndroidAssetDir(const QString& src, const QString& dst) {
    if (!QDir().mkpath(dst)) {
        qCritical() << "Failed to create Android QML resource directory:" << dst;
        return false;
    }

    QDir srcDir(src);
    if (!srcDir.exists()) {
        qCritical() << "Android asset directory does not exist:" << src;
        return false;
    }

    const QStringList files = srcDir.entryList(QDir::Files);
    for (const QString& file : files) {
        QFile srcFile(srcDir.absoluteFilePath(file));
        if (!srcFile.open(QIODevice::ReadOnly)) {
            qCritical() << "Failed to read Android QML asset:" << srcFile.fileName();
            return false;
        }
        const QByteArray data = srcFile.readAll();
        if (srcFile.error() != QFile::NoError) {
            qCritical() << "Failed while reading Android QML asset:" << srcFile.fileName();
            return false;
        }

        const QString dstFilePath = QDir(dst).filePath(file);
        QFile dstFile(dstFilePath);
        if (!dstFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qCritical() << "Failed to write Android QML asset:" << dstFilePath;
            return false;
        }
        if (dstFile.write(data) != data.size()) {
            qCritical() << "Failed to write complete Android QML asset:" << dstFilePath;
            return false;
        }
    }

    const QStringList dirs = srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString& dir : dirs) {
        if (kSkipAndroidQmlDirs.contains(dir)) {
            continue;
        }
        if (!copyAndroidAssetDir(
                    srcDir.filePath(dir),
                    QDir(dst).filePath(dir))) {
            return false;
        }
    }

    return true;
}

QString materializeAndroidQmlResources() {
    const QString appDataDir =
            QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (appDataDir.isEmpty()) {
        qCritical() << "Android QML resource materialization failed:"
                       " AppDataLocation is empty";
        return {};
    }

    const QString qmlDir = QDir(appDataDir).filePath(QStringLiteral("qml"));
    const QString skinDir = QDir(appDataDir).filePath(QStringLiteral("skins"));

    // Remove previous materialized copies so an app update cannot leave stale
    // QML files behind after files are removed or renamed in the APK.
    if (QDir(qmlDir).exists() && !QDir(qmlDir).removeRecursively()) {
        qCritical() << "Failed to remove stale Android QML directory:" << qmlDir;
        return {};
    }
    if (QDir(skinDir).exists() && !QDir(skinDir).removeRecursively()) {
        qCritical() << "Failed to remove stale Android skin directory:" << skinDir;
        return {};
    }

    if (!copyAndroidAssetDir(QStringLiteral("assets:/qml"), qmlDir) ||
            !copyAndroidAssetDir(QStringLiteral("assets:/skins"), skinDir)) {
        qCritical() << "Android QML resource materialization failed under" << appDataDir;
        return {};
    }

    const QString mainQmlFilePath = QDir(qmlDir).filePath(QStringLiteral("main.qml"));
    if (!QFileInfo::exists(mainQmlFilePath)) {
        qCritical() << "Android QML resource materialization completed without main.qml:"
                    << mainQmlFilePath;
        return {};
    }

    qInfo() << "Android QML resources materialized in app-private storage:"
            << appDataDir;
    qInfo() << "Android QML shell:" << mainQmlFilePath;
    qInfo() << "Android packaged skins:" << skinDir;
    return mainQmlFilePath;
}
#endif

int runMixxx(MixxxApplication* pApp, const CmdlineArgs& args) {
    CmdlineArgs::Instance().parseForUserFeedback();

    int exitCode;
    auto pCoreServices = std::make_shared<mixxx::CoreServices>(args, pApp);
#ifdef MIXXX_USE_QML
    bool loadQml = args.isQml();

#if defined(Q_OS_ANDROID)
    // Android always uses the QML application shell. Skin selection changes
    // only the MainWindow content inside res/qml/main.qml.
    loadQml = true;

    mixxx::skin::SkinLoader skinLoader(pCoreServices->getSettings());
    const mixxx::skin::SkinPointer pSkin = skinLoader.getConfiguredSkin();
    if (!pSkin || pSkin->type() != mixxx::skin::SkinType::QML) {
        qCritical() << "No valid Android QML skin is available";
        return kFatalErrorOnStartupExitCode;
    }

    // SkinLoader is the authoritative resolver for the configured Android QML skin.
    // Keep the resolved value in the shared UserSettings object so the QML shell
    // consumes the same skin name instead of reinterpreting the raw preference.
    const ConfigKey resizableSkinKey(
            QStringLiteral("[Config]"), QStringLiteral("ResizableSkin"));
    const QString resolvedSkinName = pSkin->name();
    if (pCoreServices->getSettings()->getValueString(resizableSkinKey) != resolvedSkinName) {
        qInfo() << "Normalized Android QML skin selection to" << resolvedSkinName;
        pCoreServices->getSettings()->setValue(resizableSkinKey, resolvedSkinName);
    }

    const QString androidMainQmlPath = materializeAndroidQmlResources();
    if (androidMainQmlPath.isEmpty()) {
        qCritical() << "Cannot start Android QML application without a materialized QML shell";
        return kFatalErrorOnStartupExitCode;
    }
#endif

    if (loadQml) {
        qputenv("QT_QUICK_TABLEVIEW_COMPAT_VERSION", "6.4");
#if defined(Q_OS_ANDROID)
        mixxx::qml::QmlApplication qmlApplication(pApp, pCoreServices, androidMainQmlPath);
#else
        mixxx::qml::QmlApplication qmlApplication(pApp, pCoreServices);
#endif
        if (!qmlApplication.isReady()) {
            exitCode = kFatalErrorOnStartupExitCode;
        } else {
            exitCode = pApp->exec();
        }
    } else
#endif
    {
        MixxxMainWindow mainWindow(pCoreServices);
        pApp->processEvents();
        pApp->installEventFilter(&mainWindow);

#if defined(__WINDOWS__)
        WindowsEventHandler winEventHandler;
        pApp->installNativeEventFilter(&winEventHandler);
#endif

        QObject::connect(pCoreServices.get(),
                &mixxx::CoreServices::initializationProgressUpdate,
                &mainWindow,
                &MixxxMainWindow::initializationProgressUpdate);

        QPixmapCache::setCacheLimit(static_cast<int>(kPixmapCacheLimitAt100PercentZoom *
                pow(pApp->devicePixelRatio(), 2.0f)));

        pCoreServices->initialize(pApp);

        if (pCoreServices->getSettings()->getValue(
                    ConfigKey("[Config]", "did_run_with_unstable"), false)) {
            qInfo() << "User previously ran the unstable version on this profile";
        }

#ifdef MIXXX_USE_QOPENGL
        mainWindow.initializeQOpenGL();
#else
        mainWindow.initialize();
#endif

        pCoreServices->getControllerManager()->setUpDevices();

        if (ErrorDialogHandler::instance()->checkError()) {
            exitCode = kFatalErrorOnStartupExitCode;
        } else {
            qDebug() << "Displaying main window";
            mainWindow.show();

            qDebug() << "Running Mixxx";
            exitCode = pApp->exec();
        }
    }
    return exitCode;
}

void adjustScaleFactor(CmdlineArgs* pArgs) {
    if (qEnvironmentVariableIsSet(kScaleFactorEnvVar)) {
        bool ok;
        const double f = qgetenv(kScaleFactorEnvVar).toDouble(&ok);
        if (ok && f > 0) {
            qDebug() << "Using" << kScaleFactorEnvVar << f;
            pArgs->setScaleFactor(f);
            return;
        }
    }

    auto config = ConfigObject<ConfigValue>(
            QDir(pArgs->getSettingsPath()).filePath(MIXXX_SETTINGS_FILE),
            QString(),
            QString());
    QString strScaleFactor = config.getValue(
            ConfigKey(kConfigGroup, kScaleFactorKey));
    double scaleFactor = strScaleFactor.toDouble();
    if (scaleFactor > 0) {
        qDebug() << "Using preferences ScaleFactor" << scaleFactor;
        qputenv(kScaleFactorEnvVar, strScaleFactor.toLocal8Bit());
        pArgs->setScaleFactor(scaleFactor);
    }
}

void applyStyleOverride(CmdlineArgs* pArgs) {
    if (!pArgs->getStyle().isEmpty()) {
        qDebug() << "Default style is overwritten by command line argument "
                    "-style"
                 << pArgs->getStyle();
        QApplication::setStyle(pArgs->getStyle());
        return;
    }
    if (qEnvironmentVariableIsSet("QT_STYLE_OVERRIDE")) {
        QString styleOverride = QString::fromLocal8Bit(qgetenv("QT_STYLE_OVERRIDE"));
        if (!styleOverride.isEmpty()) {
            qDebug() << "Default style is overwritten by env variable "
                        "QT_STYLE_OVERRIDE"
                     << styleOverride;
            QApplication::setStyle(styleOverride);
        }
    }
}

} // anonymous namespace

#ifdef Q_OS_ANDROID
extern "C" {
JNIEXPORT bool JNICALL
Java_org_qtproject_qt_android_QtNativeAccessibility_accessibilitySupported(JNIEnv*, jobject) {
    return false;
}
}
#endif

int main(int argc, char * argv[]) {
    Console console;

    QCoreApplication::setOrganizationDomain("mixxx.org");

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif
#ifdef MIXXX_USE_QOPENGL
    QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
#endif

#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0) && QT_VERSION < QT_VERSION_CHECK(5, 15, 1)
    qputenv("QV4_FORCE_INTERPRETER", QByteArrayLiteral("1"));
#endif
#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
            Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#endif

#ifdef __LINUX__
    QGuiApplication::setDesktopFileName(QStringLiteral("org.mixxx.Mixxx"));
#endif

    QCoreApplication::setApplicationName(VersionStore::applicationName());
    QCoreApplication::setApplicationVersion(VersionStore::version());

    CmdlineArgs& args = CmdlineArgs::Instance();
    if (!args.parse(argc, argv)) {
        return kParseCmdlineArgsErrorExitCode;
    }

    QThread::currentThread()->setObjectName("Main");
    ErrorDialogHandler::instance();

#ifdef __APPLE__
    Sandbox::checkSandboxed();
#endif

    adjustScaleFactor(&args);

    MixxxApplication app(argc, argv);

#if defined(Q_OS_WIN)
    QApplication::setStyle("windowsvista");
#endif

    applyStyleOverride(&args);

    qInfo() << "Selected Qt style:" << QApplication::style()->objectName();

#if defined(Q_OS_WIN)
    if (QApplication::style()->objectName() != "windowsvista") {
        qWarning() << "Qt style for Windows is not set to 'windowsvista'. GUI might look broken!";
    }
#endif

    auto config = ConfigObject<ConfigValue>(
            QDir(args.getSettingsPath()).filePath(MIXXX_SETTINGS_FILE),
            QString(),
            QString());
    int notifywarningThreshold = config.getValue<int>(
            ConfigKey(kConfigGroup, kNotifyMaxDbgTimeKey), 10);
    app.setNotifyWarningThreshold(notifywarningThreshold);

#ifdef Q_OS_MACOS
    QApplication::setQuitOnLastWindowClosed(false);
#endif

#ifdef __APPLE__
    QDir dir(QApplication::applicationDirPath());
    if (dir.path().contains(".app/")) {
        dir.cdUp();
        dir.cd("PlugIns");
        qDebug() << "Setting Qt plugin search path to:" << dir.absolutePath();
        QApplication::setLibraryPaths(QStringList(dir.absolutePath()));
    }
#endif

    QObject::connect(&app, &MixxxApplication::lastWindowClosed, &app, &MixxxApplication::quit);

    int exitCode = runMixxx(&app, args);

    qDebug() << "Mixxx shutdown complete with code " << exitCode;

    mixxx::Logging::shutdown();

    return exitCode;
}
