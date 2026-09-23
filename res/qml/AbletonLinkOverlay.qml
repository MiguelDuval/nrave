import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import Qt5Compat.GraphicalEffects
import "Theme"

Item {
    id: root

    anchors.fill: parent
    z: 100001
    visible: Qt.platform.os === "android" && Mixxx.Core.ready

    Mixxx.ControlProxy {
        id: linkEnabled
        group: "[AbletonLink]"
        key: "sync_enabled"
    }

    Mixxx.ControlProxy {
        id: linkPeers
        group: "[AbletonLink]"
        key: "num_peers"
    }

    Mixxx.ControlProxy {
        id: linkSync
        group: "[AbletonLink]"
        key: "sync_decks"
    }

    Skin.Button {
        id: linkButton

        x: 364
        y: 5
        width: 52
        height: 26
        text: "Link"
        highlight: linkEnabled.initialized && linkEnabled.value > 0.5
        activeColor: Theme.white

        onPressed: {
            if (linkEnabled.initialized) {
                linkEnabled.value = linkEnabled.value > 0.5 ? 0.0 : 1.0;
            }
        }
    }

    Text {
        x: 418
        y: 5
        width: 42
        height: 26
        color: Theme.lightGray3
        font.family: Theme.fontFamily
        font.pixelSize: 9
        font.bold: true
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: linkPeers.initialized ? "P" + Math.max(0, Math.round(linkPeers.value)) : ""
    }

    Skin.Button {
        id: linkSyncButton

        x: 462
        y: 5
        width: 58
        height: 26
        text: "Sync"
        activeColor: Theme.white
        enabled: linkEnabled.initialized && linkEnabled.value > 0.5
        highlight: linkSync.initialized && linkSync.value > 0.5

        onPressed: {
            if (linkSync.initialized && enabled) {
                linkSync.value = linkSync.value > 0.5 ? 0.0 : 1.0;
            }
        }
    }

    // Product label: centered in the exact space between Ableton Link Sync
    // and the right-side Support Us / Help / Preferences utility cluster.
    // MainWindow uses 78 + 50 + 76 px controls with 5 px spacing.
    Item {
        id: productBrandSlot

        readonly property int rightUtilityClusterWidth: 214
        x: linkSyncButton.x + linkSyncButton.width + 8
        y: 0
        width: Math.max(0, root.width - rightUtilityClusterWidth - x - 8)
        height: root.height

        Text {
            id: brandGlowText

            anchors.centerIn: parent
            color: Theme.primaryCyan
            font.bold: true
            font.family: Theme.fontFamily
            font.letterSpacing: 1.3
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.9
            text: "NRAVE"
            verticalAlignment: Text.AlignVCenter
            visible: text !== ""
        }

        Glow {
            anchors.fill: brandGlowText
            cached: true
            color: Theme.primaryCyan
            opacity: 0.75
            radius: 9
            samples: 19
            spread: 0.22
            source: brandGlowText
        }

        Text {
            anchors.centerIn: parent
            color: Theme.brightCyan
            font.bold: true
            font.family: Theme.fontFamily
            font.letterSpacing: 1.3
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            text: "NRAVE"
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primaryCyan
            height: 1
            opacity: 0.55
            width: Math.min(64, Math.max(34, brandGlowText.implicitWidth * 0.72))
        }
    }
}
