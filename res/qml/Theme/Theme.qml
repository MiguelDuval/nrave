pragma Singleton
import QtQuick 2.12

QtObject {
    // ============================================================
    // NRave PHOTON GRID -- Theme
    // ============================================================
    // Futuristic professional DJ hardware visual palette
    // Dark graphite structure, cyan transport core, violet creative energy
    // ============================================================

    // --- Structure ---
    property color nearBlack: "#070B10"
    property color deepGraphite: "#0A0F16"
    property color panelGraphite: "#111821"
    property color elevatedGraphite: "#18212B"
    property color coolGraphiteBlue: "#1C2631"
    property color softBorder: "#263442"
    property color strongBorder: "#3D5264"
    property color coolDarkBlue: "#1C2833"

    // --- Accents ---
    property color primaryCyan: "#10D9E8"
    property color brightCyan: "#65F4FF"
    property color deepCyan: "#078EA9"
    property color primaryViolet: "#B94CFF"
    property color brightViolet: "#D96BFF"
    property color deepViolet: "#7658C9"

    // --- Semantics ---
    property color amber: "#FFC857"
    property color green: "#42E6A4"
    property color red: "#FF5364"
    property color white: "#F4F8FC"
    property color primaryText: "#D8E2EC"
    property color mutedText: "#7D8C9A"
    property color technicalLabel: "#8FA3B8"

    // --- Legacy aliases (backward compatibility) ---
    property color accentColor: primaryCyan
    property color backgroundColor: nearBlack
    property color blue: primaryCyan
    property color bpmSliderBarColor: primaryCyan
    property color buttonActiveColor: white
    property color buttonDisableColor: mutedText
    property int buttonFontPixelSize: 10
    property color buttonNormalColor: primaryText
    property color crossfaderBarColor: primaryCyan
    property color crossfaderOrientationColor: mutedText
    property color darkGray: deepGraphite
    property color darkGray2: panelGraphite
    property color darkGray3: elevatedGraphite
    property color darkGray4: nearBlack
    property color deckActiveColor: white
    property color deckBackgroundColor: deepGraphite
    property color deckBeatjumpBackgroundColor: panelGraphite
    property color deckBeatjumpLabelColor: mutedText
    property color deckEmptyCoverArt: panelGraphite
    property color deckInfoBarBackgroundColor: '#0A1018'
    property color deckLineColor: softBorder
    property color deckLoopBackgroundColor: panelGraphite
    property color deckLoopLabelColor: mutedText
    property color deckTextColor: primaryText
    property color effectColor: primaryViolet
    property color effectUnitColor: red
    property color embeddedBackgroundColor: "#B00A1018"
    property color eqFxColor: red
    property color eqHighColor: white
    property color eqLowColor: white
    property color eqMidColor: white
    property string fontFamily: "Open Sans"
    property color gainKnobColor: primaryCyan
    property color green: green
    property string imgBpmSliderBackground: "images/slider_bpm.svg"
    property string imgButton: "images/button.svg"
    property string imgButtonPressed: "images/button_pressed.svg"
    property string imgCrossfaderBackground: "images/slider_crossfader.svg"
    property string imgCrossfaderHandle: "images/slider_handle_crossfader.svg"
    property string imgKnob: "images/knob.svg"
    property string imgKnobMini: "images/miniknob.svg"
    property string imgKnobMiniShadow: "images/miniknob_shadow.svg"
    property string imgKnobShadow: "images/knob_shadow.svg"
    property string imgMicDuckingSlider: "images/slider_micducking.svg"
    property string imgMicDuckingSliderHandle: "images/slider_handle_micducking.svg"
    property string imgPopupBackground: imgButton
    property string imgSectionBackground: "images/section.svg"
    property string imgSliderHandle: "images/slider_handle.svg"
    property string imgVolumeSliderBackground: "images/slider_volume.svg"
    property color knobBackgroundColor: panelGraphite
    property color libraryPanelSplitterBackground: deepGraphite
    property color libraryPanelSplitterHandle: strongBorder
    property color libraryPanelSplitterHandleActive: primaryCyan
    property color lightGray: mutedText
    property color lightGray2: primaryText
    property color lightGray3: technicalLabel
    property color midGray: strongBorder
    property color midGray2: softBorder
    property color midGray3: panelGraphite
    property color panelSplitterBackground: nearBlack
    property color panelSplitterHandle: strongBorder
    property color panelSplitterHandleActive: primaryCyan
    property color pflActiveButtonColor: primaryCyan
    property color red: red
    property color samplerColor: primaryViolet
    property color sunkenBackgroundColor: nearBlack
    property color textColor: primaryText
    property int textFontPixelSize: 14
    property color toolbarActiveColor: white
    property color toolbarBackgroundColor: deepGraphite
    property color buttonNormalBackgroundColor: panelGraphite
    property color buttonActiveBackgroundColor: primaryCyan
    property color buttonBorderColor: softBorder
    property color buttonActiveBorderColor: primaryCyan
    property color buttonPressedBorderColor: white
    property color buttonControlNormalBackgroundColor: elevatedGraphite
    property color volumeSliderBarColor: primaryCyan
    property color warningColor: red
    property color waveformBeatColor: white
    property color waveformCursorColor: white
    property color waveformMarkerDefault: amber
    property color waveformMarkerIntroOutroColor: primaryCyan
    property color waveformMarkerLabel: Qt.rgba(255, 255, 255, 0.8)
    property color waveformMarkerLoopColor: green
    property color waveformMarkerLoopColorDisabled: white
    property color waveformPostrollColor: midGray
    property color waveformPrerollColor: midGray
    property color white: white
    property color yellow: amber
}
