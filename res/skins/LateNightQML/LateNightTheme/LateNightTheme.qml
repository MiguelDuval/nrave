pragma Singleton
import QtQuick
import "."

QtObject {
    readonly property color accentColor: "#10D9E8"
    readonly property color activePlayCueColor: "#10D9E8"
    readonly property url assetDeckArrowLeftUpButton: lateNightAsset("buttons", "btn__arrow_left_up.svg")
    readonly property url assetDeckArrowRightDownButton: lateNightAsset("buttons", "btn__arrow_right_down.svg")
    readonly property url assetDeckBeatCurposButton: lateNightAsset("buttons", "btn__beat_curpos.svg")
    readonly property url assetDeckBeatCurposLargeButton: lateNightAsset("buttons", "btn__beat_curpos_large.svg")
    readonly property url assetDeckBeatgridButton: lateNightAsset("buttons", "btn__beatgrid.svg")
    readonly property url assetDeckBeatSpinBoxBorder: isClassic ? lateNightAsset("buttons", "spinbox_elevated_border.svg") : lateNightSubRegionButton("wide")
    readonly property url assetDeckBeatSpinBoxDownButton: isClassic ? lateNightAsset("buttons", "spinbox_down.svg") : lateNightAsset("buttons", "btn__spinbox_down.svg")
    readonly property url assetDeckBeatSpinBoxUpButton: isClassic ? lateNightAsset("buttons", "spinbox_up.svg") : lateNightAsset("buttons", "btn__spinbox_up.svg")
    readonly property url assetDeckBeatjumpLeftButton: lateNightAsset("buttons", "btn__beatjump_left.svg")
    readonly property url assetDeckBeatjumpRightButton: lateNightAsset("buttons", "btn__beatjump_right.svg")
    readonly property url assetDeckBeatsEarlierButton: lateNightAsset("buttons", "btn__beats_earlier.svg")
    readonly property url assetDeckBeatsFasterButton: lateNightAsset("buttons", "btn__beats_faster.svg")
    readonly property url assetDeckBeatsHotcuesEarlierButton: lateNightAsset("buttons", "btn__beats_hotcues_earlier.svg")
    readonly property url assetDeckBeatsHotcuesLaterButton: lateNightAsset("buttons", "btn__beats_hotcues_later.svg")
    readonly property url assetDeckBeatsLaterButton: lateNightAsset("buttons", "btn__beats_later.svg")
    readonly property url assetDeckBeatsSlowerButton: lateNightAsset("buttons", "btn__beats_slower.svg")
    readonly property url assetDeckBpmLockedButton: lateNightAsset("buttons", "btn__bpm_locked.svg")
    readonly property url assetDeckBpmSelectEditButton: lateNightAsset("buttons", "btn__bpm_select_edit.svg")
    readonly property url assetDeckBpmSelectTapButton: lateNightAsset("buttons", "btn__bpm_select_tap.svg")
    readonly property url assetDeckBpmSpinboxMinusButton: lateNightAsset("buttons", "btn__bpm_spinbox_minus.svg")
    readonly property url assetDeckBpmSpinboxMinusPressedButton: lateNightAsset("buttons", isClassic ? "btn__bpm_spinbox_minus_pressed.svg" : "btn__bpm_spinbox_minus.svg")
    readonly property url assetDeckBpmSpinboxPlusButton: lateNightAsset("buttons", "btn__bpm_spinbox_plus.svg")
    readonly property url assetDeckBpmSpinboxPlusPressedButton: lateNightAsset("buttons", isClassic ? "btn__bpm_spinbox_plus_pressed.svg" : "btn__bpm_spinbox_plus.svg")
    readonly property url assetDeckBpmUnlockedButton: lateNightAsset("buttons", "btn__bpm_unlocked.svg")
    readonly property url assetDeckCoverDefault: lateNightAsset("style", "cover_default.svg")
    readonly property url assetDeckCueButton: lateNightAsset("buttons", "btn__cue_deck.svg")
    readonly property url assetDeckEjectButton: lateNightAsset("buttons", "btn__eject.svg")
    readonly property url assetDeckIntroEndButton: lateNightAsset("buttons", "btn__intro_end.svg")
    readonly property url assetDeckIntroStartButton: lateNightAsset("buttons", "btn__intro_start.svg")
    readonly property url assetDeckKeyButtonBackground: lateNightAsset("buttons", "btn_embedded_library.svg")
    readonly property url assetDeckKeyDownButton: lateNightAsset("buttons", "btn__key_down.svg")
    readonly property url assetDeckKeyMatchButton: lateNightAsset("buttons", "btn__key_match.svg")
    readonly property url assetDeckKeyUpButton: lateNightAsset("buttons", "btn__key_up.svg")
    readonly property url assetDeckKeylockButton: lateNightAsset("buttons", "btn__keylock.svg")
    readonly property url assetDeckLeaderBackground: lateNightAsset("buttons", "btn_embedded_grid.svg")
    readonly property url assetDeckLeaderButton: lateNightAsset("buttons", "btn__sync_leader.svg")
    readonly property url assetDeckLeaderExplicitButton: isPaleMoon ? lateNightAsset("buttons", "btn__sync_leader_explicit.svg") : lateNightAsset("buttons", "btn__sync_leader_active.svg")
    readonly property url assetDeckLeaderImplicitButton: isPaleMoon ? lateNightAsset("buttons", "btn__sync_leader_implicit.svg") : lateNightAsset("buttons", "btn__sync_leader_active.svg")
    readonly property url assetDeckLoopAnchorEndButton: lateNightAsset("buttons", "btn__loop_anchor_end.svg")
    readonly property url assetDeckLoopAnchorStartButton: lateNightAsset("buttons", "btn__loop_anchor_start.svg")
    readonly property url assetDeckLoopButton: lateNightAsset("buttons", "btn__loop.svg")
    readonly property url assetDeckLoopInButton: lateNightAsset("buttons", "btn__loop_in.svg")
    readonly property url assetDeckLoopOutButton: lateNightAsset("buttons", "btn__loop_out.svg")
    readonly property url assetDeckMinusButton: lateNightAsset("buttons", "btn__minus.svg")
    readonly property url assetDeckOutroEndButton: lateNightAsset("buttons", "btn__outro_end.svg")
    readonly property url assetDeckOutroStartButton: lateNightAsset("buttons", "btn__outro_start.svg")
    readonly property url assetDeckPlayButton: lateNightAsset("buttons", "btn__play_deck.svg")
    readonly property url assetDeckPlusButton: lateNightAsset("buttons", "btn__plus.svg")
    readonly property url assetDeckQuantizeButton: lateNightAsset("buttons", "btn__quantize.svg")
    readonly property url assetDeckRateSliderBackground: lateNightAsset("sliders", "slider_pitch_deck.svg")
    readonly property url assetDeckRateSliderHandle: lateNightAsset("sliders", "knob_pitch_deck.svg")
    readonly property url assetDeckReloopButton: lateNightAsset("buttons", "btn__reloop.svg")
    readonly property url assetDeckRepeatButton: lateNightAsset("buttons", "btn__repeat.svg")
    readonly property url assetDeckReverseButton: lateNightAsset("buttons", "btn__reverse.svg")
    readonly property url assetDeckSettingsOffButton: lateNightAsset("buttons", "btn__settings_off.svg")
    readonly property url assetDeckSettingsOnButton: lateNightAsset("buttons", "btn__settings_on.svg")
    readonly property url assetDeckSlipButton: lateNightAsset("buttons", "btn__slip.svg")
    readonly property url assetDeckSpinnyBackground: lateNightAsset("style", "spinny_bg.svg")
    readonly property url assetDeckSpinnyGhostIndicator: lateNightAsset("style", "spinny_indicator_ghost.svg")
    readonly property url assetDeckSpinnyIndicator: lateNightAsset("style", "spinny_indicator.svg")
    readonly property url assetDeckSpinnyMask12: lateNightAsset("style", "spinny_mask_12.svg")
    readonly property url assetDeckSpinnyMask34: lateNightAsset("style", "spinny_mask_34.svg")
    readonly property url assetDeckSyncActiveButton: isPaleMoon ? lateNightAsset("buttons", "btn__sync_deck_active.svg") : lateNightAsset("buttons", "btn__sync_deck.svg")
    readonly property url assetDeckSyncBackground: lateNightAsset("buttons", "btn_embedded_library.svg")
    readonly property url assetDeckSyncButton: lateNightAsset("buttons", "btn__sync_deck.svg")
    readonly property url assetDeckUndoButton: lateNightAsset("buttons", "btn__undo.svg")
    readonly property url assetDeckVinylControl0: lateNightAsset("style", "vinyl_control_0.svg")
    readonly property url assetDeckVinylControl1: lateNightAsset("style", "vinyl_control_1.svg")
    readonly property url assetDeckVinylControl2: lateNightAsset("style", "vinyl_control_2.svg")
    readonly property url assetDeckVinylControl3: lateNightAsset("style", "vinyl_control_3.svg")
    readonly property url assetDeckVolumeSliderBackground: lateNightAsset("sliders", "slider_volume_deck.svg")
    readonly property url assetDeckVolumeSliderHandle: lateNightAsset("sliders", "knob_volume_deck.svg")
    readonly property url assetFxCollapseButton: lateNightAsset("buttons", isClassic ? "btn__collapse.svg" : "btn__collapse_dim.svg")
    readonly property url assetFxExpandButton: lateNightAsset("buttons", isClassic ? "btn__expand.svg" : "btn__expand_dim.svg")
    readonly property url assetFxFlowHorizontal: lateNightAsset("style", isClassic ? "fx_separator.svg" : "fx_flow_horizontal.svg")
    readonly property url assetFxFlowVertical: lateNightAsset("style", isClassic ? "fx_separator.svg" : "fx_flow_vertical.svg")
    readonly property url assetFxFocusActiveButton: lateNightAsset("buttons", "btn__fx_focus_active.svg")
    readonly property url assetFxFocusButton: lateNightAsset("buttons", "btn__fx_focus.svg")
    readonly property url assetFxKnobBackground: lateNightAsset("knobs", "knob_bg_fx.svg")
    readonly property url assetFxMixModeButton: lateNightAsset("buttons", "btn_embedded_mixmode.svg")
    readonly property url assetFxMixModeDryWetButton: lateNightAsset("buttons", "btn__fx_mixmode_d-w.svg")
    readonly property url assetFxMixModeDryWetSumButton: lateNightAsset("buttons", "btn__fx_mixmode_d+w.svg")
    readonly property url assetFxParameterActiveButton: lateNightAsset("buttons", "btn_embedded_fx_parameter_active.svg")
    readonly property url assetFxParameterButton: lateNightAsset("buttons", "btn_embedded_fx_parameter.svg")
    readonly property url assetFxSelectorActiveBorder: lateNightAsset("buttons", "btn_embedded_library_active.svg")
    readonly property url assetFxSelectorBorder: lateNightAsset("buttons", "btn_embedded_library.svg")
    readonly property url assetFxSelectorDownButton: lateNightAsset("buttons", "btn__fx_selector_down.svg")
    readonly property url assetFxSettingsButton: lateNightAsset("buttons", "btn__fx_settings.svg")
    readonly property url assetFxSlotButtonActiveBackground: lateNightAsset("buttons", "btn_embedded_square_active.svg")
    readonly property url assetFxSlotButtonBackground: lateNightAsset("buttons", "btn_embedded_square.svg")
    readonly property url assetFxToggleActiveButton: lateNightAsset("buttons", "btn__fx_toggle_active.svg")
    readonly property url assetFxToggleButton: lateNightAsset("buttons", "btn__fx_toggle.svg")
    readonly property url assetMainKnobBackground: lateNightAsset("knobs", "knob_bg_main.svg")
    readonly property url assetMixerCrossfaderBackground: lateNightAsset("sliders", "slider_crossfader.svg")
    readonly property url assetMixerCrossfaderHandle: lateNightAsset("sliders", "knob_crossfader.svg")
    readonly property url assetMixerCrossfaderSmallBackground: lateNightAsset("sliders", "slider_crossfader_small.svg")
    readonly property url assetMixerEqKillButtonActiveBackground: lateNightAsset("buttons", "btn_embedded_eqkill_active.svg")
    readonly property url assetMixerEqKillButtonBackground: lateNightAsset("buttons", "btn_embedded_eqkill.svg")
    readonly property url assetMixerEqKillHighIcon: lateNightAsset("buttons", "btn__eq_kill_high.svg")
    readonly property url assetMixerEqKillLowIcon: lateNightAsset("buttons", "btn__eq_kill_low.svg")
    readonly property url assetMixerEqKillMidIcon: lateNightAsset("buttons", "btn__eq_kill_mid.svg")
    readonly property url assetMixerPflActiveIcon: isPaleMoon ? lateNightAsset("buttons", "btn__pfl_active.svg") : lateNightAsset("buttons", "btn__pfl.svg")
    readonly property url assetMixerPflBackground: lateNightTopRegionButton("square")
    readonly property url assetMixerPflIcon: lateNightAsset("buttons", "btn__pfl.svg")
    readonly property url assetMixerQuickEffectIcon: lateNightAsset("buttons", "btn__star.svg")
    readonly property url assetMixerSplitActiveIcon: lateNightAsset("buttons", isClassic ? "btn_elevated_headsplit_active.svg" : "btn_embedded_headsplit_active.svg")
    readonly property url assetMixerSplitIcon: lateNightAsset("buttons", isClassic ? "btn_elevated_headsplit.svg" : "btn_embedded_headsplit.svg")
    readonly property url assetMixerVolumeSliderBackground: lateNightAsset("sliders", "slider_volume_deck.svg")
    readonly property url assetMixerVolumeSliderHandle: lateNightAsset("sliders", "knob_volume_deck.svg")
    readonly property url assetRegularKnobBackground: lateNightAsset("knobs", "knob_bg_regular.svg")
    readonly property url assetSamplerCollapseButton: lateNightAsset("buttons", "btn__collapse_dim.svg")
    readonly property url assetSamplerExpandButton: lateNightAsset("buttons", "btn__expand_dim.svg")
    readonly property url assetSamplerPauseButton: lateNightAsset("buttons", "btn__pause_sampler.svg")
    readonly property url assetSamplerPitchSliderBackground: lateNightAsset("sliders", "slider_pitch_sampler.svg")
    readonly property url assetSamplerPitchSliderHandle: lateNightAsset("sliders", "knob_pitch_sampler.svg")
    readonly property url assetSamplerPlayButton: lateNightAsset("buttons", "btn__play_sampler.svg")
    readonly property url assetSamplerSyncButton: lateNightAsset("buttons", "btn__sync_sampler.svg")
    readonly property url assetSamplerVuClippingActive: lateNightAsset("style", "vu_sampler_clipping_active.png")
    readonly property url assetSamplerVuClippingBackground: lateNightAsset("style", "vu_sampler_clipping_bg_.png")
    readonly property url assetSamplerVuLevelActive: lateNightAsset("style", "vu_sampler_level_active.png")
    readonly property url assetSamplerVuLevelBackground: lateNightAsset("style", "vu_sampler_level_bg_.png")
    readonly property url assetSamplerXfaderLeft: lateNightAsset("buttons", "btn__xfader_sampler_left.svg")
    readonly property url assetSamplerXfaderMain: lateNightAsset("buttons", "btn__xfader_sampler_main.svg")
    readonly property url assetSamplerXfaderRight: lateNightAsset("buttons", "btn__xfader_sampler_right.svg")
    readonly property url assetSmallKnobBackground: lateNightAsset("knobs", "knob_bg_small.svg")
    readonly property url assetToolbarDropdownIcon: lateNightAsset("buttons", "btn__fx_selector_down.svg")
    readonly property url assetToolbarMenuIcon: lateNightAsset("buttons", "btn__menu.svg")
    readonly property color backgroundColor: "#06080D"
    readonly property color beatgridDisabledCoverColor: "#B406080D"
    readonly property color bpmTapEditorBackgroundColor: "#0A0F16"
    readonly property color bpmTapEditorButtonColor: "#111821"
    readonly property color bpmTapEditorEditBorderColor: "#10D9E8"
    readonly property color bpmTapEditorSelectBackgroundColor: "#18212B"
    readonly property color bpmTapEditorSelectBorderColor: "#B94CFF"
    readonly property color buttonActiveColor: "#F4F8FC"
    readonly property color buttonNormalColor: "#D8E2EC"
    readonly property color buttonPressedColor: "#65F4FF"
    readonly property color darkGray: "#0A0F16"
    readonly property color deckActiveButtonTextColor: "#06080D"
    readonly property color deckBeatSpinBoxTextColor: "#D8E2EC"
    readonly property color deckButtonInactiveColor: "#1A222D"
    readonly property color deckDimButtonInactiveColor: "#2A3A4A"
    readonly property color deckEmbeddedButtonInactiveColor: "#1A222D"
    readonly property color deckPanelBorderDark: "#1A222D"
    readonly property color deckPanelBorderLeft: "#263442"
    readonly property color deckPanelBorderLight: "#3D5264"
    readonly property color deckPanelBorderRight: "#1A222D"
    readonly property color deckPanelColor: "#111821"
    readonly property color deckReadonlyTextColor: "#7D8C9A"
    readonly property color deckTimeTextColor: "#F4F8FC"
    readonly property color deckTopRowBackgroundColor: "#0A0F16"
    readonly property color effectsAssignmentActiveTextColor: "#06080D"
    readonly property color effectsAssignmentInactiveColor: "#1A222D"
    readonly property color effectsAssignmentInactiveTextColor: "#7D8C9A"
    readonly property color effectsControlActiveColor: "#65F4FF"
    readonly property color effectsControlInactiveColor: "#1A222D"
    readonly property color effectsControllerColor12: "#42E6A4"
    readonly property color effectsControllerColor34: "#10D9E8"
    readonly property color effectsFillerColor: "#1A222D"
    readonly property color effectsFocusBorderColor: "#10D9E8"
    readonly property color effectsHeaderColor: "#1A222D"
    readonly property color effectsMasterButtonInactiveColor: "#1A222D"
    readonly property color effectsPanelColor: "#1A222D"
    readonly property color effectsParameterActiveColor: "#65F4FF"
    readonly property color effectsParameterArcColor: "#3D5264"
    readonly property color effectsParameterInactiveColor: "#2A3A4A"
    readonly property string effectsParameterIndicatorColor: "grey"
    readonly property color effectsParameterInverseActiveColor: "#FF5364"
    readonly property color effectsParameterLinkInactiveColor: "#2A3A4A"
    readonly property color effectsParameterPanelColor: "#1A222D"
    readonly property color effectsParameterTextColor: "#7D8C9A"
    readonly property color effectsRackGutterColor: "#06080D"
    readonly property color effectsSlotToggleInactiveColor: "#1A222D"
    readonly property color effectsUnitColor12: "#42E6A4"
    readonly property color effectsUnitColor34: "#10D9E8"
    readonly property color effectsUnitDimColor12: "#2A6B4D"
    readonly property color effectsUnitDimColor34: "#006B7A"
    readonly property bool isClassic: ColorScheme.name === "classic"
    readonly property bool isPaleMoon: ColorScheme.name === "palemoon"
    readonly property color keyControlsPressedColor: "#B94CFF"
    readonly property string keyControlsPressedIconSuffix: ""
    readonly property color libraryPanelSplitterBackground: "#0A0F16"
    readonly property color libraryPanelSplitterHandle: "#3D5264"
    readonly property color libraryPanelSplitterHandleActive: "#10D9E8"
    readonly property color mixerAccentCyan: "#10D9E8"
    readonly property color mixerAccentOrange: "#FFC857"
    readonly property color mixerAccentRed: "#FF5364"
    readonly property color mixerArcEqColor: "#7D8C9A"
    readonly property color mixerArcGainColor: "#FFC857"
    readonly property color mixerArcGainLowColor: "#B94CFF"
    readonly property color mixerArcMainBalanceColor: "#FF5364"
    readonly property color mixerArcQuickEffectColor: "#42E6A4"
    readonly property real mixerArcRadiusBig: 14.5
    readonly property real mixerArcRadiusCompact: 12.5
    readonly property real mixerArcWidth: 2
    readonly property color mixerControlTextColor: "#D8E2EC"
    readonly property color mixerDimTextColor: "#7D8C9A"
    readonly property color mixerEqKillActiveColor: "#FF5364"
    readonly property color mixerFxAssignInactiveColor: "#1A222D"
    readonly property color mixerFxAssignInactiveTextColor: "#7D8C9A"
    readonly property color mixerMainSeparatorDarkColor: "#1A222D"
    readonly property color mixerMainSeparatorLightColor: "#3D5264"
    readonly property color mixerSplitActiveColor: "#10D9E8"
    readonly property color mixerSplitInactiveColor: "#1A222D"
    readonly property color mixerPanelBorderBottom: "#1A222D"
    readonly property color mixerPanelBorderDark: "#1A222D"
    readonly property color mixerPanelBorderLeft: "#3D5264"
    readonly property color mixerPanelBorderLight: "#10D9E8"
    readonly property color mixerPanelBorderRight: "#1A222D"
    readonly property color mixerPanelBorderTop: "#3D5264"
    readonly property color mixerPanelColor: "#0A0F16"
    readonly property color mixerPflActiveFillColor: "#FF5364"
    readonly property color mixerQuickEffectActiveColor: "#42E6A4"
    readonly property color mixerQuickEffectSelectorTextColor: "#8FA3B8"
    readonly property color mixerSliderBarColor: "#10D9E8"
    readonly property color mixerVuClipColor: "#FF5364"
    readonly property color mixerVuLevelColor: "#FF5364"
    readonly property url optionalDeckControlsBackgroundTile: isClassic ? lateNightAsset("style", "background_tile.png") : ""
    readonly property url optionalDeckRateCenterActive: isPaleMoon ? lateNightAsset("buttons", "btn__rate_center_cyan.svg") : ""
    readonly property url optionalDeckRateCenterInactive: isPaleMoon ? lateNightAsset("buttons", "btn__rate_center_off.svg") : ""
    readonly property url optionalMixerEqKillDotActiveGreen: isPaleMoon ? lateNightAsset("buttons", "btn__eq_kill_dot_active_green.svg") : ""
    readonly property url optionalMixerEqKillDotActiveRed: isPaleMoon ? lateNightAsset("buttons", "btn__eq_kill_dot_active_red.svg") : ""
    readonly property url optionalMixerEqKillDotOff: isPaleMoon ? lateNightAsset("buttons", "btn__eq_kill_dot_off.svg") : ""
    readonly property url optionalMixerQuickEffectActiveIcon: isPaleMoon ? lateNightAsset("buttons", "btn__star_active.svg") : ""
    readonly property color overviewHotcueBrightTextColor: "#000000"
    readonly property int overviewHotcueBrightnessThreshold: 127
    readonly property color overviewMarkerTextColor: "#ffffff"
    readonly property color overviewRgbHighColor: "#ff0000"
    readonly property color overviewRgbLowColor: "#0000ff"
    readonly property color overviewRgbMidColor: "#00ff00"
    readonly property color overviewBorderBottomColor: "#2a2a2a"
    readonly property color overviewBorderLeftColor: "#121212"
    readonly property color overviewBorderRightColor: "#252525"
    readonly property color overviewBorderTopColor: "#0d0d0d"
    readonly property color overviewSettingsBackgroundColor: isClassic ? "#151515" : "#19191a"
    readonly property string playCueActiveIconSuffix: isPaleMoon ? "active" : ""
    readonly property color primaryDeckTextColor: "#EAF6FF"
    readonly property color primaryOverviewBackgroundColor: "#070C12"
    readonly property color primaryWaveformSignalColor: "#59E4FF"
    readonly property color samplerBpmColor: isClassic ? "#f0bb2b" : "#766b65"
    readonly property color samplerBpmSeparatorLightColor: "#292929"
    readonly property color samplerColor: "#B86BFF"
    readonly property color samplerEffectAssignment12ActiveColor: isClassic ? "#659f08" : "#236b00"
    readonly property color samplerEffectAssignment34ActiveColor: isClassic ? "#0895bc" : "#146674"
    readonly property color samplerEffectAssignmentInactiveTextColor: isClassic ? "#696969" : "#666666"
    readonly property color samplerExpanderBottomBorderColor: isClassic ? "#111111" : "#020202"
    readonly property color samplerExpanderColor: isClassic ? "#171717" : "#151517"
    readonly property color samplerExpanderLeftBorderColor: isClassic ? "#222222" : "#191919"
    readonly property color samplerExpanderRightBorderColor: "#111111"
    readonly property color samplerExpanderTopBorderColor: isClassic ? "#222222" : "#212123"
    readonly property color samplerGainArcColor: isClassic ? "#db7700" : "#8d3b11"
    readonly property color samplerGainColor: isClassic ? "#db7700" : "#b24c12"
    readonly property color samplerOverviewBackgroundColor: isClassic ? "#151515" : "#19191a"
    readonly property color samplerOverviewBackgroundLoadedColor: isClassic ? "#080808" : "#151515"
    readonly property color samplerOverviewBorderBottomColor: isClassic ? "#333333" : "#2a2a2a"
    readonly property color samplerOverviewBorderLeftColor: isClassic ? "#0a0a0a" : "#121212"
    readonly property color samplerOverviewBorderRightColor: isClassic ? "#333333" : "#252525"
    readonly property color samplerOverviewBorderTopColor: isClassic ? "#0a0a0a" : "#0d0d0d"
    readonly property color samplerPanelColor: isClassic ? "#1e1e1e" : "#1e1e20"
    readonly property color samplerPflActiveColor: isClassic ? "#db0000" : "#666666"
    readonly property color samplerPitchSliderBarColor: "#888888"
    readonly property color samplerSettingsBorderBottomColor: isClassic ? "#0c0c0c" : "#2a2a2a"
    readonly property color samplerSettingsBorderTopColor: isClassic ? "#0c0c0c" : "#080808"
    readonly property color samplerTitleColor: isClassic ? "#d2d2d1" : "#c2b3a5"
    readonly property color samplerWaveformFilteredHighColor: isClassic ? "#f3f16f" : "#a17b35"
    readonly property color samplerWaveformFilteredLowColor: isClassic ? "#e7c413" : "#d9b28c"
    readonly property color samplerWaveformFilteredMidColor: isClassic ? "#edaf27" : "#d09271"
    readonly property color secondaryDeckTextColor: "#9D7BFF"
    readonly property color secondaryOverviewBackgroundColor: "#0A1020"
    readonly property color secondaryWaveformSignalColor: "#A98CFF"
    readonly property color starsColor12: isClassic ? "#f0bb2b" : "#988f86"
    readonly property color starsColor34: isClassic ? "#0bd9d1" : "#559b99"
    readonly property int syncButtonHorizontalPadding: isClassic ? 3 : 0
    readonly property color syncExplicitLeaderColor: activePlayCueColor
    readonly property color syncImplicitLeaderColor: isPaleMoon ? "#7d350d" : "#db7700"
    readonly property color syncInactiveBackgroundColor: "#1e1e1e"
    readonly property color textColor: "#F4FAFF"
    readonly property color textColorMuted: "#718498"
    readonly property color trackPropertyHighlightColor: "#151515"
    readonly property color trackPropertySelectedTextColor: "#111111"
    readonly property color trackPropertySelectionColor: white
    readonly property color toolbarActiveColor: white
    readonly property color toolbarBackgroundColor: "#111821"
    readonly property color toolbarBottomBorderColor: "#1A222D"
    readonly property color toolbarBroadcastOnColor: "#42E6A4"
    readonly property color toolbarButtonActiveBackgroundColor: "#10D9E8"
    readonly property color toolbarButtonActiveTextColor: "#06080D"
    readonly property int toolbarButtonHeight: 26
    readonly property color toolbarButtonInactiveBackgroundColor: "#1A222D"
    readonly property color toolbarButtonInactiveTextColor: "#7D8C9A"
    readonly property int toolbarButtonWidth: 52
    readonly property color toolbarClockTextColor: "#F4F8FC"
    readonly property color toolbarLatencyBorderColor: "#1A222D"
    readonly property color toolbarLatencyLabelColor: "#7D8C9A"
    readonly property color toolbarLatencyOverloadColor: "#FFC857"
    readonly property color toolbarMenuDisabledTextColor: "#7D8C9A"
    readonly property color toolbarMenuHoverColor: "#1A222D"
    readonly property color toolbarMenuHoverTextColor: "#F4F8FC"
    readonly property color toolbarMenuTextColor: "#D8E2EC"
    readonly property color toolbarMeterBackgroundColor: "#0A0F16"
    readonly property color toolbarPopupBackgroundColor: "#0A0F16"
    readonly property color toolbarPopupBorderColor: "#3D5264"
    readonly property color toolbarRecordInitColor: "#FFC857"
    readonly property color toolbarRecordOnColor: "#FF5364"
    readonly property color toolbarRecordingColor: "#FF5364"
    readonly property color toolbarRecordingTextColor: "#FFC857"
    readonly property color toolbarRootBackgroundColor: "#0A0F16"
    readonly property color toolbarStatusErrorColor: "#FF5364"
    readonly property color toolbarStatusOkColor: "#42E6A4"
    readonly property color toolbarStatusWarnColor: "#FFC857"
    readonly property color passthroughActiveColor: "#FFC857"
    readonly property color vinylCueingActiveColor: "#7D8C9A"
    readonly property color vinylStatusSignalAndSpeedColor: "#D96BFF"
    readonly property color vinylStatusSignalColor: "#42E6A4"
    readonly property color vinylStatusSpeedColor: "#FFC857"
    readonly property color waveformBeatAxesColor: "#FFFFFF"
    readonly property color waveformCueColor: "#FFC857"
    readonly property color waveformDefaultMarkColor: "#FF5364"
    readonly property color waveformDisabledMarkColor: "#FFFFFF"
    readonly property color waveformEndOfTrackWarningColor: "#FF5364"
    readonly property color waveformFilteredHighColor: "#D96BFF"
    readonly property color waveformFilteredLowColor: "#10D9E8"
    readonly property color waveformFilteredMidColor: "#7658C9"
    readonly property color waveformIntroOutroColor: "#10D9E8"
    readonly property color waveformLoopColor: "#42E6A4"
    readonly property color waveformMarkerTextColor: "#FFFFFF"
    readonly property color waveformPlayPositionColor: "#FFFFFF"
    readonly property color waveformPrimaryBackgroundColor: "#06080D"
    readonly property color waveformSecondaryBackgroundColor: "#06080D"
    readonly property color white: "#F4F8FC"

    function lateNightAsset(directory, fileName) {
        return Qt.resolvedUrl("../../LateNight/" + ColorScheme.name + "/" + directory + "/" + fileName);
    }
    function lateNightButton(fileName) {
        return lateNightAsset("buttons", fileName);
    }
    function lateNightRegionButton(regionButtonType, buttonSize) {
        return lateNightButton("btn_" + regionButtonType + "_" + buttonSize + ".svg");
    }
    function lateNightSubRegionButton(buttonSize) {
        return lateNightRegionButton(isClassic ? "elevated" : "embedded", buttonSize);
    }
    function lateNightTopRegionButton(buttonSize) {
        return lateNightRegionButton("embedded", buttonSize);
    }
    function mixerKnobIndicator(kind, colorName) {
        return lateNightAsset("knobs", "knob_indicator_" + kind + "_" + colorName + ".svg");
    }
    function mixerVuClipBackground(colorVariant) {
        return lateNightAsset("style", "vu_deck_clipping_bg_" + colorVariant + ".png");
    }
    function mixerVuLevelBackground(colorVariant) {
        return lateNightAsset("style", "vu_deck_level_bg_" + colorVariant + ".png");
    }
    function overviewHotcueTextColor(hotcueColor) {
        const red = hotcueColor.r * 255;
        const green = hotcueColor.g * 255;
        const blue = hotcueColor.b * 255;
        const brightness = Math.sqrt(red * red * 0.241 + green * green * 0.691 + blue * blue * 0.068);
        return brightness <= overviewHotcueBrightnessThreshold
                ? overviewMarkerTextColor
                : overviewHotcueBrightTextColor;
    }
    function sharedImage(fileName) {
        return Qt.resolvedUrl("../../../qml/images/" + fileName);
    }
    function vinylStatusColor(status) {
        switch (Math.round(status)) {
        case 1:
            return vinylStatusSignalColor;
        case 2:
            return vinylStatusSpeedColor;
        case 3:
            return vinylStatusSignalAndSpeedColor;
        default:
            return deckEmbeddedButtonInactiveColor;
        }
    }
}
