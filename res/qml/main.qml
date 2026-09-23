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

    Connections {
        target: Mixxx.Core
        function onReadyChanged() {
            root.updateVisibility();
        }
    }

    Component.onCompleted: root.updateVisibility()

    Loader {
        id: content
        anchors.fill: parent
        active: Mixxx.Core.ready
        asynchronous: true
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("Failed to load the Mixxx main window")
                Qt.quit()
            }
        }
        sourceComponent: Component {
            MainWindow {
                applicationWindow: root
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


    // NRave launch curtain: this is the first QML layer on Android and stays
    // above the UI until the real MainWindow has finished loading.
    Rectangle {
        id: nraveSplashCurtain
        objectName: "nraveSplashCurtain"
        anchors.fill: parent
        color: "#000000"
        opacity: root.isMobile ? 1 : 0
        visible: opacity > 0
        z: 200000

        Image {
            id: nraveSplashArtwork
            objectName: "nraveSplashArtwork"
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: false
            cache: true
            smooth: true
            source: "qrc:/images/nrave_splash.webp"
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        states: [
            State {
                when: content.status === Loader.Ready && content.active
                PropertyChanges {
                    target: nraveSplashCurtain
                    opacity: 0
                }
            }
        ]
    }

}
