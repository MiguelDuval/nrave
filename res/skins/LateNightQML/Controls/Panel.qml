import QtQuick
import "../LateNightTheme"

Rectangle {
    id: root

    property bool borderVisible: true
    property color topBorderColor: LateNightTheme.borderHairline
    property color leftBorderColor: LateNightTheme.borderSubtle
    property color bottomBorderColor: LateNightTheme.borderHairline
    property color rightBorderColor: LateNightTheme.borderSubtle

    color: LateNightTheme.surfaceLevel1
    radius: LateNightTheme.radiusSmall

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: root.topBorderColor
        visible: root.borderVisible
        z: 1000
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.leftBorderColor
        visible: root.borderVisible
        z: 1000
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: root.bottomBorderColor
        visible: root.borderVisible
        z: 1000
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.rightBorderColor
        visible: root.borderVisible
        z: 1000
    }
}
