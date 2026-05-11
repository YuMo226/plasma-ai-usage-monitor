# AI API 使用情况监控部件 (AI Usage Monitor)

一个专为 KDE Plasma 6 设计的桌面部件（Plasmoid），用于实时监控各种 AI 服务提供商（如 OpenAI、DeepSeek 等）的余额和额度消耗情况。

## 🌟 特性

- **现代化设计**：采用类似 Apple 风格的深色半透明设计，美观大方。
- **多供应商支持**：原生支持 OpenAI、DeepSeek，并支持通过自定义 API 路径兼容各类第三方中转代理。
- **动态进度环**：直观展示已用额度百分比。
- **自动刷新**：默认每 30 分钟自动更新数据。
- **高性能**：后端使用 Python 异步请求，前端使用 QML 与 Kirigami，轻量且流畅。

## 📂 项目结构

```
.
├── com.yumo.ai_usage/              # Plasma 6 部件源码
│   ├── contents/
│   │   └── ui/
│   │       ├── main.qml           # 主控制逻辑
│   │       ├── FullRepresentation.qml # 展开后的详细视图
│   │       └── CompactRepresentation.qml # 面板上的简略视图
│   ├── metadata.json              # 插件元数据
├── get_ai_usage.py                # Python 后端数据获取脚本
├── ai_widget.example.json         # DeepSeek 配置示例
├── ai_widget.proxy.example.json   # 中转代理配置示例
└── README.md                      # 英文文档
```

## 🛠️ 安装要求

### 依赖 (以 Arch Linux 为例)

```bash
sudo pacman -S python python-requests
```

## 🚀 安装步骤

### 1. 配置 API 密钥

你需要先创建一个配置文件。将示例文件复制到你的配置目录：

```bash
cp ai_widget.example.json ~/.config/ai_widget.json
```

然后使用编辑器修改 `~/.config/ai_widget.json`，填入你的 `api_url` 和 `api_key`。

### 2. 安装部件

将部件文件夹复制到 Plasma 的插件目录下：

```bash
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r com.yumo.ai_usage ~/.local/share/plasma/plasmoids/
```

### 3. 重启 Plasma 面板

为了让 Plasma 识别新安装的部件，建议重启面板：

```bash
plasmashell --replace &
```

### 4. 添加到桌面或面板

右键点击桌面或面板 -> 选择“添加部件” -> 搜索 “AI Usage Monitor” 并拖入。

## ⚙️ 配置说明

### DeepSeek 官方
```json
{
  "api_url": "https://api.deepseek.com",
  "api_key": "sk-xxxxxxxxxxxxxxxx",
  "provider": "deepseek"
}
```
*注：DeepSeek API 目前仅返回当前余额，不提供历史总消耗。*

### OpenAI 官方
```json
{
  "api_url": "https://api.openai.com",
  "api_key": "sk-xxxxxxxxxxxxxxxx",
  "provider": "openai"
}
```

### 第三方中转代理 (One-API, New-API 等)
```json
{
  "api_url": "https://your-proxy-domain.com",
  "api_key": "sk-xxxxxxxxxxxxxxxx",
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

## 🔍 测试与调试

如果遇到数据显示不正确，可以手动运行后端脚本查看输出：

```bash
python3 get_ai_usage.py
```

或者使用 `plasmoidviewer` 预览界面错误：

```bash
plasmoidviewer -a com.yumo.ai_usage
```

## 📄 开源协议

本项目采用 [GPL-2.0+](LICENSE) 协议开源。
