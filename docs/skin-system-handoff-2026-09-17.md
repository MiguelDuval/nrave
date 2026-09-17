# NRave Android QML skin system — engineering handoff (2026-09-17)

This document is the canonical handoff for the next context window. It describes the current repository state, the architectural mistake in the experimental redesign, and the migration strategy for making the LateNight UI a real Android-selectable skin without embedding the application shell into the skin.

## Repository state

Repository: `MiguelDuval/nrave`

Current working baseline: `main`

Current `main` tip used for this handoff:

- `44e49fd7003b5c1d9e1c3f061c7f06eacfad8279` — `fix(android): restore preference-driven skin selection`

Experimental redesign branch:

- `experimental/main-window-ui-redesign`
- tip: `f1509e1c0a601082c2767dd5b4ea231a40a7b55e`

The two branches have diverged. At handoff time the experimental branch is 50 commits ahead and 5 commits behind `main`. Do not merge the experimental branch wholesale into `main`.

## Core architectural conclusion

The previous work mixed two separate concerns:

1. the **application shell / QML runtime contract**;
2. the **visual skin and its DJ controls**.

That caused repeated runtime failures and made a skin appear to work while actually replacing the Android application structure.

The correct contract is:

`Android/QML application shell -> selected skin content -> skin-specific controls/features`

The root `ApplicationWindow` must remain owned by the application runtime. A skin should provide the main-window **content**, not become a second application root.

The experimental branch violated this by using `res/skins/LateNightQML/main.qml` as an `ApplicationWindow`. Its `MainWindow.qml` was then loaded inside that skin-owned window. That made the LateNight UI instantiate, but it also displaced the Android application's normal shell/navigation/settings path.

## Critical source facts

### Existing application root on `main`

`res/qml/main.qml` is the real QML application entrypoint. It creates the root `ApplicationWindow`, handles mobile fullscreen sizing, and loads `res/qml/MainWindow.qml` as its content.

Important shape:

- root: `ApplicationWindow`
- content: `Loader`
- selected content currently: `MainWindow { applicationWindow: root }`
- Android overlays (`AbletonLinkOverlay.qml`, `BitGridOverlay.qml`) are attached at the root level.

### Existing MainWindow contract

`res/qml/MainWindow.qml` is an `Item`, not an `ApplicationWindow`.

It already requires:

```qml
required property ApplicationWindow applicationWindow
```

and exposes/uses the application's menu command objects and core Mixxx controls.

This is the contract the LateNight `MainWindow.qml` should satisfy.

### Experimental LateNight root is the wrong layer

`res/skins/LateNightQML/main.qml` on the experimental branch is an `ApplicationWindow` and contains a second startup/loader system, splash, progress state and LateNight-specific root lifecycle.

That file should not become the Android application root.

The valuable reusable part is the LateNight **content implementation**, primarily:

- `res/skins/LateNightQML/MainWindow.qml`
- its `Deck/`, `Mixer/`, `Samplers/`, `Effects/`, `Toolbar/`, `Waveforms/`, `Controls/`, and `LateNightTheme/` components
- the additional Mixxx controls created by that content
- feature implementations such as BeatGrid controls

## What went wrong in the earlier redesign

The experimental branch changed many files simultaneously and then discovered QML API mismatches at runtime one by one.

Verified failures included:

- `Cannot assign to non-existent property "onClicked"`
- `Cannot assign to non-existent property "inactiveOpacity"`
- Android failure resolving `../../../qml/Mixxx/Controls`

Those were fixed locally during investigation, but the fixes should be treated as compatibility evidence, not as a reason to transplant the entire branch.

Additional important evidence:

- `LateNightIconButton` did not originally expose the signals/properties that the redesign assumed.
- Android materialized QML files cannot safely be assumed to have the same source-tree-relative paths as the desktop Qt resource tree.
- Registered modules such as `Mixxx.Controls 1.0` are the correct mechanism when a shared QML API is registered as a module.

## Migration strategy

Do **not** copy the experimental branch into `main`.

Instead, recover the work in four layers.

### Layer 1 — establish a stable skin loader

The loader must make exactly one decision:

- `AndroidDefault` (or the existing default identifier) -> current `res/qml/MainWindow.qml`
- `LateNightQML` -> `res/skins/LateNightQML/MainWindow.qml`

Both choices must be inserted into the same root `ApplicationWindow` created by `res/qml/main.qml`.

Do not load `res/skins/LateNightQML/main.qml` as the root window.

Do not create a second `ApplicationWindow` for the skin.

Do not create a second Android settings/navigation system inside the skin.

### Layer 2 — keep Preferences outside the skin

The persisted skin identifier remains `[Config] ResizableSkin`.

The existing Preferences implementation (`DlgPrefInterface`) already knows how to enumerate skins and write that setting.

The skin-selection workflow should be:

`Preferences -> ResizableSkin -> restart/reload -> root ApplicationWindow -> selected MainWindow content`

The Preferences page must remain the single source of truth for selecting the skin.

### Layer 3 — migrate LateNight functionality as content/features

The functionality developed in the redesign should be extracted from the experimental root and kept where it belongs:

- deck-specific controls stay in deck components;
- mixer controls stay in mixer components;
- sampler controls stay in sampler components;
- visual behavior stays in the LateNight theme/components;
- application-level overlays that genuinely apply to Android stay in the application root;
- skin-specific persistent control state stays under `[Skin]` where appropriate.

The `Mixxx.SkinControlCreator` declarations added to the LateNight content are useful, but they must be audited so they do not accidentally become a substitute for application-level state.

### Layer 4 — only then improve visual design

Once the following works on Android:

1. app starts with Android Default;
2. Preferences opens normally;
3. LateNightQML can be selected;
4. restart loads LateNightQML content in the same application root;
5. Android-level settings/navigation still work;
6. changing back to Android Default works;
7. BitGrid and other custom controls still work;
8. no QML runtime errors occur;

then the visual redesign can continue independently.

## What NOT to do next

Do not:

- add more QML Loader fallbacks to hide errors;
- put Android settings/navigation into LateNightQML;
- patch individual `onClicked`/opacity errors without auditing the component API;
- make `LateNightQML/main.qml` another application root;
- re-enable `--new-ui` as a shortcut for selecting a skin;
- assume a desktop-relative `../../../qml/...` path is valid on Android;
- merge all experimental commits into `main` just because they contain desired visuals.

## Recommended implementation shape

The preferred design is conceptually:

```qml
ApplicationWindow {           // owned by res/qml/main.qml
    Loader {
        sourceComponent: selectedSkinMainWindow
    }

    // shared Android/app-level overlays remain here
}
```

where `selectedSkinMainWindow` resolves to either:

```qml
MainWindow { applicationWindow: root }
```

or:

```qml
LateNightMainWindow { applicationWindow: root }
```

The exact loader mechanism should be implemented only after verifying the existing `QmlSkin`/`SkinLoader` entrypoint contract and Android packaging path. Do not hard-code assumptions about `main.qml` until that audit is complete.

## Validation protocol

Every architectural change should be checked in this order:

1. static inspection of the affected QML/C++ dependency graph;
2. build;
3. Android launch with `AndroidDefault`;
4. open Preferences;
5. select `LateNightQML`;
6. restart;
7. verify LateNight content;
8. verify application-level settings/navigation;
9. switch back to `AndroidDefault`;
10. only then test individual redesigned controls.

A successful build alone does not prove that the skin system works.

## Context transfer rule

A new chat should begin by reading this file and then inspecting the exact current `main` tip. Do not rebuild the historical reasoning from memory.

The user wants the assistant to operate as a senior Qt/QML/C++/Android engineer on the public repository only.

Primary objective for the next phase:

> Make the skin architecture correct and reliable first. Preserve as much of the existing LateNight functionality as possible, but re-home it behind the existing application-shell contract instead of reproducing the shell inside the skin.
