import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "LateNightTheme"
import "Samplers" as LateNightSamplers

ApplicationWindow {
    id: root

    property int displayedProgress: 0

    color: startupScreen.backgroundColor
    height: 1008
    menuBar: mainWindowLoader.item ? mainWindowLoader.item.menuBar : null
    minimumHeight: 668
    minimumWidth: 1280
    visible: true
    width: 1792

    Mixxx.ControlProxy { id: bitgrid1Action; group: "[Channel1]"; key: "beats_translate_curpos" }
    Mixxx.ControlProxy { id: bitgrid2Action; group: "[Channel2]"; key: "beats_translate_curpos" }
    Mixxx.ControlProxy { id: abletonLinkControl; group: "[AbletonLink]"; key: "sync_enabled" }

    Mixxx.ControlProxy {
        id: showSamplersControl
        group: "[Skin]"
        key: "show_samplers"
        onValueChanged: {
            if (value > 0.5 && mobileSamplerExpandControl.initialized)
                mobileSamplerExpandControl.value = 1.0;
        }
    }
    Mixxx.ControlProxy {
        id: mobileSamplerExpandControl
        group: "[Skin]"
        key: "expand_samplers_1-8"
        onInitializedChanged: {
            if (initialized && Qt.platform.os === "android" && showSamplersControl.value > 0.5)
                value = 1.0;
        }
    }

    function updateVisibility() {
        if (!Mixxx.Core.ready) return;
        root.visibility = Mixxx.Config.configStartInFullscreenKey ? Window.FullScreen : Window.Windowed;
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
        function onInitializationProgressChanged() { root.updateProgress(); }
        function onReadyChanged() { root.updateProgress(); root.updateVisibility(); }
    }

    Loader {
        id: mainWindowLoader
        anchors.fill: parent
        active: Mixxx.Core.ready
        asynchronous: true
        onProgressChanged: root.updateProgress()
        onStatusChanged: root.handleMainWindowLoaderStatus()
        sourceComponent: Component {
            MainWindow { applicationWindow: root; anchors.fill: parent }
        }
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
                        text: parent.parentData.modelData
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
        id: mobileSamplerPanel
        visible: Qt.platform.os === "android" && showSamplersControl.value > 0.5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: bitgridBar.bottom
        anchors.topMargin: 4
        height: 204
        color: LateNightTheme.samplerPanelColor
        border.color: LateNightTheme.mixerPanelBorderTop
        border.width: 1
        z: 10000

        LateNightSamplers.SamplerGroup {
            anchors.fill: parent
            anchors.margins: 4
            count: 8
            expandKey: "expand_samplers_1-8"
            firstSampler: 1
            preloadExpandedContent: true
            show8Hotcues: true
            showFxAssignments: false
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
