pragma ComponentBehavior: Bound

import "." as Skin
import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    id: root

    property int auxiliaryCount: 4
    property int fxUnitCount: 4

    implicitHeight: 112
    implicitWidth: parent ? parent.width : 0

    Loader {
        id: desktopLoader

        anchors.fill: parent
        active: Qt.platform.os !== "android"

        sourceComponent: Component {
            RowLayout {
                anchors.fill: parent
                spacing: 8

                Repeater {
                    model: Math.max(0, root.auxiliaryCount)

                    Skin.AuxiliaryUnit {
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        fxUnitCount: root.fxUnitCount
                        unitNumber: index + 1
                    }
                }
            }
        }
    }

    Flickable {
        id: androidAuxPanel

        anchors.fill: parent
        anchors.margins: 2
        clip: true
        contentHeight: height
        contentWidth: auxiliaryRow.implicitWidth
        visible: Qt.platform.os === "android"

        Row {
            id: auxiliaryRow

            height: parent.height
            spacing: 8

            Repeater {
                model: Math.max(0, root.auxiliaryCount)

                Skin.AuxiliaryUnit {
                    required property int index

                    fxUnitCount: root.fxUnitCount
                    height: Math.max(108, root.height - 4)
                    unitNumber: index + 1
                }
            }
        }
    }
}
