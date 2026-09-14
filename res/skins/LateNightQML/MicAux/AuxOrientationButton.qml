pragma ComponentBehavior: Bound

import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string group

    implicitHeight: 15
    implicitWidth: 36

    RowLayout {
        anchors.fill: parent
        spacing: 1
        Repeater {
            model: ["orientation_left", "orientation_center", "orientation_right"]
            Rectangle {
                required property int index
                required property string modelData
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: orientationControl.value === index ? "#555555" : "transparent"
                border.color: "#333333"
                border.width: 1
                radius: 1
                Text {
                    anchors.fill: parent
                    color: "#888888"
                    font.pixelSize: 9
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: ["L", "M", "R"][index]
                }
                TapHandler {
                    onTapped: {
                        orientationControl.value = index;
                    }
                }
            }
        }
    }
    Mixxx.ControlProxy {
        id: orientationControl
        group: root.group
        key: "orientation"
    }
}
