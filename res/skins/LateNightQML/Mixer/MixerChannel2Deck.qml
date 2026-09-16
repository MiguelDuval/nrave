import QtQuick
import "../Controls" as LateNightControls
import "../LateNightTheme"

Item {
    id: root

    required property string group
    property bool mirror: false
    property bool showEqKillButtons: true
    property bool showEqKnobs: true
    property bool showXfader: true

    implicitHeight: 170
    implicitWidth: root.showEqKnobs ? (root.showEqKillButtons ? 109 : 91) : 42

    Item {
        anchors.left: root.mirror ? parent.left : undefined
        anchors.right: root.mirror ? undefined : parent.right
        height: parent.height
        width: 109

        EqQuickColumn {
            id: eqColumn
            alignRight: root.mirror
            group: root.group
            showEqKillButtons: root.showEqKillButtons
            showEqKnobs: root.showEqKnobs
            x: root.mirror ? 51 : 0
            y: 6
        }

        LateNightControls.Fader {
            backgroundSource: LateNightTheme.assetMixerVolumeSliderBackground
            group: root.group
            handleHeight: 18
            handleSource: LateNightTheme.assetMixerVolumeSliderHandle
            handleWidth: 40
            height: 91
            key: "volume"
            orientation: Qt.Vertical
            width: 40
            x: root.mirror ? 3 : 64
            y: 40
        }

        QuickEffectSelector {
            arrowOnRight: root.mirror
            group: root.group
            visible: root.showEqKnobs
            width: root.showEqKillButtons ? 62 : 40
            x: root.mirror ? 42 : (root.showEqKillButtons ? 5 : 18)
            y: 133
        }

        CrossfaderAssignButton {
            group: root.group
            leftStyle: root.mirror ? "warning" : "default"
            rightStyle: root.mirror ? "default" : "warning"
            visible: root.showXfader
            x: root.showEqKnobs ? (root.mirror ? 46 : 22) : (root.mirror ? 18 : 57)
            y: 156
        }
    }
}
