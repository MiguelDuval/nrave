# Android QML skin system — investigation record (2026-09-17)

This document preserves the findings from the September 2026 investigation so future UI work can reuse the evidence instead of repeating runtime debugging.

## Decision / baseline

For the next phase, use `main` as the clean UI baseline and repair the skin-loading system there first.

Do **not** use `experimental/main-window-ui-redesign` as the starting point for the skin-loader repair. That branch contains a large UI redesign plus loader/API compatibility experiments which make it difficult to distinguish skin-system bugs from redesign bugs.

Current `main` branch tip at the time this record was written:

- Branch: `main`
- Commit: `fe2b52f450ca536c80998f91df7399d654b7a354`
- Message: `chore: restore NRave full splash source`

Experimental branch used during the investigation:

- Branch: `experimental/main-window-ui-redesign`
- It contains the LateNight QML redesign and subsequent loader/debug fixes.

## What we proved

### 1. There are two different problems: loading the QML skin and owning the Android application shell

The LateNight redesign eventually became loadable, but the resulting window was effectively the LateNight desktop-style main window. It did not provide the Android-level application settings/navigation that the user needs to select and manage skins.

Therefore:

- "LateNight QML successfully instantiated" is **not** equivalent to "the Android skin system works".
- The skin must be loaded as the content of the application's existing Android shell, not as a replacement for the entire Android application shell.
- Do not solve this by adding Android navigation/settings into the LateNight skin itself.

### 2. `main.qml` is the real QML application entrypoint

`src/qml/qmlapplication.cpp` sets `m_mainFilePath` to `qml/main.qml`. On Android it materializes `assets:/qml` into external storage and then loads that `main.qml`.

Relevant current `main` code:

- `src/qml/qmlapplication.cpp`
- `res/qml/main.qml`

The Android copy routine currently skips only the compiled `res/qml/Mixxx` directory. It copies the rest of `res/qml` recursively.

**Important consequence:** any future skin-loader design must respect the actual Android materialization mechanism. A relative source path that works inside the Qt resource tree is not automatically equivalent to a file that exists in the Android external QML tree.

### 3. `main` already has a configurable skin setting

`src/qml/qmlconfigproxy.cpp` exposes `Config.configSkin`, backed by:

- group: `[Config]`
- key: `ResizableSkin`

The default is an empty string.

Therefore the configuration value exists independently of the redesigned LateNight loader. The main-branch task is to connect that persisted configuration to the QML application entrypoint correctly.

### 4. Existing repository contains `res/skins/LateNightQML`

`main` contains a `res/skins/LateNightQML` directory in addition to the standard skin directories. So the next investigation should determine:

1. how that directory is packaged for Android,
2. which exact identifier is stored in `[Config] ResizableSkin`,
3. how Preferences presents the available QML skin choices,
4. how the selected skin is expected to map to an entrypoint (`main.qml` vs `MainWindow.qml`), and
5. whether Android needs `res/skins` copied/materialized alongside `res/qml`.

Do not assume the answer from the experimental branch; verify it on `main`.

## Experimental branch evidence

The redesign investigation exposed several concrete incompatibilities. They are useful as compatibility rules, but their individual commits should not be blindly ported to `main`.

### A. Incorrect component API assumption: `LateNightIconButton onClicked`

The original redesign documentation claimed controls such as `LateNightIconButton` supported `onClicked`. The actual component did not expose such a signal/property. This produced a runtime component-chain error:

`Cannot assign to non-existent property "onClicked"`

The lesson is general: before changing a QML skin, audit custom component APIs and do not infer signal/property availability from documentation or from similarly named Qt Quick Controls.

### B. Shared component API mismatch: `inactiveOpacity`

The redesign used `activeOpacity` / `inactiveOpacity` on `LateNightIconButton`, while the original component only exposed `contentOpacity`.

This produced:

`Cannot assign to non-existent property "inactiveOpacity"`

A compatibility fix was then made in `LateNightIconButton.qml` so the active/inactive opacity properties were explicit aliases/derived state. This is evidence of an API-contract mismatch in the redesign, not evidence that the Android skin system itself needed those properties.

### C. Android-incompatible source-tree relative import

The Sampler redesign hit:

`SamplerFull.qml:7 "../../../qml/Mixxx/Controls": no such directory`

The offending import was changed from:

`import "../../../qml/Mixxx/Controls" as MixxxControls`

to the registered module:

`import Mixxx.Controls 1.0 as MixxxControls`

This is an important Android rule for future QML work:

> Prefer registered QML modules (`Mixxx.Controls 1.0`, etc.) for compiled/shared QML APIs; do not assume a source-tree-relative `qml/...` directory will exist in the Android materialized skin filesystem.

### D. LateNight loader experiment proved the shell problem

The experimental branch changed `res/qml/main.qml` to inspect `Mixxx.Config.configSkin` and dynamically load `../skins/LateNightQML/MainWindow.qml` for non-`AndroidDefault` values.

That change demonstrated that a LateNight component can be instantiated, but it did not provide the expected Android-level UI/settings shell. This should be treated as an architectural warning, not as the final loader design.

## Known experimental commits / evidence

Major redesign commit:

- `8db4ce37165886c0507f060314fd7cda5712a7ff`
- `feat(ui): redesign LateNight Main Window`

Loader/debug commits that followed on the experimental branch included:

- `7e2a39cba7d64c100f39bd851cb3af71d8eaaedb` — fix loader required `applicationWindow`
- `415c48d78356202c32d7cc9fafa1bd7038867d74` — precise QML component diagnostics
- `43c7b3c4ca8d41e7a144efe0112e1de9457add1b` — Android-safe `Mixxx.Controls` import in Deck/OverviewRow
- `99c242313c0db08d052e56d5d46189220659ad48` — local BeatGrid button fix
- `3509785c720bbbb1c31dc032aa5fefa78d70f481` — `LateNightIconButton` opacity API compatibility
- `f1509e1c0a601082c2767dd5b4ea231a40a7b55e` — Android-safe `Mixxx.Controls` import in SamplerFull

These commits are investigation history, not a recommended patch set for `main`.

## Runtime errors captured during the investigation

First component-chain failure:

```text
LateNightQML failed to load
MainWindow.qml:242 Type LateNightDeck.Deck unavailable
Deck/Deck.qml:3 Type FullDeck unavailable
Deck/FullDeck.qml:194 Type TransportLoopBeatjumpPlaceholders unavailable
Deck/TransportLoopBeatjumpPlaceholders.qml:192 Cannot assign to non-existent property "onClicked"
```

Second component-chain failure:

```text
TransportLoopBeatjumpPlaceholders.qml:183 Cannot assign to non-existent property "inactiveOpacity"
```

Third failure:

```text
LateNight QML failed to load
MainWindow.qml:559 Type LateNightSamplers.SamplersRack unavailable
Samplers/SamplersRack.qml:46 Type SamplerGroup unavailable
Samplers/SamplerGroup.qml:89 Type SamplerFull unavailable
Samplers/SamplerFull.qml:7 "../../../qml/Mixxx/Controls": no such directory
```

These errors establish a recurring pattern: the redesign was exposing incompatibilities one component at a time because the entire LateNight dependency graph had not been statically audited against the Android QML runtime.

## What the next main-branch investigation must establish before changing UI

1. Identify the persisted `[Config] ResizableSkin` values and the exact mapping between UI labels and stored values.
2. Identify the existing Preferences implementation that writes/changes that value.
3. Identify the original/expected skin entrypoint contract on desktop and Android.
4. Identify how `res/skins` is packaged into the Android APK and whether it is materialized to the same external QML root as `res/qml`.
5. Implement the smallest possible loader change in `main` that switches between the existing Android Default main window and the existing `LateNightQML` entrypoint while preserving the surrounding application shell.
6. Build and test the loader with **no visual redesign changes**.
7. Only after skin selection/loading is proven stable should a new UI redesign branch be created.

## Golden rule for future redesign work

**Do not redesign the skin loader and the skin UI simultaneously.**

First establish a stable, independently tested contract:

`Preferences -> persisted skin ID -> Android-safe skin materialization -> skin entrypoint -> Android application shell`

Then redesign the visual contents behind that contract.
