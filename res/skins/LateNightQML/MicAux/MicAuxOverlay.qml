import Mixxx 1.0 as Mixxx
import QtQuick
import "../LateNightTheme"

Item {
    id: root

    // Do not gate visibility on ControlProxy.initialized. The toolbar and this
    // overlay use the same [Skin] control, and the proxy can initialize one
    // frame later on Android. The value itself is sufficient and updates when
    // initialization completes.
    property bool show: showMicrophonesControl.value > 0

    visible: show
    height: show ? Math.min(micAuxRack.implicitHeight, Math.max(0, parent.height - 64)) : 0
    width: parent.width
    clip: true
    z: 10010

    Rectangle {
        anchors.fill: parent
        color: "#080808"
        opacity: 0.98
    }

    FunctionalMicAuxRack {
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
