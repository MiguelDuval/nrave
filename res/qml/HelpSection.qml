import QtQuick 2.12
import QtQuick.Controls
import "Theme"

Item {
    id: root

    property alias title: titleLabel.text
    property alias body: bodyLabel.text
    property color accent: Theme.primaryCyan

    width: parent ? parent.width : 0
    implicitHeight: sectionColumn.height + 20
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.panelGraphite
        radius: 6
        border.color: Theme.softBorder
        border.width: 1

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            color: root.accent
            radius: 2
            width: 3
        }
    }

    Column {
        id: sectionColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 6

        Text {
            id: titleLabel

            color: root.accent
            font.bold: true
            font.family: Theme.fontFamily
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Text {
            id: bodyLabel

            color: Theme.primaryText
            font.family: Theme.fontFamily
            font.pixelSize: 12
            lineHeight: 1.18
            lineHeightMode: Text.ProportionalHeight
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
}
