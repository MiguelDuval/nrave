import QtQuick

Item {
    id: root

    // Deck is an adapter around FullDeck. Keep the external Deck contract
    // explicit and forward the required Mixxx deck group to the child.
    required property string group
    property alias editMode: fullDeck.editMode
    property alias minimized: fullDeck.minimized

    signal toggleFocus

    implicitWidth: fullDeck.implicitWidth
    implicitHeight: fullDeck.implicitHeight

    FullDeck {
        id: fullDeck

        anchors.fill: parent
        group: root.group
        editMode: root.editMode
        minimized: root.minimized

        onToggleFocus: root.toggleFocus()
    }
}
