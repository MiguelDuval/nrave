# Experimental Main Window UI Map

## A. Current UI Map

### Visual Element → File → Component → Object ID → Data Source → Interaction → Skin Dependency → Risk

#### UPPER SECTION

| Visual Element | File | Component | Object ID | Data Source | Interaction | Skin Dependency | Risk |
|---|---|---|---|---|---|---|---|
| Top Toolbar | LateNightQML/Toolbar/Toolbar.qml | Toolbar | root | [Skin] controls | Click/tap | LateNightTheme | HIGH |
| Waveform Overview (D1) | LateNightQML/Deck/OverviewRow.qml | OverviewRow | waveformOverview | [Waveform], [Channel1] | Mouse/touch | LateNightTheme | HIGH |
| Waveform Overview (D2) | LateNightQML/Deck/OverviewRow.qml | OverviewRow | waveformOverview | [Waveform], [Channel2] | Mouse/touch | LateNightTheme | HIGH |
| Waveform Display (D1) | LateNightQML/Waveforms/LateNightWaveformDisplay.qml | LateNightWaveformDisplay | waveformDisplay | [Channel1] | MouseArea | LateNightTheme | CRITICAL |
| Waveform Display (D2) | LateNightQML/Waveforms/LateNightWaveformDisplay.qml | LateNightWaveformDisplay | waveformDisplay | [Channel2] | MouseArea | LateNightTheme | CRITICAL |
| Beatgrid Controls (D1) | LateNightQML/Waveforms/BeatgridControls.qml | BeatgridControls | beatgridControls | [Channel1], [Skin] | Button clicks | LateNightTheme | HIGH |
| Beatgrid Controls (D2) | LateNightQML/Waveforms/BeatgridControls.qml | BeatgridControls | beatgridControls | [Channel2], [Skin] | Button clicks | LateNightTheme | HIGH |
| Playhead | LateNightWaveformDisplay.qml | WaveformRendererPlayPosition | Internal | playposition | Real-time | LateNightTheme | CRITICAL |
| Track Title (D1) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | titleText | [Channel1] currentTrack.title | Double-click edit | LateNightTheme | MEDIUM |
| Track Title (D2) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | titleText | [Channel2] currentTrack.title | Double-click edit | LateNightTheme | MEDIUM |
| Track Artist (D1) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | artistText | [Channel1] currentTrack.artist | Double-click edit | LateNightTheme | MEDIUM |
| Track Artist (D2) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | artistText | [Channel2] currentTrack.artist | Double-click edit | LateNightTheme | MEDIUM |
| Elapsed/Remaining (D1) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | trackTimeDisplay | [Channel1] duration, playposition | Double-click cycles | LateNightTheme | MEDIUM |
| Elapsed/Remaining (D2) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | trackTimeDisplay | [Channel2] duration, playposition | Double-click cycles | LateNightTheme | MEDIUM |
| Track Duration (D1) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | durationText | [Channel1] duration | Display only | LateNightTheme | LOW |
| Track Duration (D2) | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | durationText | [Channel2] duration | Display only | LateNightTheme | LOW |
| BPM Display (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton + spinbox | Various | [Channel1] bpm, bpmlock | Tap, spinbox | LateNightTheme | HIGH |
| BPM Display (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton + spinbox | Various | [Channel2] bpm, bpmlock | Tap, spinbox | LateNightTheme | HIGH |
| Deck Identifier (D1) | LateNightQML/Toolbar/Toolbar.qml | Toolbar button | deck1Button | [Channel1] | Click to focus | LateNightTheme | LOW |
| Deck Identifier (D2) | LateNightQML/Toolbar/Toolbar.qml | Toolbar button | deck2Button | [Channel2] | Click to focus | LateNightTheme | LOW |
| Play/Pause (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightControlButton | playButton | [Channel1] play | Click toggles | LateNightTheme | CRITICAL |
| Play/Pause (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightControlButton | playButton | [Channel2] play | Click toggles | LateNightTheme | CRITICAL |
| Cue Button (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightControlButton | cueButton | [Channel1] cue_default | Left/Right click | LateNightTheme | CRITICAL |
| Cue Button (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightControlButton | cueButton | [Channel2] cue_default | Left/Right click | LateNightTheme | CRITICAL |
| Sync Button (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton | Various | [Channel1] sync_enabled | Click toggles | LateNightTheme | HIGH |
| Sync Button (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton | Various | [Channel2] sync_enabled | Click toggles | LateNightTheme | HIGH |
| Quantize Button (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton | Various | [Channel1] quantize | Click toggles | LateNightTheme | HIGH |
| Quantize Button (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | LateNightIconButton | Various | [Channel2] quantize | Click toggles | LateNightTheme | HIGH |
| Spinny/Cover (D1) | LateNightQML/Deck/SpinnyCoverSlot.qml | SpinnyCoverSlot | spinnyContainer | [Channel1] coverArtUrl | Visual only | LateNightTheme | MEDIUM |
| Spinny/Cover (D2) | LateNightQML/Deck/SpinnyCoverSlot.qml | SpinnyCoverSlot | spinnyContainer | [Channel2] coverArtUrl | Visual only | LateNightTheme | MEDIUM |
| No Track Loaded | LateNightQML/Deck/TitleTimeRows.qml | LateNightTrackPropertyText | titleText | deckPlayer.isLoaded | Text display | LateNightTheme | LOW |
#### CENTRAL SECTION (Deck Controls)

| Visual Element | File | Component | Object ID | Data Source | Interaction | Skin Dependency | Risk |
|---|---|---|---|---|---|---|---|
| Transport (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout | playButton, cueButton, syncButton, quantizeButton | [Channel1] | Tap/touch | LateNightTheme | CRITICAL |
| Transport (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout | playButton, cueButton, syncButton, quantizeButton | [Channel2] | Tap/touch | LateNightTheme | CRITICAL |
| Loop Controls (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout 4x2 | Various | [Channel1] beatloop_size, loop_* | Tap, spinbox | LateNightTheme | HIGH |
| Loop Controls (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout 4x2 | Various | [Channel2] beatloop_size, loop_* | Tap, spinbox | LateNightTheme | HIGH |
| Beatjump (D1) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout 2x2 | Various | [Channel1] beatjump_size, beatjump | Tap, spinbox | LateNightTheme | HIGH |
| Beatjump (D2) | LateNightQML/Deck/TransportLoopBeatjumpPlaceholders.qml | GridLayout 2x2 | Various | [Channel2] beatjump_size, beatjump | Tap, spinbox | LateNightTheme | HIGH |
| Hotcues (D1) | LateNightQML/Deck/HotcueAndStem.qml | HotcueButton array | Various | [Channel1] hotcue_X_* | Tap, long press | LateNightTheme | HIGH |
| Hotcues (D2) | LateNightQML/Deck/HotcueAndStem.qml | HotcueButton array | Various | [Channel2] hotcue_X_* | Tap, long press | LateNightTheme | HIGH |
| Pitch Fader (D1) | qml/Deck/TempoColumn.qml | TempoColumn | Various | [Channel1] rate, rate_ratio | Touch drag | Theme.qml | HIGH |
| Pitch Fader (D2) | qml/Deck/TempoColumn.qml | TempoColumn | Various | [Channel2] rate, rate_ratio | Touch drag | Theme.qml | HIGH |
| Pitch Bend (D1) | LateNightQML/Waveforms/BeatgridControls.qml | LateNightControlButton | beats_translate_earlier/later | [Channel1] | Tap hold | LateNightTheme | HIGH |
| Pitch Bend (D2) | LateNightQML/Waveforms/BeatgridControls.qml | LateNightControlButton | beats_translate_earlier/later | [Channel2] | Tap hold | LateNightTheme | HIGH |

#### LOWER SECTION

| Visual Element | File | Component | Object ID | Data Source | Interaction | Skin Dependency | Risk |
|---|---|---|---|---|---|---|---|
| Mixer (Ch1-4) | LateNightQML/Mixer/Mixer.qml | Mixer + MixerDecks | decks | [Channel1-4], [Master] | Faders, knobs | LateNightTheme | HIGH |
| Crossfader | LateNightQML/Mixer/MixerDecks.qml | Crossfader | xfader | [Master] crossfader | Touch drag | LateNightTheme | CRITICAL |
| Channel Faders | LateNightQML/Mixer/MixerDecks.qml | Fader | Various | [Channel1-4] volume | Touch drag | LateNightTheme | HIGH |
| EQ Knobs | LateNightQML/Mixer/MixerDecks.qml | Knob | Various | [Channel1-4] eq_* | Touch rotate | LateNightTheme | HIGH |
| Gain Knobs | LateNightQML/Mixer/MixerDecks.qml | Knob | Various | [Channel1-4] gain | Touch rotate | LateNightTheme | HIGH |
| Level Meters | LateNightQML/Controls/ImageVuMeter.qml | ImageVuMeter | Various | [Channel1-4] VuMeter | Visual | LateNightTheme | MEDIUM |
| Sampler Rack | LateNightQML/Samplers/SamplersRack.qml | SamplersRack | samplerGroups | [Sampler1-64] | Tap, volume | LateNightTheme | HIGH |
| Effects Rack | LateNightQML/Effects/EffectsRack.qml | EffectsRack | effectsRack | [EffectRack1/4] | Params | LateNightTheme | HIGH |
| Library | qml/Library.qml | Library | library | Library model | Nav, search | Theme.qml | MEDIUM |

### Key Geometry Constants (LateNightQML/MainWindow.qml)

```qml
readonly property int fullDeckHeight: 206
readonly property int minimizedDeckHeight: 80
readonly property int numDecks: 4
readonly property int numSamplers: 64
```

### Layout Structure

```
MainWindow
├── Toolbar (~48px)
├── Content Column
│   ├── Deck Row (2 or 4 decks)
│   │   ├── Deck 1 (FullDeck) - 206px
│   │   │   ├── OverviewRow - 55px
│   │   │   ├── DeckWaveform (fills remaining)
│   │   │   │   ├── LateNightWaveformDisplay
│   │   │   │   └── BeatgridControls (right)
│   │   │   ├── TitleTimeRows - 55px
│   │   │   ├── SpinnyCoverSlot (1:1)
│   │   │   └── TransportLoopBeatjumpPlaceholders - 55px
│   │   └── Deck 2 (same)
│   ├── Effects (collapsible)
│   ├── Samplers (collapsible)
│   └── Library (fills rest)
```
## B. Proposed Redesign

### Current Geometry → New Geometry → Reason → Implementation Point

| Element | Current | Proposed | Reason | Implementation |
|---|---|---|---|---|
| Waveform Height (each) | ~120px | ~155-160px (+25-30%) | Primary performance info needs more space | FullDeck.qml RowLayout proportions |
| Waveform Total Region | ~240px (2 decks) | ~310-320px | Increase waveform dominance | MainWindow.qml contentColumn layout |
| Track Info Block | 55px height | ~35-40px (-35-40%) | Reduce footprint, keep readability | TitleTimeRows.qml implicitHeight, font sizes |
| Spinny/Cover Art | Variable (1:1) | Fixed smaller, ~60-70px | Reduce visual weight | SpinnyCoverSlot.qml width/height constraints |
| Transport Controls | 55px height | ~48-50px | Compact but touch-friendly | TransportLoopBeatjumpPlaceholders.qml height |
| Loop/Beatjump/Hotcue | 55px (shared row) | Reorganize, compact | Better grouping, less wasted space | TransportLoopBeatjumpPlaceholders.qml GridLayout |
| Mixer Height | Variable (~140-180px) | Keep similar, optimize | Already compact | Mixer.qml implicitHeight |
| Sampler Height | Variable (rows × ~55px) | Compact rows | Reduce vertical space | SamplersRack.qml spacing, row height |
| Effects Height | Variable | Compact | Reduce vertical space | EffectsRack.qml |
| Toolbar Height | ~48px | Keep ~48px | Already minimal | Toolbar.qml |
| Waveform Overview | 55px | Keep 55px or slight reduce | Secondary waveform | OverviewRow.qml Layout.preferredHeight |

## C. Functional Preservation

### Critical Controls → Existing Handler → Existing Binding → Must Remain Unchanged

| Control | Handler | Binding | Preservation |
|---|---|---|---|
| Play/Pause | LateNightControlButton onClicked → [ChannelN],play | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Cue | LateNightControlButton onClicked/RightClick → [ChannelN],cue_default / cue_gotoandstop | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Sync | LateNightIconButton onClicked → [ChannelN],sync_enabled | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Quantize | LateNightIconButton onClicked → [ChannelN],quantize | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Loop In/Out/Enable | LateNightIconButton + spinbox → [ChannelN],loop_* | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Beatjump | LateNightIconButton + spinbox → [ChannelN],beatjump_* | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Hotcues | HotcueButton onPressed/Released → [ChannelN],hotcue_X_* | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Pitch Fader | TempoColumn drag → [ChannelN],rate | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Pitch Bend | LateNightControlButton press → [ChannelN],wheel | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Crossfader | Fader drag → [Master],crossfader | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Channel Faders | Fader drag → [ChannelN],volume | Mixxx.ControlProxy group/key | MUST keep exact binding |
| EQ Knobs | Knob rotate → [ChannelN],eq_* | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Gain Knobs | Knob rotate → [ChannelN],gain | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Sampler Trigger | SamplerButton → [SamplerN],play | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Effect Controls | Various → [EffectRack1/4],* | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Waveform Scratch | MouseArea onPressed/PositionChanged/Released → [ChannelN],scratch_*, wheel | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Waveform Zoom | MouseArea onWheel → [ChannelN],waveform_zoom | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Beatgrid Translate | LateNightControlButton → [ChannelN],beats_translate_curpos | Mixxx.ControlProxy group/key | MUST keep exact binding |
| Track Load | Library drag-drop / double-click → Player.loadTrack | C++ backend | MUST NOT change |