import Mixxx 1.0 as Mixxx
import QtQuick.Shapes
import QtQuick 2.12
import QtQuick.Window
import ".." as Skin
import "../Theme"

Item {
    id: root

    property color buttonColor: trackLoadedControl.value > 0 ? Theme.buttonActiveColor : Theme.buttonDisableColor
    required property string group
    readonly property var beatGridOverlay: Window.window ? Window.window.bitGridOverlay : null
    readonly property int beatGridDeckNumber: root.group === "[Channel1]" ? 1 : root.group === "[Channel2]" ? 2 : 0

    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"
    }
    Mixxx.ControlProxy {
        id: quantizeControl

        group: root.group
        key: "quantize"
    }
    Skin.ControlButton {
        id: reverseButton

        activeColor: Theme.deckActiveColor
        group: root.group
        implicitHeight: 22
        implicitWidth: 22
        key: "reverse"

        contentItem: Shape {
            anchors.fill: parent
            antialiasing: true
            layer.enabled: true
            layer.samples: 4

            ShapePath {
                fillColor: root.buttonColor
                startX: 5
                startY: 11
                strokeColor: 'transparent'

                PathLine {
                    x: 20
                    y: 4
                }
                PathLine {
                    x: 20
                    y: 18
                }
                PathLine {
                    x: 5
                    y: 11
                }
            }
        }
    }
    Skin.Button {
        id: quantizeButton

        activeColor: Theme.white
        anchors.left: reverseButton.right
        anchors.leftMargin: 5
        height: 22
        width: 22
        enabled: quantizeControl.initialized
        highlight: quantizeControl.initialized && quantizeControl.value > 0.5
        text: "Q"

        onClicked: {
            quantizeControl.value = quantizeControl.value > 0.5 ? 0 : 1;
        }
    }
    Skin.Button {
        id: beatgridButton

        activeColor: Theme.white
        anchors.right: ejectButton.left
        anchors.rightMargin: 5
        height: 22
        width: 60
        text: "BEATGRID"
        visible: root.beatGridDeckNumber > 0

        onClicked: {
            if (root.beatGridOverlay && root.beatGridDeckNumber > 0) {
                root.beatGridOverlay.open(root.beatGridDeckNumber);
            }
        }
    }
    Skin.ControlButton {
        id: keylockButton

        activeColor: Theme.deckActiveColor
        anchors.right: beatgridButton.visible ? beatgridButton.left : ejectButton.left
        anchors.rightMargin: 5
        group: root.group
        implicitHeight: 22
        implicitWidth: 46
        key: "keylock"
        text: "Key Lock"
        toggleable: true
    }
    Skin.ControlButton {
        id: ejectButton

        activeColor: Theme.deckActiveColor
        anchors.right: parent.right
        group: root.group
        implicitHeight: 22
        implicitWidth: 22
        key: "eject"

        contentItem: Item {
            anchors.fill: parent

            Shape {
                antialiasing: true
                height: 10
                layer.enabled: true
                layer.samples: 4
                width: 15

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 5
                }
                ShapePath {
                    fillColor: root.buttonColor
                    startX: 7.5
                    startY: 0
                    strokeColor: 'transparent'

                    PathLine {
                        x: 15
                        y: 10
                    }
                    PathLine {
                        x: 0
                        y: 10
                    }
                    PathLine {
                        x: 7.5
                        y: 0
                    }
                }
            }
            Rectangle {
                color: root.buttonColor
                height: 2
                width: 15

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 3
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
