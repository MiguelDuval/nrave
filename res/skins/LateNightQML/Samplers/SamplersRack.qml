pragma ComponentBehavior: Bound

import Mixxx 1.0 as Mixxx
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    readonly property int mode: Math.max(0, Math.min(5, Math.round(samplerRowsControl.value)))
    readonly property bool modeControlsInitialized: show4SamplersControl.initialized && show8SamplersControl.initialized && show16SamplersControl.initialized && show32SamplersControl.initialized && show48SamplersControl.initialized && show64SamplersControl.initialized
    readonly property int selectedSamplerCount: [4, 8, 16, 32, 48, 64][mode]
    property bool synchronizingMode: false

    function normalizeMode() {
        if (!root.modeControlsInitialized)
            return;
        root.selectMode(root.mode);
    }

    function selectMode(mode) {
        if (!root.modeControlsInitialized || mode < 0 || mode > 5)
            return;
        root.synchronizingMode = true;
        show4SamplersControl.value = mode === 0 ? 1 : 0;
        show8SamplersControl.value = mode === 1 ? 1 : 0;
        show16SamplersControl.value = mode === 2 ? 1 : 0;
        show32SamplersControl.value = mode === 3 ? 1 : 0;
        show48SamplersControl.value = mode === 4 ? 1 : 0;
        show64SamplersControl.value = mode === 5 ? 1 : 0;
        samplerRowsControl.value = mode;
        root.synchronizingMode = false;
    }

    implicitHeight: samplerGroups.implicitHeight

    ColumnLayout {
        id: samplerGroups
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: root.selectedSamplerCount === 4 ? 1 : root.selectedSamplerCount / 8

            SamplerGroup {
                required property int index

                Layout.fillWidth: true
                count: root.selectedSamplerCount === 4 ? 4 : 8
                expandKey: root.selectedSamplerCount === 4 ? "expand_samplers_1-4" : ("expand_samplers_" + firstSampler + "-" + (firstSampler + 7))
                firstSampler: root.selectedSamplerCount === 4 ? 1 : 1 + index * 8
                preloadExpandedContent: index === 0
                show8Hotcues: show8HotcuesControl.value > 0
                showFxAssignments: showSamplerFxControl.value > 0
            }
        }
    }

    Mixxx.ControlProxy {
        id: numSamplersControl

        group: "[App]"
        key: "num_samplers"
    }
    Mixxx.ControlProxy {
        id: samplerRowsControl

        group: "[Skin]"
        key: "sampler_rows"
    }
    Mixxx.ControlProxy {
        id: show4SamplersControl

        group: "[Skin]"
        key: "show_4samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(0);
        }
    }
    Mixxx.ControlProxy {
        id: show8SamplersControl

        group: "[Skin]"
        key: "show_8samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(1);
        }
    }
    Mixxx.ControlProxy {
        id: show16SamplersControl

        group: "[Skin]"
        key: "show_16samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(2);
        }
    }
    Mixxx.ControlProxy {
        id: show32SamplersControl

        group: "[Skin]"
        key: "show_32samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(3);
        }
    }
    Mixxx.ControlProxy {
        id: show48SamplersControl

        group: "[Skin]"
        key: "show_48samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(4);
        }
    }
    Mixxx.ControlProxy {
        id: show64SamplersControl

        group: "[Skin]"
        key: "show_64samplers"
        onInitializedChanged: root.normalizeMode()
        onValueChanged: {
            if (!root.synchronizingMode && value > 0.5)
                root.selectMode(5);
        }
    }
    Mixxx.ControlProxy {
        id: show8HotcuesControl

        group: "[Skin]"
        key: "show_8_hotcues"
    }
    Mixxx.ControlProxy {
        id: showSamplerFxControl

        group: "[Skin]"
        key: "show_sampler_fx"
    }
    Mixxx.ControlProxy {
        id: showSamplersControl

        group: "[Skin]"
        key: "show_samplers"
    }
}