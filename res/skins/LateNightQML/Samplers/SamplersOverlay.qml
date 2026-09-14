import QtQuick
import "../LateNightTheme"
import "." as LateNightSamplers

Item {
    id: root

    required property bool show

    visible: show
    height: visible ? Math.min(samplersRack.implicitHeight, Math.max(0, parent.height - 64)) : 0
    width: parent.width
    clip: true
    z: 10020

    Rectangle {
        anchors.fill: parent
        color: "#080808"
        opacity: 0.98
    }

    LateNightSamplers.SamplersRack {
        id: samplersRack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }
}
