import "." as Skin
import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import "Theme"

Column {
    id: root

    required property string group

    spacing: 4

    Skin.EqKnob {
        knob.color: Theme.eqHighColor
        knob.group: "[EqualizerRack1_" + root.group + "_Effect1]"
        knob.key: "parameter3"
        statusKey: "button_parameter3"
    }
    Skin.EqKnob {
        knob.color: Theme.eqMidColor
        knob.group: "[EqualizerRack1_" + root.group + "_Effect1]"
        knob.key: "parameter2"
        statusKey: "button_parameter2"
    }
    Skin.EqKnob {
        knob.color: Theme.eqLowColor
        knob.group: "[EqualizerRack1_" + root.group + "_Effect1]"
        knob.key: "parameter1"
        statusKey: "button_parameter1"
    }
    Skin.QuickFxKnob {
        group: "[QuickEffectRack1_" + root.group + "]"
        knob.arcStyle: ShapePath.DashLine
        knob.arcStylePattern: [2, 2]
        knob.color: Theme.eqFxColor
    }
}
