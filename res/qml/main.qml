import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Window
import "Theme"

ApplicationWindow {
    id: root

    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
    readonly property int designWidth: 1792
    readonly property int designHeight: 1008
    // On mobile, an empty ResizableSkin means no explicit skin has been
    // selected yet. LateNight QML is the new mobile default; Android Default
    // is represented explicitly by the "AndroidDefault" identifier.
    readonly property bool useLateNightQmlSkin: isMobile && Mixxx.Config.configSkin !== "AndroidDefault"
    property var bitGridOverlay: bitgridOverlay.item

    color: Theme.backgroundColor
    height: isMobile ? Screen.height : designHeight
    menuBar: content.item ? content.item.menuBar : null
    minimumHeight: isMobile ? 0 : 300
    minimumWidth: isMobile ? 0 : 680
    visible: true
    width: isMobile ? Screen.width : designWidth

    function updateVisibility() {
        if (!Mixxx.Core.ready) {
            return;
        }
        root.visibility = Mixxx.Config.configStartInFullscreenKey || isMobile
                ? Window.FullScreen
                : Window.Windowed;
    }

    function loadConfiguredSkin() {
        if (!Mixxx.Core.ready) {
            return;
        }

        // QmlApplication is able to load the QML entry point directly from
        // Android's packaged assets. The experimental LateNight skin is also
        // packaged under assets:/skins, so do not depend on MANAGE_EXTERNAL_STORAGE
        // or on a shared /storage/emulated/0/Mixxx directory just to load the skin.
        const sourceUrl = root.useLateNightQmlSkin
                ? (root.isMobile
                        ? "assets:/skins/LateNightQML/MainWindow.qml"
                        : "qrc:/skins/LateNightQML/MainWindow.qml")
                : "MainWindow.qml";
        console.debug("Loading configured main window:", sourceUrl,
                "configSkin:", Mixxx.Config.configSkin);
        content.setSource(sourceUrl, { "applicationWindow": root });
    }

    Connections {
        target: Mixxx.Core
        function onReadyChanged() {
            root.updateVisibility();
            if (Mixxx.Core.ready) {
                root.loadConfiguredSkin();
            }
        }
    }

    Connections {
        target: Mixxx.Config
        function onConfigSkinChanged() {
            if (Mixxx.Core.ready) {
                root.loadConfiguredSkin();
            }
        }
    }

    Component.onCompleted: {
        root.updateVisibility();
        if (Mixxx.Core.ready) {
            root.loadConfiguredSkin();
        }
    }

    Loader {
        id: content
        anchors.fill: parent
        active: Mixxx.Core.ready
        asynchronous: true
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("Failed to load configured main window:", source,
                        "configSkin:", Mixxx.Config.configSkin);
                // Never turn a skin-loading error into a total application exit.
                // Fall back to the known-good Android/default QML window so the
                // application remains usable and the skin problem is diagnosable.
                if (source !== "MainWindow.qml") {
                    console.error("Falling back to Android Default QML window");
                    setSource("MainWindow.qml", { "applicationWindow": root });
                }
            }
        }
    }

    Loader {
        id: abletonLinkOverlay
        anchors.fill: parent
        active: root.isMobile && Mixxx.Core.ready && content.status === Loader.Ready
        asynchronous: false
        z: 100001
        source: "AbletonLinkOverlay.qml"
    }

    Loader {
        id: bitgridOverlay
        anchors.fill: parent
        active: root.isMobile && Mixxx.Core.ready && content.status === Loader.Ready
        asynchronous: false
        z: 100000
        source: "BitGridOverlay.qml"
    }

    Rectangle {
        id: splash
        visible: opacity > 0
        color: Theme.backgroundColor
        anchors.fill: parent

        property bool ready: false

        Component.onCompleted: ready = true

        states: [
            State {
                when: splash.ready && content.status != Loader.Ready
                PropertyChanges {
                    text.opacity: 1
                    logo.opacity: 1
                    logo.y: root.height / 2 - logo.height / 2
                }
            },
            State {
                when: content.status === Loader.Ready && content.active
                PropertyChanges {
                    splash.opacity: 0
                }
            }
        ]

        Image {
            id: logo
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/mixxx-icon-logo-symbolic.svg"
            opacity: 0
            y: root.height / 2
            Behavior on opacity {
                NumberAnimation { duration: 1500; easing.type: Easing.InOutQuad }
            }
            Behavior on y {
                NumberAnimation { duration: 1500; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            id: text
            opacity: 0
            y: logo.y + logo.height * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            font.pixelSize: 12
            color: Theme.lightGray3
            text: "DJ your way"
            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: 1000 }
                    NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }
}