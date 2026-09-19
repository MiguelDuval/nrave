import QtQuick
import QtQuick.Window

Item {
    id: root

    required property ApplicationWindow applicationWindow
    property Item menuBar: null

    Component.onCompleted: {
        console.info(
            "NRAVE_SKIN_CONTRACT_TEST ready",
            "applicationWindow=",
            applicationWindow !== null
        )
    }

    Rectangle {
        anchors.fill: parent
        color: "#101820"
    }

    Column {
        anchors.centerIn: parent
        spacing: 18

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.bold: true
            font.pixelSize: 42
            text: "NRAVE TEST SKIN"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#7dd3fc"
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            text: "ApplicationWindow → Loader → TestSkin/MainWindow.qml"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#94a3b8"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            text: "STAGE 4 CONTRACT PROBE"
        }
    }
}
