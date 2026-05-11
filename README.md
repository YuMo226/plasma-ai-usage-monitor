# AI API Balance Plasma Widget

[简体中文](README_CN.md)

## Project Structure

```
Plasmoid/
├── com.yumo.ai_usage/              # Plasma 6 widget
│   ├── contents/
│   │   └── ui/
│   │       └── main.qml           # Main QML file
│   ├── metadata.json              # Plasma 6 metadata
│   └── README.md                  # Widget documentation
├── get_ai_usage.py                # Python backend script
├── ai_widget.example.json         # DeepSeek config example
├── ai_widget.proxy.example.json   # Proxy config example
└── README.md                      # This file
```

## Dependencies (Arch Linux)

```bash
sudo pacman -S python python-requests
```

Or with paru:

```bash
paru -S python python-requests
```

## Installation

### 1. Configure API

```bash
cp ai_widget.example.json ~/.config/ai_widget.json
$EDITOR ~/.config/ai_widget.json
```

### 2. Install widget

```bash
cp -r com.yumo.ai_usage ~/.local/share/plasma/plasmoids/
```

### 3. Restart Plasma

```bash
plasmashell --replace &
```

### 4. Add widget

Right-click desktop → Add Widgets → Search "AI Usage Monitor"

## Testing

### Test Python script

```bash
python3 get_ai_usage.py
```

### Test widget

```bash
plasmoidviewer -a com.yumo.ai_usage
```

## Configuration

### DeepSeek

```json
{
  "api_url": "https://api.deepseek.com",
  "api_key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "provider": "deepseek"
}
```

**Note:** DeepSeek API only returns current balance, not total limit or historical usage.

### OpenAI Official

```json
{
  "api_url": "https://api.openai.com",
  "api_key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "provider": "openai"
}
```

### Third-party Proxy (one-api, new-api, etc.)

```json
{
  "api_url": "https://your-proxy.example.com",
  "api_key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "provider": "proxy",
  "unit": 0.000001,
  "paths": {
    "usage": "/api/user/self"
  },
  "fields": {
    "limit": "quota",
    "usage": "used_quota"
  }
}
```

## Output Format

```json
{
  "success": true,
  "limit": 0,
  "usage": 0,
  "balance": 2.33,
  "error_msg": ""
}
```

- `success`: Whether the request succeeded
- `limit`: Total quota (0 for DeepSeek)
- `usage`: Used amount (0 for DeepSeek)
- `balance`: Current remaining balance
- `error_msg`: Error message if request failed

## Plasma 6 API

- Uses `P5Support.DataSource` with `executable` engine
- Uses `PlasmoidItem` for widget structure
- Uses `Kirigami` components for UI
- 30-minute auto-refresh with `Timer`
