import QtQuick
import QtQuick.Layouts
import Mixxx 1.0 as Mixxx
import "../../../qml" as Skin
import "../LateNightTheme"

Item {
    id: root

    required property string group
    property bool showRateControlButtons: true

    readonly property var deckPlayer: Mixxx.PlayerManager.getPlayer(root.group)
    readonly property bool isLoaded: deckPlayer?.isLoaded ?? false

    implicitWidth: 86
    implicitHeight: 170
    readonly property bool useSecondaryDeckText: root.group === "[Channel3]" || root.group === "[Channel4]"
    readonly property color bpmTextColor: useSecondaryDeckText ? LateNightTheme.secondaryDeckTextColor : LateNightTheme.primaryDeckTextColor
    readonly property color rateTextColor: useSecondaryDeckText ? LateNightTheme.secondaryDeckTextColor : LateNightTheme.primaryDeckTextColor
    readonly property bool hasLegacyRateCenterAsset: LateNightTheme.optionalDeckRateCenterInactive.toString().length > 0

    function syncLeaderIconSource() {
        switch (Math.round(syncLeaderProxy.value)) {
        case 1:
            return LateNightTheme.assetDeckLeaderImplicitButton;
        case 2:
            return LateNightTheme.assetDeckLeaderExplicitButton;
        default:
            return LateNightTheme.assetDeckLeaderButton;
        }
    }

    function rateRangeTopLabelY(labelHeight) {
        labelHeight;
        return 0;
    }

    function rateRangeBottomLabelY(labelHeight) {
        return sliderContainer.height - labelHeight - 1;
    }

    property real previousSyncEnabledValue: syncEnabledProxy.value

    Mixxx.ControlProxy { id: bpmProxy; group: root.group; key: "bpm" }
    Mixxx.ControlProxy { id: rateRatioProxy; group: root.group; key: "rate_ratio" }
    Mixxx.ControlProxy { id: rateDirProxy; group: root.group; key: "rate_dir" }
    Mixxx.ControlProxy { id: rateRangeProxy; group: root.group; key: "rateRange" }
    Mixxx.ControlProxy { id: rateSetDefaultProxy; group: root.group; key: "rate_set_default" }
    Mixxx.ControlProxy { id: syncEnabledProxy; group: root.group; key: "sync_enabled" }
    Mixxx.ControlProxy { id: syncLeaderProxy; group: root.group; key: "sync_leader" }

    Item {
        id: deckRateSeparator
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1; color: LateNightTheme.deckPanelBorderDark }
        Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: 1; color: LateNightTheme.deckPanelBorderLight }
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: deckRateSeparator.right
        anchors.leftMargin: 2
        spacing: 2

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 62
            Layout.preferredHeight: 38
            Column {
                anchors.fill: parent
                Text { width: parent.width; height: 21; text: bpmProxy.value.toFixed(2); font.family: "Open Sans"; font.pixelSize: 19; font.bold: true; color: root.bpmTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                Text { width: parent.width; height: 17; text: ((rateRatioProxy.value - 1) * 100).toFixed(2); font.family: "Open Sans"; font.pixelSize: 12; color: root.rateTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            LateNightBpmTapEditor { id: bpmTapEditor; anchors.fill: parent; group: root.group }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 62
            Layout.preferredHeight: 22
            spacing: 0
            LateNightControlButton {
                id: syncBtn
                Layout.preferredWidth: 40; Layout.preferredHeight: 22
                backgroundSource: LateNightTheme.assetDeckSyncBackground
                activeBackgroundSuffix: "active"
                iconSource: syncEnabledProxy.value > 0 ? LateNightTheme.assetDeckSyncActiveButton : LateNightTheme.assetDeckSyncButton
                group: root.group; key: "sync_enabled"; rightClickKey: "sync_leader"; longPressLatching: true
                numberStates: 2; longPressLatchOverlayColor: LateNightTheme.syncInactiveBackgroundColor
                longPressLatchOverlayBackgroundSource: LateNightTheme.assetDeckSyncBackground
                longPressLatchOverlayIconSource: LateNightTheme.assetDeckSyncButton
                activeOpacity: 1.0; inactiveOpacity: 1.0; activeColor: LateNightTheme.syncExplicitLeaderColor
                fillMargin: 0; iconBottomPadding: LateNightTheme.isPaleMoon ? 2 : 0
                iconLeftPadding: LateNightTheme.isPaleMoon ? 2 : LateNightTheme.syncButtonHorizontalPadding
                iconRightPadding: LateNightTheme.isPaleMoon ? 2 : LateNightTheme.syncButtonHorizontalPadding
                iconTopPadding: LateNightTheme.isPaleMoon ? 2 : 0; rasterizeIconAtPaintedSize: LateNightTheme.isPaleMoon; stretchIcon: LateNightTheme.isPaleMoon
            }
            LateNightControlButton {
                id: leaderBtn
                Layout.preferredWidth: 22; Layout.preferredHeight: 22
                backgroundSource: LateNightTheme.assetDeckLeaderBackground
                activeBackgroundSuffix: "active"
                iconSource: root.syncLeaderIconSource(); group: root.group; key: "sync_leader"; displayKey: "sync_leader"
                ignoreActivePresses: true; releaseToZero: false; activeDisplayThreshold: 0.5; activeOpacity: 1.0; inactiveOpacity: 1.0
                activeColor: { switch (Math.round(syncLeaderProxy.value)) { case 1: return LateNightTheme.syncImplicitLeaderColor; case 2: return LateNightTheme.syncExplicitLeaderColor; default: return "transparent"; } }
                fillMargin: 0
                onPrimaryPressed: function(displayValue) { if (displayValue <= 0.5) syncBtn.startLatchReveal(); }
            }
        }

        Connections {
            target: syncEnabledProxy
            function onValueChanged(newValue) { if (newValue > 0 && root.previousSyncEnabledValue <= 0) syncBtn.startLatchReveal(); root.previousSyncEnabledValue = newValue; }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 1

            Item {
                id: sliderContainer
                Layout.preferredWidth: 50
                Layout.preferredHeight: 100
                Layout.minimumHeight: 100
                Layout.alignment: Qt.AlignVCenter

                Text { width: 7; height: 14; x: 3; y: root.rateRangeTopLabelY(height); text: "−"; font.family: "Open Sans"; font.pixelSize: 11; color: root.rateTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                Text { width: 18; height: 14; x: 32; y: root.rateRangeTopLabelY(height); text: (rateRangeProxy.value * 100).toFixed(0); font.family: "Open Sans"; font.pixelSize: 9; color: root.rateTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                Text { width: 7; height: 14; x: 3; y: root.rateRangeBottomLabelY(height); text: "+"; font.family: "Open Sans"; font.pixelSize: 11; color: root.rateTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                Text { width: 18; height: 14; x: 32; y: root.rateRangeBottomLabelY(height); text: (rateRangeProxy.value * 100).toFixed(0); font.family: "Open Sans"; font.pixelSize: 9; color: root.rateTextColor; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

                Skin.ControlFader {
                    id: rateSlider
                    x: 4; y: 1; width: 38; height: 98
                    bar.enabled: true; bar.color: LateNightTheme.mixerSliderBarColor; bar.margin: 6; bar.start: 0.5
                    showDefaultHandle: false; group: root.group; key: "rate"
                    background: Image { anchors.fill: parent; fillMode: Image.PreserveAspectFit; source: LateNightTheme.assetDeckRateSliderBackground }
                    handle: Image {
                        width: 36; height: 15
                        x: (rateSlider.width - width) / 2
                        y: rateSlider.visualPosition * (rateSlider.height - height)
                        fillMode: Image.PreserveAspectFit
                        source: LateNightTheme.assetDeckRateSliderHandle
                    }
                }

                Image { id: rateCenterAsset; width: 5; height: 5; x: 1; y: 47; z: rateSlider.z + 1; source: rateSetDefaultProxy.value > 0 ? LateNightTheme.optionalDeckRateCenterActive : LateNightTheme.optionalDeckRateCenterInactive; fillMode: Image.PreserveAspectFit; visible: root.hasLegacyRateCenterAsset }
                Rectangle { width: 5; height: 5; x: 1; y: 47; z: rateSlider.z + 1; radius: 1; color: rateSetDefaultProxy.value > 0 ? LateNightTheme.schemeAccent : LateNightTheme.surfaceLevel4; border.color: LateNightTheme.deckPanelBorderDark; visible: !root.hasLegacyRateCenterAsset }
            }

            ColumnLayout {
                Layout.preferredWidth: 24
                Layout.alignment: Qt.AlignVCenter
                spacing: 1
                visible: root.showRateControlButtons
                Repeater {
                    model: ["minus", "up", "down", "plus"]
                    delegate: LateNightControlButton {
                        required property string modelData
                        Layout.preferredWidth: 24; Layout.preferredHeight: 23
                        backgroundSource: LateNightTheme.lateNightTopRegionButton("square")
                        iconSource: modelData === "minus" ? LateNightTheme.assetDeckMinusButton : modelData === "up" ? LateNightTheme.assetDeckArrowLeftUpButton : modelData === "down" ? LateNightTheme.assetDeckArrowRightDownButton : LateNightTheme.assetDeckPlusButton
                        group: root.group
                        key: modelData === "minus" ? (rateDirProxy.value >= 0 ? "rate_perm_up" : "rate_perm_down") : modelData === "up" ? (rateDirProxy.value >= 0 ? "rate_temp_up" : "rate_temp_down") : modelData === "down" ? (rateDirProxy.value >= 0 ? "rate_temp_down" : "rate_temp_up") : (rateDirProxy.value >= 0 ? "rate_perm_down" : "rate_perm_up")
                        rightClickKey: modelData === "minus" ? (rateDirProxy.value >= 0 ? "rate_perm_up_small" : "rate_perm_down_small") : modelData === "up" ? (rateDirProxy.value >= 0 ? "rate_temp_up_small" : "rate_temp_down_small") : modelData === "down" ? (rateDirProxy.value >= 0 ? "rate_temp_down_small" : "rate_temp_up_small") : (rateDirProxy.value >= 0 ? "rate_perm_down_small" : "rate_perm_up_small")
                        activeOpacity: 0.95; inactiveOpacity: 0.76; inactiveColor: LateNightTheme.deckEmbeddedButtonInactiveColor
                    }
                }
            }
        }
    }
}
