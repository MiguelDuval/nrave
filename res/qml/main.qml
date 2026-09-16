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
    readonly property bool useLateNightQmlSkin: isMobile && Mixxx.Config.configSkin === "LateNightQML"
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

        const sourceUrl = root.useLateNightQmlSkin
                ? "assets:/skins/LateNightQML/MainWindow.qml"
                : "MainWindow.qml";
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
                console.error("Failed to load the configured main window")
                Qt.quit()
            }
        }
    }

    // This is the real Android QML runtime entrypoint. QmlApplication on
    // Android copies res/qml into external storage and always loads this file.
    Loader {
        id: abletonLinkOverlay
        anchors.fill: parent
        active: root.isMobile && Mixxx.Core.ready && content.status === Loader.Ready
        asynchronous: false
        z: 100001
        source: "AbletonLinkOverlay.qml"
    }

    // IMPORTANT: this Loader is deliberately created only after Mixxx.Core is
    // ready and MainWindow has loaded. ControlProxy objects inside
    // BitGridOverlay therefore see the already-created engine controls.
    // The overlay itself spans the whole Android window so its editor panel
    // can be laid out independently from the compact entry buttons.
    Loader {
        id: bitgridOverlay
        anchors.fill: parent
        active: root.isMobile && Mixxx.Core.ready && content.status === Loader.Ready
        asynchronous: false
        z: 100000
        source: "BitGridOverlay.qml"
    }

    // Samplers are rendered by MainWindow.qml through the Android-safe
    // SamplerRow adapter. Do not create a second root-level sampler instance.

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
