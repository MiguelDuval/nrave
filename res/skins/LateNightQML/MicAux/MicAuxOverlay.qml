import QtQuick
import QtQuick.Controls
import "../LateNightTheme"

Item {
    id: root

    required property bool show

    function syncPopupToState() {
        if (root.show)
            micAuxPopup.open();
        else
            micAuxPopup.close();
    }

    onShowChanged: root.syncPopupToState()

    Component.onCompleted: root.syncPopupToState()

    Popup {
        id: micAuxPopup

        x: 0
        y: 62
        width: root.parent ? root.parent.width : 0
        height: root.parent ? Math.min(180, Math.max(0, root.parent.height - 62)) : 0
        modal: false
        focus: false
        closePolicy: Popup.NoAutoClose
        padding: 0

        background: Rectangle {
            color: "#080808"
            opacity: 0.98
        }

        FunctionalMicAuxRack {
            anchors.fill: parent
        }
    }
}
