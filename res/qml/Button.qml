import QtQuick 2
import QtQuick.Controls 2
import "Theme"

AbstractButton {
    id: root

    property color activeColor: Theme.primaryCyan
    property color activeBackgroundColor: Theme.panelGraphite
    property color normalBackgroundColor: Theme.deepGraphite
    property color pressedBackgroundColor: Theme.strongBorder
    property bool highlight: false
    property color normalColor: Theme.primaryText
    property color pressedColor: Theme.brightCyan
    property int cornerRadius: 2
    property int borderWidth: 1

    implicitHeight: 30
    implicitWidth: 56

    background: Rectangle {
        id: backgroundImage
        anchors.fill: parent
        color: root.normalBackgroundColor
        radius: root.cornerRadius
        border.color: root.highlight || root.checked ? Theme.primaryCyan : Theme.softBorder
        border.width: root.highlight || root.checked ? 2 : root.borderWidth
    }
    contentItem: Item {
        anchors.fill: parent

        Label {
            id: label
            anchors.fill: parent
            color: root.highlight || root.checked ? Theme.backgroundColor : root.normalColor
            font.bold: true
            font.capitalization: Font.AllUppercase
            font.family: Theme.fontFamily
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            text: root.text
            verticalAlignment: Text.AlignVCenter
            visible: root.text != null && root.text !== ""
        }
        Image {
            id: image
            anchors.centerIn: parent
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            height: icon.height
            source: icon.source
            visible: icon.source != null && icon.source !== ""
            width: icon.width
            opacity: root.enabled ? 1.0 : 0.5
        }
    }
    states: [
        State {
            name: "pressed"
            when: root.pressed

            PropertyChanges {
                color: root.pressedBackgroundColor
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
                color: Theme.backgroundColor
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
