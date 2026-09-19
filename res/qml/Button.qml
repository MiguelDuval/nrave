import Qt5Compat.GraphicalEffects
import QtQuick 2
import QtQuick.Controls 2
import "Theme"

AbstractButton {
    id: root

    property color activeColor: Theme.buttonActiveColor
    property color activeBackgroundColor: "#2D4EA1"
    property color normalBackgroundColor: "#2B2B2B"
    property bool highlight: false
    property color normalColor: Theme.buttonNormalColor
    property color pressedColor: activeColor

    implicitHeight: 26
    implicitWidth: 52

    background: Item {
        anchors.fill: parent

        Rectangle {
            id: backgroundImage

            anchors.fill: parent
            color: root.normalBackgroundColor
            radius: 2
        }

        // Diagnostic isolation: Qt5Compat GraphicalEffects are disabled here
        // to determine whether their render-to-texture path causes the Android
        // oversized triangle artifacts. No control contract is changed.
        DropShadow {
            id: effect1
            visible: false
            anchors.fill: backgroundImage
            color: "#80000000"
            horizontalOffset: 0
            radius: 1.0
            source: backgroundImage
            verticalOffset: 0
        }
        InnerShadow {
            id: effect2
            visible: false
            anchors.fill: backgroundImage
            color: "#353535"
            horizontalOffset: 1
            radius: 1
            samples: 16
            source: effect1
            verticalOffset: 1
        }
        InnerShadow {
            visible: false
            anchors.fill: backgroundImage
            color: "#353535"
            horizontalOffset: -1
            radius: 1
            samples: 16
            source: effect2
            verticalOffset: -1
        }
    }

    contentItem: Item {
        anchors.fill: parent

        Glow {
            id: labelGlow
            visible: false
            anchors.fill: parent
            color: label.color
            radius: 1
            source: label
            spread: 0.1
        }

        Label {
            id: label
            anchors.fill: parent
            color: root.normalColor
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.family: Theme.fontFamily
            font.pixelSize: Theme.buttonFontPixelSize
            horizontalAlignment: Text.AlignHCenter
            text: root.text
            verticalAlignment: Text.AlignVCenter
            visible: root.text != null
        }

        Image {
            id: image
            anchors.centerIn: parent
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            height: icon.height
            source: icon.source
            visible: false
            width: icon.width
        }

        ColorOverlay {
            anchors.fill: image
            antialiasing: true
            color: root.normalColor
            source: image
            visible: false
        }
    }

    states: [
        State {
            name: "pressed"
            when: root.pressed
            PropertyChanges {
                color: root.highlight || root.checked ? root.activeBackgroundColor : Theme.darkGray3
                target: backgroundImage
            }
            PropertyChanges {
                color: root.pressedColor
                target: label
            }
        },
        State {
            name: "active"
            when: (root.highlight || root.checked) && !root.pressed
            PropertyChanges {
                color: root.activeBackgroundColor
                target: backgroundImage
            }
            PropertyChanges {
                color: root.activeColor
                target: label
            }
        },
        State {
            name: "inactive"
            when: !root.checked && !root.highlight && !root.pressed
            PropertyChanges {
                color: root.normalColor
                target: label
            }
        }
    ]
}
