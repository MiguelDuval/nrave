import "." as Skin
import Mixxx 1.0 as Mixxx
import "Theme"

Skin.Button {
    id: root

    required property string group
    required property string key
    property bool toggleable: false
    readonly property bool isRecordingControl: root.group === "[Recording]" && root.key === "toggle_recording"

    function toggle() {
        controlBehavior.toggleControl();
    }

    function updateRecordingVisual() {
        if (root.isRecordingControl) {
            root.activeBackgroundColor = recordingStatus.value >= 2 ? Theme.red : "#2D4EA1";
        }
    }

    highlight: root.isRecordingControl ? recordingStatus.value > 0 : controlBehavior.isActive
    onPressed: {
        controlBehavior.pressPrimary();
    }
    onReleased: {
        controlBehavior.releasePrimary();
    }

    Component.onCompleted: {
        updateRecordingVisual();
    }

    ControlProxyButtonBehavior {
        id: controlBehavior

        group: root.group
        key: root.key
        toggleable: root.isRecordingControl ? false : root.toggleable
        handlePointerInput: false
    }

    Mixxx.ControlProxy {
        id: recordingStatus

        group: "[Recording]"
        key: "status"
        enabled: root.isRecordingControl

        onValueChanged: {
            root.updateRecordingVisual();
        }
    }
}
