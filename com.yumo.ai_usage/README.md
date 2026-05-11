# AI Usage Monitor - Plasma 6 Widget

## Deployment Commands

### Install (first time)

```bash
kpackagetool6 -t Plasma/Applet -i com.yumo.ai_usage
```

### Update (after changes)

```bash
kpackagetool6 -t Plasma/Applet -u com.yumo.ai_usage
```

### Remove

```bash
kpackagetool6 -t Plasma/Applet -r com.yumo.ai_usage
```

### List installed widgets

```bash
kpackagetool6 -t Plasma/Applet -l
```

### Test in viewer

```bash
plasmoidviewer -a com.yumo.ai_usage
```

## Directory Structure

```
com.yumo.ai_usage/
├── contents/
│   ├── ui/
│   │   ├── main.qml                  # Entry point
│   │   ├── CompactRepresentation.qml # Panel icon
│   │   └── FullRepresentation.qml    # Expanded view
│   └── get_ai_usage.py               # Backend script
├── metadata.json
└── README.md
```

## Quick Install (manual copy)

```bash
cp -r com.yumo.ai_usage ~/.local/share/plasma/plasmoids/
```
