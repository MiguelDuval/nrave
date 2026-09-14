import Mixxx 1.0 as Mixxx
import QtQuick
import "../LateNightTheme"
import "." as LateNightSamplers

Item {
    id: root

    required property bool show

    Mixxx.ControlProxy {
        id: showControl

        group: "[Skin]"
        key: "show_samplers"

        onInitializedChanged: {
            if (initialized)
                value = root.show ? 1.0 : 0.0;
        }
    }

    function syncControlToButtonState() {
        if (showControl.initialized)
            showControl.value = root.show ? 1.0 : 0.0;
    }

    onShowChanged: root.syncControlToButtonState()

    visible: show || (showControl.initialized && showControl.value > 0.0)
    height: visible ? Math.min(360, Math.max(0, parent.height - 64)) : 0
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
        anchors.fill: parent
    }
}
