import "../../../qml" as Shared
import "../LateNightTheme"

Shared.Button {
    activeColor: LateNightTheme.textOnAccent
    activeBackgroundColor: LateNightTheme.schemeAccent
    normalBackgroundColor: LateNightTheme.surfaceLevel3
    implicitHeight: LateNightTheme.toolbarButtonHeight
    normalColor: LateNightTheme.textSecondary
    pressedColor: LateNightTheme.textOnAccent
    // Make buttons circular/rounded for DJ UI
    // Override the base button's radius:2 to be fully circular
    background: Item {
        anchors.fill: parent

        Rectangle {
            id: backgroundImage

            anchors.fill: parent
            color: root.normalBackgroundColor
            radius: Math.min(parent.width, parent.height) / 2
        }
        DropShadow {
            id: effect1

            anchors.fill: backgroundImage
            color: "#80000000"
            horizontalOffset: 0
            radius: 1.0
            source: backgroundImage
            verticalOffset: 0
        }
        InnerShadow {
            id: effect2

            anchors.fill: backgroundImage
            color: "#353535"
            horizontalOffset: 1
            radius: 1
            samples: 16
            source: effect1
            verticalOffset: 1
        }
        InnerShadow {
            anchors.fill: backgroundImage
            color: "#353535"
            horizontalOffset: -1
            radius: 1
            samples: 16
            source: effect2
            verticalOffset: -1
        }
    }
}
