import QtQuick
import QtQuick.Controls
import "../LateNightTheme"
import "." as LateNightSamplers

Item {
    id: root

    required property bool show

    function syncPopupToState() {
        if (root.show)
            samplersPopup.open();
        else
            samplersPopup.close();
    }

    onShowChanged: root.syncPopupToState()

    Component.onCompleted: root.syncPopupToState()

    Popup {
        id: samplersPopup

        x: 0
        y: 62
        width: root.parent ? root.parent.width : 0
        height: root.parent ? Math.min(360, Math.max(0, root.parent.height - 62)) : 0
        modal: false
        focus: false
        closePolicy: Popup.NoAutoClose
        padding: 0

        background: Rectangle {
            color: "#080808"
            opacity: 0.98
        }

        LateNightSamplers.SamplersRack {
            anchors.fill: parent
        }
    }
}
