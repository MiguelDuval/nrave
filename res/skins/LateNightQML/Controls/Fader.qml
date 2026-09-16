import QtQuick
import "../../../qml" as Skin
import "../LateNightTheme"

Skin.ControlFader {
    id: root

    property int backgroundMargin: 0
    property alias backgroundSource: backgroundImage.source
    property real handleHeight: 0
    property alias handleSource: handleImage.source
    property real handleWidth: 0
    property color valueLineColor: LateNightTheme.schemeAccent

    bar.color: valueLineColor
    bar.enabled: true
    bar.margin: LateNightTheme.spacingS
    bar.width: 2
    implicitHeight: backgroundImage.implicitHeight + (backgroundMargin * 2)
    implicitWidth: backgroundImage.implicitWidth + (backgroundMargin * 2)
    showDefaultHandle: false

    background: Image {
        id: backgroundImage

        anchors.fill: parent
        anchors.margins: root.backgroundMargin
        fillMode: Image.PreserveAspectFit
    }

    // Keep the public handleSource API intact, but always render a clearly
    // visible hardware-style position cap so the current value is readable.
    handle: Item {
        id: handleRoot

        property real resolvedHeight: root.handleHeight > 0 ? root.handleHeight : (root.horizontal ? 18 : 42)
        property real resolvedWidth: root.handleWidth > 0 ? root.handleWidth : (root.horizontal ? 42 : 18)

        height: resolvedHeight
        width: resolvedWidth
        x: root.horizontal ? Math.round(root.visualPosition * (root.width - width)) : Math.round((root.width - width) / 2)
        y: root.vertical ? Math.round(root.visualPosition * (root.height - height)) : Math.round((root.height - height) / 2)

        Image {
            id: handleImage

            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            opacity: source && source.toString().length > 0 ? 0.18 : 0
        }

        Rectangle {
            anchors.fill: parent
            color: "#16191d"
            radius: 3
            border.color: "#3a4047"
            border.width: 1
        }

        Rectangle {
            anchors.centerIn: parent
            color: valueLineColor
            radius: 1
            height: root.horizontal ? 2 : Math.max(10, parent.height - 10)
            width: root.horizontal ? Math.max(10, parent.width - 10) : 2
        }

        Rectangle {
            anchors.centerIn: parent
            color: "#eef1f3"
            radius: 1
            height: root.horizontal ? 1 : Math.max(8, parent.height - 16)
            width: root.horizontal ? Math.max(8, parent.width - 16) : 1
            opacity: 0.82
        }
    }
}
