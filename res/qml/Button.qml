import QtQuick 2
import QtQuick.Controls 2
import "Theme"

AbstractButton {
    id: root

    property color activeColor: Theme.buttonActiveColor
    property color activeBackgroundColor: Theme.buttonActiveBackgroundColor
    property color normalBackgroundColor: Theme.buttonNormalBackgroundColor
    property bool highlight: false
    property color normalColor: Theme.buttonNormalColor
    property color pressedColor: activeColor

    implicitHeight: 26
    implicitWidth: 52

    background: Rectangle {
        id: backgroundImage

        anchors.fill: parent
        color: root.normalBackgroundColor
        radius: 4
        border.width: 1
        border.color: root.pressed
                ? Theme.buttonPressedBorderColor
                : (root.highlight || root.checked
                        ? Theme.buttonActiveBorderColor
                        : Theme.buttonBorderColor)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            radius: 0.5
            color: Qt.alpha(root.pressed ? Theme.buttonPressedBorderColor
                                         : (root.highlight || root.checked
                                                 ? Theme.buttonActiveBorderColor
                                                 : Theme.buttonBorderColor), 0.42)
        }
    }
    contentItem: Item {
        anchors.fill: parent

        Glow {
            id: labelGlow

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
            visible: icon.source != null
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
            PropertyChanges {
                target: labelGlow
                visible: true
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
            PropertyChanges {
                target: labelGlow
                visible: true
            }
        },
        State {
            name: "inactive"
            when: !root.checked && !root.highlight && !root.pressed

            PropertyChanges {
                color: root.normalColor
                target: label
            }
            PropertyChanges {
                target: labelGlow
                visible: false
            }
        }
    ]
}
