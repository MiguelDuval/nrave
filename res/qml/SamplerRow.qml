pragma ComponentBehavior: Bound

import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Layouts 1.12
import "Theme"

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
                readonly property string samplerGroup: "[Sampler" + (root.firstSampler + samplerSlot.index) + "]"

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 56

                Mixxx.ControlProxy {
                    id: trackLoadedControl

                    group: samplerSlot.samplerGroup
                    key: "track_loaded"
                }
                Mixxx.ControlProxy {
                    id: playControl

                    group: samplerSlot.samplerGroup
                    key: "play"
                }

                Skin.ControlButton {
                    id: playButton

                    anchors.fill: parent
                    activeColor: Theme.samplerColor
                    group: samplerSlot.samplerGroup
                    highlight: trackLoadedControl.value > 0 && playControl.value > 0
                    key: "cue_gotoandplay"
                    text: trackLoadedControl.value > 0 ? "S" + (root.firstSampler + samplerSlot.index) : "Empty"
                }

                Loader {
                    id: trackInfoLoader

                    anchors.left: playButton.left
                    anchors.right: playButton.right
                    anchors.top: playButton.top
                    anchors.margins: 4
                    active: trackLoadedControl.value > 0
                    z: 2

                    sourceComponent: Component {
                        Item {
                            implicitHeight: 18

                            property var samplerPlayer: Mixxx.PlayerManager.getPlayer(samplerSlot.samplerGroup)

                            Text {
                                anchors.fill: parent
                                color: Theme.deckTextColor
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.textFontPixelSize
                                horizontalAlignment: Text.AlignHCenter
                                text: samplerPlayer?.currentTrack?.title ?? "Loaded"
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.left: playButton.left
                    anchors.top: playButton.top
                    anchors.margins: 2
                    border.color: Theme.samplerColor
                    border.width: trackLoadedControl.value > 0 ? 2 : 0
                    color: "transparent"
                    height: 8
                    radius: 4
                    width: 8
                    z: 3
                }

                Skin.ControlButton {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.margins: 2
                    implicitHeight: 18
                    implicitWidth: 24
                    activeColor: Theme.samplerColor
                    group: samplerSlot.samplerGroup
                    key: "stop"
                    text: "■"
                    z: 4
                }

                Skin.ControlButton {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    implicitHeight: 18
                    implicitWidth: 24
                    group: samplerSlot.samplerGroup
                    key: "eject"
                    text: "×"
                    z: 4
                }
            }
        }
    }
}
