import "../../qml" as Default
import QtQuick
import QtQuick.Window

Item {
    id: root

    required property ApplicationWindow applicationWindow
    property alias menuBar: mainWindow.menuBar

    Default.MainWindow {
        id: mainWindow

        anchors.fill: parent
        applicationWindow: root.applicationWindow
    }
}
