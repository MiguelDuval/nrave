pragma Singleton
import QtQuick 2.12

QtObject {
    // Design Token System (Graphite/Charcoal) - Phase 1
    // Surface Levels (tonal depth hierarchy)
    property color surfaceLevel0: "#080808"        // Background (deepest)
    property color surfaceLevel1: "#0e0e0e"        // Main panels
    property color surfaceLevel2: "#121212"        // Elevated panels
    property color surfaceLevel3: "#1a1a1a"        // Interactive surfaces (buttons, controls)
    property color surfaceLevel4: "#222222"        // Hover/touch feedback
    property color surfaceLevel5: "#2a2a2a"        // Pressed/active state
    property color surfaceFocus: "#1e3a5f"         // Focus ring (accent-tinted)

    // Semantic Status Colors
    property color statusCritical: "#db0000"       // Playing cue, warning, errors
    property color statusWarning: "#d89124"        // Sync issues, quantize off
    property color statusSuccess: "#54c76a"        // Connected, locked, ready
    property color statusInfo: "#3a60be"           // Info, accent

    // Waveform-Specific
    property color waveformBgPrimary: "#0a0a0a"
    property color waveformBgSecondary: "#001218"
    property color waveformPlayhead: "#00c8ff"
    property color waveformCue: "#ff001c"
    property color waveformLoop: "#00e600"
    property color waveformBeatgrid: "#ffffff33"

    // Text Hierarchy
    property color textPrimary: "#e8e8e8"
    property color textSecondary: "#b0b0b0"
    property color textTertiary: "#888888"
    property color textMuted: "#555555"
    property color textOnAccent: "#ffffff"

    // Border System
    property color borderHairline: "#000000"
    property color borderSubtle: "#1a1a1a"
    property color borderEmphasis: "#2a2a2a"
    property color borderFocus: "#3a60be"

    // Spacing Scale
    property int spacingXS: 2
    property int spacingS: 4
    property int spacingM: 8
    property int spacingL: 12
    property int spacingXL: 16

    // Border Radius
    property int radiusSmall: 2
    property int radiusMedium: 4
    property int radiusLarge: 8

    // Control Heights
    property int controlHeightSmall: 24
    property int controlHeightMedium: 32
    property int controlHeightLarge: 44

    // Typography
    property string fontFamily: "Open Sans"
    property int fontSizeDisplay: 20
    property int fontSizeTitle: 16
    property int fontSizeBody: 14
    property int fontSizeCaption: 11
    property int fontSizeTiny: 9
    property int buttonFontPixelSize: 10

    // Legacy compatibility mappings
    property color accentColor: "#3a60be"
    property color backgroundColor: surfaceLevel0
    property color blue: "#01dcfc"
    property color bpmSliderBarColor: blue
    property color buttonActiveColor: textOnAccent
    property color buttonDisableColor: textMuted
    property color buttonNormalColor: textTertiary
    property color crossfaderBarColor: blue
    property color crossfaderOrientationColor: textSecondary
    property color darkGray: surfaceLevel1
    property color darkGray2: surfaceLevel2
    property color darkGray3: surfaceLevel3
    property color darkGray4: surfaceLevel4
    property color deckActiveColor: textOnAccent
    property color deckBackgroundColor: surfaceLevel1
    property color deckBeatjumpBackgroundColor: surfaceLevel3
    property color deckBeatjumpLabelColor: surfaceLevel3
    property color deckEmptyCoverArt: surfaceLevel3
    property color deckInfoBarBackgroundColor: surfaceLevel1
    property color deckLineColor: borderSubtle
    property color deckLoopBackgroundColor: surfaceLevel3
    property color deckLoopLabelColor: surfaceLevel3
    property color deckTextColor: textSecondary
    property color effectColor: statusWarning
    property color effectUnitColor: statusCritical
    property color embeddedBackgroundColor: "#a0000000"
    property color eqFxColor: statusCritical
    property color eqHighColor: textPrimary
    property color eqLowColor: textPrimary
    property color eqMidColor: textPrimary
    property color gainKnobColor: statusInfo
    property color libraryPanelSplitterBackground: surfaceLevel1
    property color libraryPanelSplitterHandle: textTertiary
    property color libraryPanelSplitterHandleActive: textSecondary
    property color lightGray: textTertiary
    property color lightGray2: textSecondary
    property color lightGray3: textTertiary
    property color midGray: textTertiary
    property color midGray2: textTertiary
    property color midGray3: surfaceLevel3
    property color panelSplitterBackground: surfaceLevel0
    property color panelSplitterHandle: textTertiary
    property color panelSplitterHandleActive: textSecondary
    property color pflActiveButtonColor: statusInfo
    property color red: statusCritical
    property color samplerColor: statusInfo
    property color sunkenBackgroundColor: borderHairline
    property color textColor: textSecondary
    property int textFontPixelSize: 14
    property color toolbarActiveColor: textOnAccent
    property color toolbarBackgroundColor: surfaceLevel1
    property color volumeSliderBarColor: blue
    property color warningColor: statusWarning
    property color waveformBeatColor: textTertiary
    property color waveformCursorColor: textOnAccent
    property color waveformMarkerDefault: waveformCue
    property color waveformMarkerIntroOutroColor: statusInfo
    property color waveformMarkerLabel: Qt.rgba(255, 255, 255, 0.8)
    property color waveformMarkerLoopColor: waveformLoop
    property color waveformMarkerLoopColorDisabled: "#FFFFFF"
    property color waveformPostrollColor: textTertiary
    property color waveformPrerollColor: textTertiary
    property color white: textPrimary
    property color yellow: statusWarning
}
