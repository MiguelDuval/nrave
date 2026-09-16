import QtQuick
import "../../../qml" as Skin
import "../LateNightTheme"

Skin.ControlKnob {
    id: root

    readonly property int arcRenderScale: 8
    property bool displayArc: false
    property color displayArcColor: "transparent"
    property real displayArcOffsetY: 1.998
    property real displayArcRadius: 12.5
    property int displayArcStart: 1
    property real displayArcWidth: 2
    property string indicatorColor: "accent"
    property string indicatorKind: "regular"

    angle: LateNightTheme.isClassic ? 135 : 130
    arc: false
    arcStart: displayArcStart
    color: displayArcColor
    implicitHeight: 36
    implicitWidth: 36
    knobCenterOffsetY: displayArcOffsetY
    showDefaultBackground: false
    showDefaultForeground: false

    // Replace the legacy image-based square knob with a real hardware-style
    // control: circular graphite body + restrained edge + unambiguous position marker.
    background: Item {
        anchors.fill: parent

        Rectangle {
            anchors.centerIn: parent
            color: "#15171a"
            height: Math.min(parent.width, parent.height) - 4
            radius: height / 2
            width: height
            border.color: "#32363b"
            border.width: 1

            Rectangle {
                anchors.centerIn: parent
                color: "#0b0d10"
                height: parent.height - 8
                radius: height / 2
                width: height
            }
        }
    }

    foreground: Item {
        anchors.fill: parent

        // A narrow pointer is much easier to read during performance than a
        // square white image. ControlKnob applies the value rotation to the
        // foreground item, preserving the existing value/interaction chain.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            color: root.indicatorColor === "accent" ? LateNightTheme.schemeAccent : Qt.color(root.indicatorColor)
            height: 10
            radius: width / 2
            width: 2
        }

        Rectangle {
            anchors.centerIn: parent
            color: root.indicatorColor === "accent" ? LateNightTheme.schemeAccent : Qt.color(root.indicatorColor)
            height: 3
            radius: 1.5
            width: 3
        }
    }

    Canvas {
        id: arcCanvas

        readonly property color renderedColor: root.displayArcColor
        readonly property real renderedOffsetY: root.displayArcOffsetY
        readonly property real renderedRadius: root.displayArcRadius
        readonly property int renderedStart: root.displayArcStart
        readonly property real renderedValue: root.value
        readonly property real renderedWidth: root.displayArcWidth

        antialiasing: true
        height: root.height * root.arcRenderScale
        layer.enabled: true
        layer.mipmap: true
        renderStrategy: Canvas.Immediate
        scale: 1 / root.arcRenderScale
        transformOrigin: Item.TopLeft
        visible: root.displayArc
        width: root.width * root.arcRenderScale
        z: 1

        Component.onCompleted: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (!root.displayArc) {
                return;
            }

            const renderScale = root.arcRenderScale;
            const startAngle = root.angleFrom(root.arcStartValue - root.valueCenter) - 90;
            const sweepAngle = root.angleFrom(root.value - root.arcStartValue);
            const startRadians = startAngle * Math.PI / 180;
            const endRadians = (startAngle + sweepAngle) * Math.PI / 180;

            ctx.beginPath();
            ctx.strokeStyle = root.displayArcColor;
            ctx.lineWidth = root.displayArcWidth * renderScale;
            ctx.lineCap = "round";
            ctx.arc((root.width / 2) * renderScale, (root.height / 2 + root.displayArcOffsetY) * renderScale, root.displayArcRadius * renderScale, startRadians, endRadians, sweepAngle < 0);
            ctx.stroke();
        }
        onRenderedColorChanged: requestPaint()
        onRenderedOffsetYChanged: requestPaint()
        onRenderedRadiusChanged: requestPaint()
        onRenderedStartChanged: requestPaint()
        onRenderedValueChanged: requestPaint()
        onRenderedWidthChanged: requestPaint()
        onVisibleChanged: requestPaint()
    }
}
