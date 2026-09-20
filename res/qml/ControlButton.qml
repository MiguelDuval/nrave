import "." as Skin

Skin.Button {
    id: root

    required property string group
    required property string key
    property bool toggleable: false
    property string displayKey: ""
    readonly property bool isRecordingControl: root.group === "[Recording]" && root.key === "toggle_recording"

    function toggle() {
        controlBehavior.toggleControl();
    }

    highlight: controlBehavior.isActive
    normalBackgroundColor: root.isRecordingControl && controlBehavior.isActive ? Theme.buttonActiveBackgroundColor : Theme.buttonControlNormalBackgroundColor
    onPressed: {
        controlBehavior.pressPrimary();
    }
    onReleased: {
        controlBehavior.releasePrimary();
    }

    ControlProxyButtonBehavior {
        id: controlBehavior

        activeDisplayThreshold: 0
        displayKey: root.isRecordingControl ? "status" : root.displayKey
        group: root.group
        key: root.key
        toggleable: root.isRecordingControl ? false : root.toggleable
        handlePointerInput: false
    }
}
