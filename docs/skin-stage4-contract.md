# Stage 4 — minimal Android QML skin contract

## Goal

Prove the smallest end-to-end Android skin pipeline before migrating LateNight.

## Runtime contract

```
Android startup
    |
    v
materialize app-private QML/skin files
    |
    v
SkinLoader resolves ResizableSkin
    |
    v
QmlApplication receives the resolved skin
    |
    v
res/qml/main.qml owns one ApplicationWindow
    |
    v
Loader inserts the resolved MainWindow.qml
```

There is no second ApplicationWindow.

## Skin contract

Every Android QML skin used by this stage must provide:

- `skin.ini`
- `MainWindow.qml`
- root type `Item`
- `required property ApplicationWindow applicationWindow`
- optional `menuBar` property

The skin is content. It is not the application shell.

## TestSkin

`res/skins/TestSkin` is intentionally tiny and contains no Mixxx control dependencies.

It renders a unique visual marker and writes a runtime log message:

`NRAVE_SKIN_CONTRACT_TEST ready`

This separates loader correctness from LateNight's component graph.

## Test sequence

1. Fresh Android install.
2. Launch with Android Default.
3. Open Preferences -> Interface.
4. Select Test Skin.
5. Save and restart.
6. Assert `SkinLoader` resolved TestSkin.
7. Assert QML Loader reached Ready from TestSkin/MainWindow.qml.
8. Assert TestSkin runtime marker was emitted.
9. Switch back to Android Default.
10. Save and restart.
11. Assert Android Default resolved and loaded.

## Failure interpretation

- Resolver failure: `SkinLoader` or Android materialization problem.
- Wrong source path: QmlApplication-to-shell contract problem.
- Loader Error: QML import/content problem.
- Correct loader source + missing marker: TestSkin component/runtime problem.
- Correct marker but unchanged LateNight later: LateNight-specific component/design problem, not the base skin contract.

The Stage 3 1055-line UI smoke test is not the oracle for this stage.
