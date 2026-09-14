import "../Controls" as Controls
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#080808"
    implicitHeight: Math.max(micRack.implicitHeight, auxRack.implicitHeight) + 3
    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: 3
        spacing: 0
        Controls.RackFiller { Layout.fillHeight: true; Layout.fillWidth: true }
        RowLayout {
            id: micRack
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            spacing: 3
            Repeater {
                model: 4
                MicUnit {
                    required property int index
                    Layout.alignment: Qt.AlignTop
                    unitNumber: index + 1
                }
            }
        }
        Controls.RackFiller { Layout.fillHeight: true; Layout.fillWidth: true }
        RowLayout {
            id: auxRack
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: 2
            Layout.rightMargin: 2
            spacing: 3
            Repeater {
                model: 4
                AuxUnit {
                    required property int index
                    Layout.alignment: Qt.AlignTop
                    unitNumber: index + 1
                }
            }
        }
        Controls.RackFiller { Layout.fillHeight: true; Layout.fillWidth: true }
    }
}
