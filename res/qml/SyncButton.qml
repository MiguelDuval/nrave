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

    function otherDeckGroup() {
        switch (root.group) {
        case "[Channel1]":
            return "[Channel2]";
        case "[Channel2]":
            return "[Channel1]";
        case "[Channel3]":
            return "[Channel4]";
        case "[Channel4]":
            return "[Channel3]";
        default:
            return "";
        }
    }

    function makeLeader() {
        // Explicitly select this deck as leader and the paired deck as follower.
        if (otherSyncModeControl.valid) {
            otherSyncModeControl.value = SyncButton.SyncMode.Follower;
        }
        modeControl.value = SyncButton.SyncMode.ExplicitLeader;
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
    onPressAndHold: makeLeader()

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

    Mixxx.ControlProxy {
        id: otherSyncModeControl

        group: root.otherDeckGroup()
        key: "sync_mode"
    }
}
