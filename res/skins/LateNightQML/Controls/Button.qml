import "../../../qml" as Shared
import "../LateNightTheme"

Shared.Button {
    activeColor: LateNightTheme.textOnAccent
    activeBackgroundColor: LateNightTheme.schemeAccent
    activeBorderColor: LateNightTheme.schemeBorderFocus
    normalBackgroundColor: LateNightTheme.surfaceLevel3
    normalBorderColor: LateNightTheme.borderSubtle
    implicitHeight: LateNightTheme.toolbarButtonHeight
    normalColor: LateNightTheme.textSecondary
    pressedColor: LateNightTheme.textOnAccent
    pressedBackgroundColor: LateNightTheme.surfaceLevel5
    pressedBorderColor: LateNightTheme.schemeAccent
}
