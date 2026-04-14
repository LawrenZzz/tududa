<div align="center">

# 📱 Tududa

<img src="assets/icon.png" width="128" alt="Tududa Icon">
<br>
<small><em>应用图标由 AI 生成</em></small>

**基于 [Tududi](https://github.com/chrisvel/tududi) 的 Flutter 移动客户端**

*一个平静、开放的生活与工作组织系统。*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Vibe Coded](https://img.shields.io/badge/Vibe-Coded_🎵-ff69b4)](#-vibe-coding)

[English](README.md) | **中文**

</div>

---

## ⚠️ 声明

**本项目是第三方移动客户端。** Tududa 与原始 Tududi 项目没有任何隶属、背书或关联关系。

原始 [Tududi](https://github.com/chrisvel/tududi) 由 **[Chris Veleris](https://github.com/chrisvel)** 创建并维护 —— 一个基于 Node.js 和 React 构建的自托管任务管理系统。所有后端 API 和服务端逻辑均属于原始项目，采用 [MIT 许可证](https://github.com/chrisvel/tududi/blob/main/LICENSE) 开源。

本 Flutter 客户端是一个独立的、社区驱动的项目，旨在将 Tududi 体验带到 Android 和 iOS 移动设备上。

---

## 🎵 Vibe Coding

本项目完全采用 **Vibe Coding** 方式构建 —— 通过人与 AI 的对话式结对编程完成。没有任何代码是以传统方式手动逐行编写的；相反，每一个功能、修复和设计决策都诞生于与 AI 编程助手的自然语言对话中。

> *"描述你想要的，让代码自然流淌。"*

---

## ✨ 功能特性

- 📋 **任务管理** — 创建、编辑、删除和完成任务，支持优先级、截止日期和重复任务
- 📁 **项目组织** — 将任务分组到项目中，通过完成百分比跟踪进度
- 📊 **看板视图** — 项目任务和全局任务列表均支持可视化看板视图，可切换列表/看板模式
- 🏷️ **领域与标签** — 层级化组织结构，领域（Area）包含项目
- 📝 **笔记** — 支持 Markdown 格式的笔记，可关联到项目
- 🔄 **重复任务** — 支持每日、每周、每月等多种重复模式，灵活调度
- 🌐 **国际化** — 完整的中文和英文双语支持
- 🎨 **Material Design 3** — 现代简洁的 UI 设计，支持深色模式和毛玻璃效果
- 🔐 **会话认证** — 基于 Cookie 的认证机制，对接自托管 Tududi 服务器
- 📱 **跨平台** — 一套代码同时支持 Android 和 iOS

---

## 📸 截图

> *即将推出*

---

## 🛠️ 技术栈

| 分类 | 技术方案 |
|---|---|
| **框架** | Flutter 3.x / Dart 3.x |
| **状态管理** | Riverpod |
| **网络请求** | Dio + Cookie Manager |
| **路由** | GoRouter |
| **本地存储** | SharedPreferences、FlutterSecureStorage |
| **UI 组件** | Material Design 3、Google Fonts、Flutter Markdown |
| **架构模式** | 基于功能模块的分层结构 |

---

## 📦 项目结构

```
lib/
├── auth/              # 认证模块（登录、会话管理）
│   ├── providers/
│   ├── screens/
│   └── services/
├── common/            # 公共组件（GlassContainer 等）
│   └── widgets/
├── core/              # 应用基础设施
│   ├── router/        # GoRouter 路由配置
│   ├── services/      # ApiService（Dio 客户端）
│   └── theme/         # Material 3 主题
├── home/              # 首页 / 仪表盘
│   └── screens/
├── l10n/              # 本地化字符串（中文/英文）
├── notes/             # 笔记模块
│   ├── models/
│   ├── providers/
│   └── screens/
├── projects/          # 项目模块
│   ├── models/
│   ├── providers/
│   ├── screens/
│   └── widgets/       # KanbanBoard 看板组件
├── tasks/             # 任务模块
│   ├── models/
│   ├── providers/
│   └── screens/
├── app.dart           # App 根组件
└── main.dart          # 入口文件
```

---

## 🚀 快速开始

### 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x 及以上
- 一个运行中的 [Tududi](https://github.com/chrisvel/tududi) 服务器实例
- Android Studio / Xcode（用于平台构建）

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/LawrenZzz/tududa.git
cd tududa

# 安装依赖
flutter pub get

# 以开发模式运行
flutter run
```

### 配置服务器

在登录界面输入你的 Tududi 服务器地址（例如 `http://your-server:3002`），然后输入账号密码即可登录。

### 构建发布版本

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔧 服务端兼容性

本客户端专为 [Tududi](https://github.com/chrisvel/tududi) 后端设计。核心 API 说明：

| 操作 | 方法 | 端点 |
|---|---|---|
| 获取任务列表 | `GET` | `/api/tasks` |
| 获取单个任务 | `GET` | `/api/task/:uid` |
| 创建任务 | `POST` | `/api/task` |
| 更新任务 | `PATCH` | `/api/task/:uid` |
| 删除任务 | `DELETE` | `/api/task/:uid` |
| 获取项目列表 | `GET` | `/api/projects` |
| 更新项目 | `PATCH` | `/api/project/:uid` |

> **注意：** 服务器所有更新操作使用 `PATCH`（而非 `PUT`），资源通过 `uid` 字符串进行标识。

---

## 🤝 参与贡献

欢迎贡献代码！你可以通过提交 Issue 或 Pull Request 来参与项目。

1. Fork 本仓库
2. 创建功能分支（`git checkout -b feature/amazing-feature`）
3. 提交你的更改
4. 推送到你的 Fork 并创建 Pull Request

---

## 📜 许可证

本项目采用 [MIT 许可证](LICENSE) 开源。

---

## 🙏 致谢

- **[Chris Veleris](https://github.com/chrisvel)** — 原始 [Tududi](https://github.com/chrisvel/tududi) 项目的创建者。没有他优秀的开源工作，本客户端不可能存在。
- **[Tududi 社区](https://github.com/chrisvel/tududi/discussions)** — 构建和维护服务端生态。
- 使用 [Flutter](https://flutter.dev) 和 **Vibe Coding** 🎵 的力量，用 ❤️ 构建。

---

<div align="center">

*Tududa — 让生活与工作的组织变得平静而有序*

</div>
