with open("res/skins/LateNightQML/LateNightTheme/LateNightTheme.qml", "r", encoding="utf-8") as f:
    content = f.read()
replacements = {
} 
with open('res/skins/LateNightQML/LateNightTheme/LateNightTheme.qml', 'r', encoding='utf-8') as f:
    content = f.read()
for old, new in replacements.items():
    content = content.replace(old, new)
with open('res/skins/LateNightQML/LateNightTheme/LateNightTheme.qml', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
