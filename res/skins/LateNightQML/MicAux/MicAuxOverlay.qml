import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import "../LateNightTheme"

Item {
    id: root

    property bool show: showMicrophonesControl.initialized && showMicrophonesControl.value > 0

    visible: show
    height: visible ? Math.min(micAuxRack.implicitHeight, parent.height - 64) : 0
    width: parent.width
    z: 10010

    Rectangle {
        anchors.fill: parent
        color: "#080808"
        opacity: 0.98
    }

    MicAuxRack {
        id: micAuxRack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Mixxx.ControlProxy {
        id: showMicrophonesControl
        group: "[Skin]"
        key: "show_microphones"
    }
}
