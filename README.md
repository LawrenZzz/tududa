<div align="center">

# 📱 Tududa

**A Flutter mobile client for [Tududi](https://github.com/chrisvel/tududi)**

*A calm, open system for organizing life and work.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Vibe Coded](https://img.shields.io/badge/Vibe-Coded_🎵-ff69b4)](#-vibe-coding)

**English** | [中文](README_CN.md)

</div>

---

## ⚠️ Disclaimer

**This is a third-party mobile client.** Tududa is not affiliated with, endorsed by, or connected to the original Tududi project.

The original [Tududi](https://github.com/chrisvel/tududi) is created and maintained by **[Chris Veleris](https://github.com/chrisvel)** — a self-hosted task management system built with Node.js and React. All backend APIs and server-side logic belong to the original project, licensed under the [MIT License](https://github.com/chrisvel/tududi/blob/main/LICENSE).

This Flutter client is an independent, community-driven effort to bring the Tududi experience to Android and iOS devices.

---

## 🎵 Vibe Coding

This project is entirely **vibe coded** — built through human-AI pair programming sessions using conversational prompts. No line of code was manually typed in the traditional sense; instead, every feature, fix, and design decision emerged from natural language conversations with AI coding assistants.

> *"Describe what you want, and let the code flow."*

---

## ✨ Features

- 📋 **Task Management** — Create, edit, delete, and complete tasks with priorities, due dates, and recurrence
- 📁 **Project Organization** — Group tasks into projects, track progress with completion percentages
- 📊 **Kanban Board** — Visual kanban view for both project tasks and the global task list, with drag-status support
- 🏷️ **Areas & Tags** — Hierarchical organization with areas containing projects
- 📝 **Notes** — Markdown-formatted notes attached to projects
- 🔄 **Recurring Tasks** — Daily, weekly, monthly patterns with flexible scheduling
- 🌐 **i18n** — Full Chinese (中文) and English localization
- 🎨 **Material Design 3** — Modern, clean UI with dark mode support and glassmorphism effects
- 🔐 **Session Authentication** — Cookie-based auth with your self-hosted Tududi server
- 📱 **Cross-Platform** — Android & iOS from a single codebase

---

## 📸 Screenshots

> *Coming soon*

---

## 🛠️ Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.x |
| **State Management** | Riverpod |
| **Networking** | Dio + Cookie Manager |
| **Routing** | GoRouter |
| **Storage** | SharedPreferences, FlutterSecureStorage |
| **UI** | Material Design 3, Google Fonts, Flutter Markdown |
| **Architecture** | Feature-based modular structure |

---

## 📦 Project Structure

```
lib/
├── auth/              # Authentication (login, session management)
│   ├── providers/
│   ├── screens/
│   └── services/
├── common/            # Shared widgets (GlassContainer, etc.)
│   └── widgets/
├── core/              # App infrastructure
│   ├── router/        # GoRouter configuration
│   ├── services/      # ApiService (Dio client)
│   └── theme/         # Material 3 theme
├── home/              # Home / Dashboard
│   └── screens/
├── l10n/              # Localization strings (zh/en)
├── notes/             # Notes module
│   ├── models/
│   ├── providers/
│   └── screens/
├── projects/          # Projects module
│   ├── models/
│   ├── providers/
│   ├── screens/
│   └── widgets/       # KanbanBoard
├── tasks/             # Tasks module
│   ├── models/
│   ├── providers/
│   └── screens/
├── app.dart           # App widget
└── main.dart          # Entry point
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x+
- A running [Tududi](https://github.com/chrisvel/tududi) server instance
- Android Studio / Xcode (for platform builds)

### Setup

```bash
# Clone the repository
git clone https://github.com/LawrenZzz/tududa.git
cd tududa

# Install dependencies
flutter pub get

# Run in development mode
flutter run
```

### Configure Server

On the login screen, enter your Tududi server URL (e.g., `http://your-server:3002`) along with your credentials.

### Build Release APK

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔧 Server Compatibility

This client is designed for the [Tududi](https://github.com/chrisvel/tududi) backend. Key API characteristics:

| Operation | Method | Endpoint |
|---|---|---|
| List tasks | `GET` | `/api/tasks` |
| Get task | `GET` | `/api/task/:uid` |
| Create task | `POST` | `/api/task` |
| Update task | `PATCH` | `/api/task/:uid` |
| Delete task | `DELETE` | `/api/task/:uid` |
| List projects | `GET` | `/api/projects` |
| Update project | `PATCH` | `/api/project/:uid` |

> **Note:** The server uses `PATCH` (not `PUT`) for all update operations, and resources are typically identified by `uid` strings.

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to your fork and open a Pull Request

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙏 Acknowledgments

- **[Chris Veleris](https://github.com/chrisvel)** — Creator of the original [Tududi](https://github.com/chrisvel/tududi) project. This client would not exist without his excellent open-source work.
- **[Tududi Community](https://github.com/chrisvel/tududi/discussions)** — For building and maintaining the server ecosystem.
- Built with ❤️ using [Flutter](https://flutter.dev) and the power of **Vibe Coding** 🎵.

---

<div align="center">

*Tududa — 让生活与工作的组织变得平静而有序*

</div>
