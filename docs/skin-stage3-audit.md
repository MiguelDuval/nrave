# NRave QML skin architecture — Stage 3 audit record

Date: 2026-09-19

Repository: MiguelDuval/nrave

## Stage 3 conclusion

The Stage 3 branch, `stage3-skin-loader-contract`, is preserved as an engineering forensic snapshot. It should not be treated as the development base for further skin work.

The branch contains useful evidence, not a reusable final architecture.

## Verified findings

1. The correct runtime boundary is a single application-owned `ApplicationWindow` in `res/qml/main.qml`.
2. A skin should provide a `MainWindow.qml` content item and receive the application window through a required property.
3. `LateNightQML/MainWindow.qml` was converted to this content-only shape and is therefore useful as a later migration target.
4. The previous experimental design mixed shell ownership, skin selection, resource materialization, and skin content.
5. Stage 3 accumulated multiple skin-selection authorities:
   - `SkinLoader`
   - raw `[Config]/ResizableSkin` reads in `QmlApplication`
   - QML Preferences
   - native Preferences
6. Android resource handling evolved from external-storage copying to app-private materialization. The app-private model is the one to retain.
7. The 1055-line Stage 3 Android UI smoke test is useful as historical infrastructure, but its coordinate- and pixel-signature-heavy checks are too coupled to the CI emulator to serve as the core architectural proof.
8. Stage 3's explicit loader diagnostics are useful and should be retained in a smaller form.

## Stage 3 architectural anti-patterns to avoid

- Do not make a skin its own `ApplicationWindow`.
- Do not let the skin own Android settings/navigation.
- Do not add Loader fallbacks that silently replace a selected skin with Android Default.
- Do not resolve the same skin independently in several layers.
- Do not mix APK asset resolution and arbitrary desktop-relative paths in the same runtime contract.
- Do not use a full visual UI test to prove a loader contract.

## Stage 4 test objective

Prove only this:

`ApplicationWindow -> resolved skin MainWindow.qml -> rendered content`

The first experimental skin is deliberately minimal and visually unmistakable: `TestSkin`.

Only after this contract is proven should LateNightQML be reintroduced.
