import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "LateNightTheme"
import "Samplers" as LateNightSamplers

Item {
    id: root
    property int displayedProgress: 0
    property bool diagnosticForcePanel: false
    color: startupScreen.backgroundColor
    height: 1008
    minimumHeight: 668
    minimumWidth: 1280
    width: 1792

    // On mobile (Android/iOS), the shell loads MainWindow.qml directly.
    // This Item is a no-op on mobile. On desktop, it loads MainWindow.qml.
    readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"

    // Forward the shell's ApplicationWindow to MainWindow.qml on desktop.
    required property ApplicationWindow applicationWindow

    Mixxx.ControlProxy { id: bitgrid1Action; group: "[Channel1]"; key: "beats_translate_curpos" }
    Mixxx.ControlProxy { id: bitgrid2Action; group: "[Channel2]"; key: "beats_translate_curpos" }
    Mixxx.ControlProxy { id: abletonLinkControl; group: "[AbletonLink]"; key: "sync_enabled" }
    Mixxx.ControlProxy {
        id: numSamplersControl
        group: "[App]"
        key: "num_samplers"
        onInitializedChanged: {
            if (initialized && value < 8)
                value = 8;
        }
    }
    Mixxx.ControlProxy {
        id: diagnosticShowSamplersControl
        group: "[Skin]"
        key: "show_samplers"
    }

    function updateVisibility() {
        if (!Mixxx.Core.ready) return;
        if (!root.isMobile) {
            // Only relevant on desktop where this Item is the root window
            // On mobile, the shell handles visibility
        }
    }
    function updateProgress() {
        if (!Mixxx.Core.ready)
            displayedProgress = Math.max(displayedProgress, Mixxx.Core.initializationProgress);
        else if (mainWindowLoader.status === Loader.Ready)
            displayedProgress = 100;
        else
            displayedProgress = Math.max(displayedProgress, 65 + Math.round(mainWindowLoader.progress * 34));
    }
    function handleMainWindowLoaderStatus() {
        root.updateProgress();
        if (mainWindowLoader.status === Loader.Error) {
            console.error("Failed to load the LateNightQML main window");
            Qt.quit();
        }
    }
    Connections {
        target: Mixxx.Core
        function onInitializationProgressChanged() { root.updateProgress(); root.updateVisibility(); }
        function onReadyChanged() { root.updateProgress(); root.updateVisibility(); }
    }

    Loader {
        id: mainWindowLoader
        anchors.fill: parent
        // On mobile, the shell loads MainWindow.qml directly. This Loader is only active on desktop.
        active: Mixxx.Core.ready && !root.isMobile
        asynchronous: true
        onProgressChanged: root.updateProgress()
        onStatusChanged: root.handleMainWindowLoaderStatus()
        sourceComponent: Component { MainWindow { applicationWindow: root.applicationWindow; anchors.fill: parent } }
    }

    Rectangle {
        id: bitgridBar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 27
        color: LateNightTheme.toolbarRootBackgroundColor
        height: 34
        width: 283
        z: 10000
        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4
            Repeater {
                model: ["BITGRID 1", "BITGRID 2", "LINK"]
                Rectangle {
                    required property string modelData
                    color: mouse.pressed ? LateNightTheme.toolbarButtonActiveBackgroundColor : LateNightTheme.toolbarButtonInactiveBackgroundColor
                    height: parent.height
                    radius: 2
                    width: 89
                    Text {
                        anchors.fill: parent
                        color: LateNightTheme.toolbarButtonInactiveTextColor
                        font.family: "Open Sans"
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        onClicked: {
                            if (modelData === "BITGRID 1") bitgrid1Action.trigger();
                            else if (modelData === "BITGRID 2") bitgrid2Action.trigger();
                            else abletonLinkControl.value = abletonLinkControl.value > 0.0 ? 0.0 : 1.0;
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: samplerDiagnosticPanel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bitgridBar.bottom
        anchors.topMargin: 4
        height: 106
        color: "#ff00aa"
        border.color: "#ffffff"
        border.width: 2
        z: 20000
        visible: Qt.platform.os === "android"

        Column {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 2

            Text {
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
                text: "SAMPLER DIAGNOSTIC BUILD"
            }
            Text {
                color: "#ffffff"
                font.pixelSize: 12
                text: "OS=" + Qt.platform.os
                    + "  Loader=" + mainWindowLoader.status
                    + "  Main.showSamplers=" + (mainWindowLoader.item ? mainWindowLoader.item.showSamplers : "<null>")
            }
            Text {
                color: "#ffffff"
                font.pixelSize: 12
                text: "Skin/show_samplers=" + diagnosticShowSamplersControl.value
                    + "  App/num_samplers=" + numSamplersControl.value
                    + "  RealPanel.visible=" + mobileSamplerPanel.visible
            }
            Row {
                spacing: 5
                Rectangle {
                    width: 150
                    height: 24
                    radius: 3
                    color: "#111111"
                    Text { anchors.fill: parent; color: "#ffffff"; text: "TOGGLE Skin control"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: diagnosticShowSamplersControl.value = diagnosticShowSamplersControl.value > 0.5 ? 0.0 : 1.0
                    }
                }
                Rectangle {
                    width: 150
                    height: 24
                    radius: 3
                    color: "#111111"
                    Text { anchors.fill: parent; color: "#ffffff"; text: "TOGGLE test panel"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 11 }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: diagnosticForcePanel = !diagnosticForcePanel
                    }
                }
            }
        }
    }

    Rectangle {
        id: diagnosticTestStrip
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: samplerDiagnosticPanel.bottom
        anchors.topMargin: 3
        height: 44
        color: "#00d5ff"
        border.color: "#ffffff"
        border.width: 2
        z: 20000
        visible: Qt.platform.os === "android" && (diagnosticForcePanel || (mainWindowLoader.item && mainWindowLoader.item.showSamplers))

        Row {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 3
            Repeater {
                model: 8
                Rectangle {
                    width: (parent.width - 21) / 8
                    height: parent.height
                    color: "#101010"
                    radius: 2
                    Text {
                        anchors.fill: parent
                        color: "#ffffff"
                        text: "S" + (index + 1)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }

    Rectangle {
        id: mobileSamplerPanel
        visible: Qt.platform.os === "android" && mainWindowLoader.status === Loader.Ready && (numSamplersControl.value >= 8) && (mainWindowLoader.item && mainWindowLoader.item.showSamplers)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bitgridBar.bottom
        anchors.topMargin: 4
        height: 46
        color: LateNightTheme.samplerPanelColor
        border.color: LateNightTheme.mixerPanelBorderTop
        border.width: 1
        z: 10000

        RowLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2

            Repeater {
                model: 8

                LateNightSamplers.SamplerMini {
                    required property int index
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    group: "[Sampler" + (index + 1) + "]"
                }
            }
        }
    }

    StartupScreen {
        id: startupScreen
        anchors.fill: parent
        opacity: mainWindowLoader.status === Loader.Ready ? 0 : 1
        progress: root.displayedProgress
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }
    Component.onCompleted: { updateProgress(); updateVisibility(); }
}