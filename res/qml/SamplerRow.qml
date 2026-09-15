pragma ComponentBehavior: Bound

import "." as Skin
import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    id: root

    property int firstSampler: 1
    property int fxUnitCount: 4
    property int hotcueCount: 8
    property bool minimized: false
    property int samplerCount: 8
    property bool showFxAssignments: true
    property bool showHotcues: true
    property bool showRateControl: true

    implicitHeight: Qt.platform.os === "android" ? 60 : desktopLoader.item ? desktopLoader.item.implicitHeight : 0
    implicitWidth: parent ? parent.width : 0

    Loader {
        id: desktopLoader

        anchors.fill: parent
        active: Qt.platform.os !== "android"
        source: "SamplerRowDesktop.qml"

        onLoaded: {
            item.firstSampler = root.firstSampler;
            item.fxUnitCount = root.fxUnitCount;
            item.hotcueCount = root.hotcueCount;
            item.minimized = root.minimized;
            item.samplerCount = root.samplerCount;
            item.showFxAssignments = root.showFxAssignments;
            item.showHotcues = root.showHotcues;
            item.showRateControl = root.showRateControl;
        }
    }

    GridLayout {
        id: androidSamplerRow

        anchors.fill: parent
        anchors.margins: 2
        columnSpacing: 2
        columns: Math.max(1, root.samplerCount)
        rowSpacing: 0
        visible: Qt.platform.os === "android"

        Repeater {
            model: Math.max(0, root.samplerCount)

            Item {
                id: samplerSlot

                required property int index

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 56

                Skin.ControlButton {
                    id: playButton

                    anchors.fill: parent
                    activeColor: Theme.samplerColor
                    group: "[Sampler" + (root.firstSampler + samplerSlot.index) + "]"
                    key: "cue_gotoandplay"
                    text: "S" + (root.firstSampler + samplerSlot.index)
                }

                Skin.ControlButton {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    implicitHeight: 18
                    implicitWidth: 24
                    group: "[Sampler" + (root.firstSampler + samplerSlot.index) + "]"
                    key: "eject"
                    text: "×"
                }
            }
        }
    }
}
