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
const QStringList kAndroidQmlDirs = {
        QStringLiteral("Mixxx"),
};

bool copyAndroidAssetDir(const QString& src, const QString& dst) {
    const QDir srcDir(src);
    if (!srcDir.exists()) {
        qCritical() << "NRAVE_ANDROID_STARTUP missing asset directory:" << src;
        return false;
    }

    if (!QDir().mkpath(dst)) {
        qCritical() << "NRAVE_ANDROID_STARTUP cannot create destination:" << dst;
        return false;
    }

    bool ok = true;
    for (const QString& file : srcDir.entryList(QDir::Files)) {
        QFile srcFile(srcDir.absoluteFilePath(file));
        QFile dstFile(QDir(dst).filePath(file));
        if (!srcFile.open(QIODevice::ReadOnly)) {
            qCritical() << "NRAVE_ANDROID_STARTUP cannot read asset:" << srcFile.fileName();
            ok = false;
            continue;
        }
        if (!dstFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qCritical() << "NRAVE_ANDROID_STARTUP cannot write materialized file:"
                        << dstFile.fileName();
            ok = false;
            continue;
        }
        const QByteArray data = srcFile.readAll();
        if (dstFile.write(data) != data.size()) {
            qCritical() << "NRAVE_ANDROID_STARTUP short write:" << dstFile.fileName();
            ok = false;
        }
    }

    for (const QString& dir : srcDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        if (kAndroidQmlDirs.contains(dir)) {
            continue;
        }
        if (!copyAndroidAssetDir(src + '/' + dir, dst + '/' + dir)) {
            ok = false;
        }
    }
    return ok;
}

QString materializeAndroidQmlResources() {
    const QString appDataDir =
            QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (appDataDir.isEmpty()) {
        qCritical() << "NRAVE_ANDROID_STARTUP stage=app-data-missing";
        return {};
    }

    const QString qmlDir = QDir(appDataDir).filePath(QStringLiteral("qml"));
    const QString skinDir = QDir(appDataDir).filePath(QStringLiteral("skins"));

    qWarning() << "NRAVE_ANDROID_STARTUP stage=materialize-begin"
            << "appData=" << appDataDir;

    if (!QDir(qmlDir).removeRecursively() ||
            !QDir(skinDir).removeRecursively()) {
        qCritical() << "NRAVE_ANDROID_STARTUP stage=materialize-reset-failed";
        return {};
    }

    qWarning() << "NRAVE_ANDROID_STARTUP stage=copy-qml-begin"
            << "source=assets:/qml";
    if (!copyAndroidAssetDir(QStringLiteral("assets:/qml"), qmlDir)) {
        qCritical() << "NRAVE_ANDROID_STARTUP stage=copy-qml-failed";
        return {};
    }
    qWarning() << "NRAVE_ANDROID_STARTUP stage=copy-qml-done"
            << "path=" << qmlDir;

    // Stage 4 only needs the explicit contract skins. Do not copy every
    // legacy skin into app-private storage; this keeps the minimal contract
    // small and avoids unrelated assets affecting startup time.
    const QStringList requiredSkinDirs = {
            QStringLiteral("AndroidDefault"),
            QStringLiteral("TestSkin"),
            QStringLiteral("LateNightQML"),
    };
    for (const QString& skinName : requiredSkinDirs) {
        const QString source = QStringLiteral("assets:/skins/") + skinName;
        const QString destination = QDir(skinDir).filePath(skinName);
        qWarning() << "NRAVE_ANDROID_STARTUP stage=copy-skin-begin"
                << "skin=" << skinName;
        if (!copyAndroidAssetDir(source, destination)) {
            qCritical() << "NRAVE_ANDROID_STARTUP stage=copy-skin-failed"
                        << "skin=" << skinName;
            return {};
        }
        qWarning() << "NRAVE_ANDROID_STARTUP stage=copy-skin-done"
                << "skin=" << skinName;
    }

    const QStringList requiredFiles = {
            QDir(qmlDir).filePath(QStringLiteral("main.qml")),
            QDir(skinDir).filePath(QStringLiteral("AndroidDefault/MainWindow.qml")),
            QDir(skinDir).filePath(QStringLiteral("AndroidDefault/skin.ini")),
            QDir(skinDir).filePath(QStringLiteral("TestSkin/MainWindow.qml")),
            QDir(skinDir).filePath(QStringLiteral("TestSkin/skin.ini")),
            QDir(skinDir).filePath(QStringLiteral("LateNightQML/MainWindow.qml")),
            QDir(skinDir).filePath(QStringLiteral("LateNightQML/skin.ini")),
    };
    for (const QString& requiredFile : requiredFiles) {
        if (!QFileInfo::exists(requiredFile)) {
            qCritical() << "NRAVE_ANDROID_STARTUP missing materialized resource:"
                        << requiredFile;
            return {};
        }
    }

    qWarning() << "NRAVE_ANDROID_STARTUP materialized_qml path=" << qmlDir;
    qWarning() << "NRAVE_ANDROID_STARTUP materialized_skins path=" << skinDir;
    return qmlDir;
}
#endif

int runMixxx(MixxxApplication* pApp, const CmdlineArgs& args) {
    CmdlineArgs::Instance().parseForUserFeedback();

    int exitCode;
    qWarning() << "NRAVE_ANDROID_STARTUP stage=core-services-begin";
    auto pCoreServices = std::make_shared<mixxx::CoreServices>(args, pApp);
    qWarning() << "NRAVE_ANDROID_STARTUP stage=core-services-done";
#ifdef MIXXX_USE_QML
    bool loadQml = args.isQml();
    QString mainQmlFilePath;
    QString resolvedSkinName;
    QString resolvedSkinMainWindowPath;

#if defined(Q_OS_ANDROID)
    qWarning() << "NRAVE_ANDROID_STARTUP stage=materialize-call-begin";
    const QString androidQmlDir = materializeAndroidQmlResources();
    qWarning() << "NRAVE_ANDROID_STARTUP stage=materialize-call-done" << "path=" << androidQmlDir;
    if (androidQmlDir.isEmpty()) {
        return kFatalErrorOnStartupExitCode;
    }

    // Android always uses one QML application shell. SkinLoader resolves the
    // MainWindow.qml that the shell will insert.
    loadQml = true;

    mixxx::skin::SkinLoader skinLoader(pCoreServices->getSettings());
    const mixxx::skin::SkinPointer pSkin = skinLoader.getConfiguredSkin();
    if (!pSkin || pSkin->type() != mixxx::skin::SkinType::QML) {
        qCritical() << "NRAVE_SKIN_RESOLVE failed: no valid Android QML skin";
        return kFatalErrorOnStartupExitCode;
    }

    resolvedSkinName = pSkin->name();
    resolvedSkinMainWindowPath = pSkin->mainQmlFilePath();
    if (!QFileInfo::exists(resolvedSkinMainWindowPath)) {
        qCritical() << "NRAVE_SKIN_RESOLVE failed: missing entrypoint"
                    << resolvedSkinMainWindowPath;
        return kFatalErrorOnStartupExitCode;
    }

    if (pCoreServices->getSettings()->getValueString(
                ConfigKey("[Config]", "ResizableSkin")) != resolvedSkinName) {
        pCoreServices->getSettings()->setValue(
                ConfigKey("[Config]", "ResizableSkin"), resolvedSkinName);
        pCoreServices->getSettings()->save();
    }

    mainQmlFilePath = QDir(androidQmlDir).filePath(QStringLiteral("main.qml"));
    qWarning() << "NRAVE_SKIN_RESOLVED"
            << "skin=" << resolvedSkinName
            << "main=" << resolvedSkinMainWindowPath;
#endif

    if (loadQml) {
        qputenv("QT_QUICK_TABLEVIEW_COMPAT_VERSION", "6.4");
        mixxx::qml::QmlApplication qmlApplication(
                pApp,
                pCoreServices,
                mainQmlFilePath,
                resolvedSkinName,
                resolvedSkinMainWindowPath);
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
