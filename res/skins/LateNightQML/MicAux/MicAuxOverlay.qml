import QtQuick
import "../LateNightTheme"

Item {
    id: root

    // Visibility is owned by the toolbar button in MainWindow. Do not create a
    // second ControlProxy here: on Android that can race the toolbar state and
    // leave the button active while the overlay stays hidden.
    required property bool show

    visible: show
    height: visible ? Math.min(micAuxRack.implicitHeight, Math.max(0, parent.height - 64)) : 0
    width: parent.width
    clip: true
    z: 10020

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
}
