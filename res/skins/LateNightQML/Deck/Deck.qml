import QtQuick

FullDeck {
    id: root

    // The experimental FullDeck historically contained temporary BitGrid/touch
    // diagnostics using deliberately high z-values. Keep the real controls and
    // bindings intact, but prevent those debug overlays from reaching production UI.
    Component.onCompleted: {
        for (let i = 0; i < root.children.length; ++i) {
            const child = root.children[i];
            if (child && child.z >= 10000)
                child.visible = false;
        }
    }
}
