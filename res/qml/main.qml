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
    property bool selectedSkinUsingAssetFallback: false
    property string selectedSkinLoadError: ""

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

    function selectedSkinName() {
        return NraveSelectedSkin !== "" ? NraveSelectedSkin
                                       : (Mixxx.Config.configSkin || "AndroidDefault");
    }

    function selectedMainWindowUrl() {
        const selectedSkin = root.selectedSkinName();
        if (selectedSkin === "" || selectedSkin === "AndroidDefault") {
            return Qt.resolvedUrl("MainWindow.qml");
        }

        if (Qt.platform.os === "android" &&
                NraveSelectedSkinMainWindowUrl !== "") {
            return NraveSelectedSkinMainWindowUrl;
        }

        return Qt.resolvedUrl("../skins/" + selectedSkin + "/MainWindow.qml");
    }

    readonly property bool preferencesOpen: settingsPopup.opened

    function openPreferences() {
        if (!settingsPopup.opened) {
            settingsPopup.open();
        }
    }

    function loadSelectedMainWindow() {
        root.selectedSkinUsingAssetFallback = false;
        root.selectedSkinLoadError = "";
        const sourceUrl = root.selectedMainWindowUrl();
        console.info(
                "Loading resolved QML skin entrypoint:",
                root.selectedSkinName(),
                sourceUrl);
        content.setSource(sourceUrl, { "applicationWindow": root });
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
        objectName: "nrave_selected_skin_loader"
        anchors.fill: parent
        active: Mixxx.Core.ready
        asynchronous: true
        onActiveChanged: {
            if (active) {
                root.loadSelectedMainWindow();
            }
        }
        onStatusChanged: {
            if (status !== Loader.Error) {
                return;
            }

            const selectedSkin = root.selectedSkinName();
            root.selectedSkinLoadError = selectedSkin + " @ " + source;
            console.error(
                    "Failed to load the resolved Mixxx QML skin entrypoint:",
                    source,
                    "skin:",
                    selectedSkin);

            // Do not silently replace an explicitly selected QML skin with
            // AndroidDefault. The resolved skin entrypoint is authoritative;
            // keeping the error visible prevents a loader failure from being
            // mistaken for a preference or persistence problem.
        }
    }

    Skin.Settings {
        id: settingsPopup

        height: Math.min(840, parent.height)
        modal: true
        width: Math.min(1400, parent.width)
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        Overlay.modal: Rectangle {
            id: overlayModal

            readonly property bool hasHardwareAcceleration: Mixxx.Config.useAcceleration
            property real radius: 12

            anchors.fill: parent
            color: Qt.alpha('#00000010', hasHardwareAcceleration ? 1.0 : 0.6)

            Repeater {
                model: hasHardwareAcceleration ? 1 : 0

                GaussianBlur {
                    anchors.fill: overlayModal
                    deviation: 4
                    radius: Math.max(0, overlayModal.radius)
                    samples: 16
                    source: content
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
        anchors.fill: parent
        color: "#b00020"
        opacity: content.status === Loader.Error ? 0.96 : 0
        visible: opacity > 0
        z: 200000

        Text {
            anchors.centerIn: parent
            anchors.margins: 24
            color: "white"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            text: "QML skin failed to load\\n\\n" + root.selectedSkinLoadError
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            width: Math.min(parent.width - 48, 900)
        }

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
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