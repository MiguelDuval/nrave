import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import "Theme"

Item {
    id: root

    required property string group

    Rectangle {
        id: gainKnobFrame

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Theme.knobBackgroundColor
        height: width
        radius: 5

        Skin.ControlKnob {
            id: gainKnob

            anchors.centerIn: parent
            color: Theme.gainKnobColor
            group: root.group
            height: 36
            key: "pregain"
            width: 36
        }
    }
    Item {
        anchors.bottom: filterSelector.top
        anchors.bottomMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: gainKnobFrame.bottom
        anchors.topMargin: 5

        Skin.VuMeter {
            group: root.group
            height: parent.height - 22
            key: "vu_meter_left"
            width: 4
            x: 15
            y: (parent.height - height) / 2
        }
        Skin.VuMeter {
            group: root.group
            height: parent.height - 22
            key: "vu_meter_right"
            width: 4
            x: parent.width - width - 15
            y: (parent.height - height) / 2
        }
        Skin.ControlFader {
            id: volumeSlider

            anchors.fill: parent
            bar.color: Theme.volumeSliderBarColor
            bg: Theme.imgVolumeSliderBackground
            group: root.group
            key: "volume"

            handleImage {
                width: parent.width - 4
            }
        }
    }
    Mixxx.ControlProxy {
        id: fxSelect

        group: "[QuickEffectRack1_" + root.group + "]"
        key: "loaded_chain_preset"
    }
    Skin.ComboBox {
        id: filterSelector

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        height: 22
        currentIndex: fxSelect.value == -1 ? 0 : fxSelect.value
        font.pixelSize: 10
        indicator.width: 0
        model: Mixxx.EffectsManager.quickChainPresetModel
        popupMaxItem: 8
        popupWidth: 100
        spacing: 2
        textRole: "display"

        onActivated: index => {
            fxSelect.value = index;
        }
    }
}
