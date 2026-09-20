with open('res/skins/LateNightQML/Deck/FullDeck.qml', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('required property string group', 'required property string group\n    readonly property bool isDeckA: group === "[Channel1]"\n    readonly property bool isDeckB: group === "[Channel2]"')
content = content.replace('color: LateNightTheme.deckPanelColor', 'color: LateNightTheme.deckPanelColor\n    border.color: root.isDeckA ? LateNightTheme.primaryVioletColor : LateNightTheme.primaryCyan\n    border.width: 1')

with open('res/skins/LateNightQML/Deck/FullDeck.qml', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')