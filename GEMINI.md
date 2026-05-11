# AI API Usage Monitor Plasmoid

A KDE Plasma 6 widget for monitoring balance and usage across various AI providers.

## Project Overview

This project provides a system tray or panel widget for KDE Plasma 6 that displays the remaining balance and usage statistics for AI APIs.

### Core Technologies
- **Frontend**: QML, Kirigami, QtQuick (Plasma 6 API)
- **Backend**: Python 3 (using the `requests` library)
- **Integration**: `P5Support.DataSource` (executable engine) for running the backend from QML.

### Architecture
1. **Backend (`get_ai_usage.py`)**:
   - Fetches data from OpenAI, DeepSeek, or third-party proxies.
   - Reads configuration from `~/.config/ai_widget.json`.
   - Outputs result as a JSON object to `stdout`.
2. **Frontend (`com.yumo.ai_usage/`)**:
   - `main.qml`: Manages the application lifecycle, data fetching, and representation switching.
   - `CompactRepresentation.qml`: Minimal view for panels.
   - `FullRepresentation.qml`: Detailed popup view with a progress ring and balance information.
   - `metadata.json`: Defines the widget's properties for Plasma.

## Building and Running

### Prerequisites
- KDE Plasma 6
- Python 3
- `python-requests` package

### Setup and Installation
1. **Configure API**:
   ```bash
   cp ai_widget.example.json ~/.config/ai_widget.json
   # Edit ~/.config/ai_widget.json with your API keys and provider settings
   ```
2. **Install the Widget**:
   ```bash
   cp -r com.yumo.ai_usage ~/.local/share/plasma/plasmoids/
   ```
3. **Restart Plasma** (to pick up the new widget):
   ```bash
   plasmashell --replace &
   ```

### Testing and Debugging
- **Test Python logic**:
  ```bash
  python3 get_ai_usage.py
  ```
- **Test UI in a window**:
  ```bash
  plasmoidviewer -a com.yumo.ai_usage
  ```

## Development Conventions

### Code Structure
- Python scripts should remain at the root or within `contents/` if they are only for the widget.
- QML files are organized in `com.yumo.ai_usage/contents/ui/`.
- `main.qml` acts as the controller, while `CompactRepresentation` and `FullRepresentation` are purely for display.

### Data Flow
- Communication from QML to Python is via command-line arguments (though currently simple execution).
- Communication from Python to QML is via JSON on `stdout`.
- The widget refreshes every 30 minutes by default.

### UI Style
- Follows a custom dark aesthetic ("Apple-style") using manual `Rectangle` and `Canvas` elements rather than just standard Kirigami themes for the full representation.
- Uses `Qt5Compat.GraphicalEffects` for gradients.
