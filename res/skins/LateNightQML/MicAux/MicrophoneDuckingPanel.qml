import "../Controls" as Controls
import "../Deck" as DeckControls
import "../../../qml" as Shared
import QtQuick
import QtQuick.Layouts

Controls.Panel {
    id: root

    color: "#1e1e20"
    implicitHeight: 59
    implicitWidth: 48

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 2

        DeckControls.LateNightIconButton {
            id: duckModeButton
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 24
            Layout.preferredWidth: 42
            activeBackgroundSuffix: "active"
            activeColor: "#b24c12"
            activeState: duckModeBehavior.currentState > 0
            backgroundSource: LateNightTheme.lateNightTopRegionButton("medium")
            contentOpacity: 1
            iconSource: LateNightTheme.assetDeckPlayButton
            stretchIcon: true
            Shared.ControlCycleButtonBehavior {
                id: duckModeBehavior
                anchors.fill: parent
                group: "[Master]"
                key: "talkoverDucking"
            }
        }
        Controls.Knob {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 30
            Layout.preferredWidth: 35
            backgroundSource: LateNightTheme.assetSmallKnobBackground
            displayArc: true
            displayArcColor: "#a00000"
            displayArcStart: Controls.Knob.ArcStart.Maximum
            group: "[Master]"
            indicatorColor: "red"
            indicatorKind: "small"
            key: "duckStrength"
        }
    }
}
