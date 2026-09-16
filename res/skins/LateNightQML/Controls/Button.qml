import "../../../qml" as Shared
import "../LateNightTheme"

Shared.Button {
    activeColor: LateNightTheme.textOnAccent
    activeBackgroundColor: LateNightTheme.schemeAccent
    normalBackgroundColor: LateNightTheme.surfaceLevel3
    implicitHeight: LateNightTheme.toolbarButtonHeight
    normalColor: LateNightTheme.textSecondary
    pressedColor: LateNightTheme.textOnAccent
}
