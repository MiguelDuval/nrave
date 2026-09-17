import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "LateNightTheme"

ApplicationWindow {
    id: root

    property int displayedProgress: 0
    property bool mainWindowLoadError: false

    color: startupScreen.backgroundColor
    height: 1008
    menuBar: mainWindowLoader.item ? mainWindowLoader.item.menuBar : null
    minimumHeight: 668
    minimumWidth: 1280
    visible: true
    width: 1792

    function updateVisibility() {
        if (!Mixxx.Core.ready)
            return;
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
            root.mainWindowLoadError = true;
            console.error("Failed to load the LateNightQML main window:", mainWindowLoader.source);
        }
    }

    Connections {
        target: Mixxx.Core

        function onInitializationProgressChanged() {
            root.updateProgress();
            root.updateVisibility();
        }

        function onReadyChanged() {
            root.updateProgress();
            root.updateVisibility();
        }
    }

    Loader {
        id: mainWindowLoader

        active: Mixxx.Core.ready
        anchors.fill: parent
        asynchronous: true
        onProgressChanged: root.updateProgress()
        onStatusChanged: root.handleMainWindowLoaderStatus()
        source: Qt.resolvedUrl("MainWindow.qml")
    }

    StartupScreen {
        id: startupScreen

        anchors.fill: parent
        opacity: mainWindowLoader.status === Loader.Ready || root.mainWindowLoadError ? 0 : 1
        progress: root.displayedProgress
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#101114"
        visible: root.mainWindowLoadError

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                font.pixelSize: 22
                text: "LateNight QML failed to load"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#b8bbc4"
                font.pixelSize: 14
                text: "MainWindow.qml could not be instantiated."
            }
        }
    }

    Component.onCompleted: {
        updateProgress();
        updateVisibility();
    }
}
