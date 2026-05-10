# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KDE Plasma 6 widget ("plasmoid") called **AI Usage Monitor** that displays remaining balance and usage statistics for AI API providers (OpenAI, DeepSeek, third-party proxies like one-api/new-api). Licensed GPL-2.0+.

## Architecture

Two-layer design: Python backend fetches data, QML frontend displays it. Communication is one-way via JSON on stdout.

**Backend** (`get_ai_usage.py`):
- Reads config from `~/.config/ai_widget.json` (fields: `api_url`, `api_key`, `provider`)
- Three provider modes: `openai` (fetch_openai_official), `deepseek` (fetch_deepseek), `proxy` (fetch_proxy_api — generic, configurable via `paths`, `fields`, `unit`)
- Always outputs `{"success", "limit", "usage", "balance", "error_msg"}` to stdout, never crashes with non-zero exit

**Frontend** (`com.yumo.ai_usage/contents/ui/`):
- `main.qml` — controller; uses `P5Support.DataSource` (executable engine) to run the Python script; 30-minute Timer with `triggeredOnStart: true`
- `CompactRepresentation.qml` — panel bar: robot emoji + `$X.XX` balance
- `FullRepresentation.qml` — popup: dark rounded rect, Canvas progress ring with conic gradient, balance with LinearGradient text; UI strings are hardcoded Chinese

**Data flow**: Timer → `refresh()` → DataSource connects `"python3 <path>"` → Python prints JSON → `onNewData` parses → properties update representations.

## Key Files

| File | Role |
|------|------|
| `get_ai_usage.py` | Root-level backend (development/testing copy) |
| `com.yumo.ai_usage/contents/get_ai_usage.py` | Widget's backend copy (identical to root) |
| `com.yumo.ai_usage/metadata.json` | Plasma plugin metadata (ID: `com.yumo.ai_usage`) |
| `com.yumo.ai_usage/contents/ui/main.qml` | Entry point and data controller |
| `com.yumo.ai_usage/contents/ui/FullRepresentation.qml` | Detailed popup UI |
| `com.yumo.ai_usage/contents/ui/CompactRepresentation.qml` | Panel bar UI |

## Development Commands

```bash
# Test backend data fetching (outputs JSON to stdout)
python3 get_ai_usage.py

# Preview widget UI in a standalone window
plasmoidviewer -a com.yumo.ai_usage

# Install/update widget into Plasma
kpackagetool6 -t Plasma/Applet -i com.yumo.ai_usage
# or: kpackagetool6 -t Plasma/Applet -u com.yumo.ai_usage  (upgrade)

# Restart Plasma shell (pick up changes)
plasmashell --replace &

# View Plasma/widget logs for debugging
journalctl --user -f -u plasma-plasmashell
```

No build system — this is a pure interpreted project (Python + QML). No compilation step.

## Tech Stack

- **Python 3**: `requests`, `json`, `sys`, `pathlib`
- **QML/Qt 6**: `QtQuick`, `QtQuick.Controls`, `QtQuick.Layouts`, `QtQuick.Shapes`, `Qt5Compat.GraphicalEffects`
- **KDE**: `org.kde.kirigami`, `org.kde.plasma.core`, `org.kde.plasma.plasma5support` (P5Support.DataSource executable engine), `org.kde.plasma.plasmoid`

## Conventions

- `get_ai_usage.py` is duplicated: root copy is for development/testing, `contents/` copy is what the widget actually runs. Keep them in sync.
- UI uses a custom dark aesthetic (manual `Rectangle`/`Canvas` elements) rather than standard Kirigami theme for the full representation.
- The widget references its Python script via `Qt.resolvedUrl("../get_ai_usage.py")` (relative to the `ui/` directory).
- Config file lives at `~/.config/ai_widget.json` — not in the repo. Provider-specific config examples are shown in the README.
