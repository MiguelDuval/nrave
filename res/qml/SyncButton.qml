import "." as Skin
import Mixxx 1.0 as Mixxx
import "Theme"

Skin.Button {
    id: root

    enum SyncMode {
        Off,
        Follower,
        ImplicitLeader,
        ExplicitLeader
    }

    required property string group
    property alias mode: modeControl.value

    function toggleSync() {
        enabledControl.value = !enabledControl.value;
    }

    function toggleLeader() {
        leaderControl.value = !leaderControl.value;
    }

    activeColor: {
        switch (mode) {
            case SyncButton.SyncMode.ImplicitLeader:
                return Theme.amber;
            case SyncButton.SyncMode.ExplicitLeader:
                return Theme.red;
            default:
                return Theme.primaryCyan;
        }
    }
    text: {
        switch (mode) {
            case SyncButton.SyncMode.ImplicitLeader:
                case SyncButton.SyncMode.ExplicitLeader:
                    return "Leader";
            default:
                return "Sync";
        }
    }
    highlight: enabledControl.value
    onClicked: toggleSync()
    onPressAndHold: toggleLeader()

    Mixxx.ControlProxy {
        id: enabledControl

        group: root.group
        key: "sync_enabled"
    }

    Mixxx.ControlProxy {
        id: modeControl

        group: root.group
        key: "sync_mode"
    }

    Mixxx.ControlProxy {
        id: leaderControl

        group: root.group
        key: "sync_leader"
    }
}
