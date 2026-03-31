<div align="center">
  <h1>💰 FinXL</h1>
  <p><strong>A Modern, Responsive Personal Finance Tracking Application</strong></p>
  
  <p>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
    <a href="https://pub.dev/packages/flutter_bloc"><img src="https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge" alt="BLoC" /></a>
    <a href="https://pub.dev/packages/sqflite"><img src="https://img.shields.io/badge/Database-Sqflite-green?style=for-the-badge" alt="Sqflite" /></a>
  </p>
</div>

---

FinXL is a comprehensive personal finance tracking application built with Flutter. It provides users with an intuitive, beautifully designed interface to manage their financial ecosystem, track goals, monitor budgets, and oversee their bills—all while keeping data securely stored on their device.

## ✨ Key Features

- **📊 Dashboard:** Get an at-a-glance view of your total balance, monthly income, spending, and recent transaction highlights.
- **📈 Analytics:** Dive into in-depth breakdowns of your expenses and identify spending trends over time.
- **🎯 Goals Tracking:** Set financial milestones, allocate funds, and monitor your progress towards achieving them.
- **💰 Budgeting:** Organize your spending into custom categories with defined monthly limits to stay on track.
- **🗓️ Bills Management:** Keep track of upcoming bills, manage recurring payments, and receive local notifications before due dates.
- **🎨 Custom UI System:** Enjoy a cohesive, sleek design system featuring glassmorphism elements, custom routing patterns, and fully responsive layouts.
- **📴 Offline First:** All data is stored locally using `sqflite`, ensuring your financial information is private and accessible without an internet connection.

## 🛠️ Architecture & Tech Stack

The application strictly adheres to a feature-based architecture pattern (inspired by Clean Architecture) to ensure scalability, testability, and separation of concerns.

### Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.11.1)
- **Language:** Dart
- **State Management:** `flutter_bloc` (utilizing the Cubit pattern)
- **Database:** `sqflite` for fast, reliable local data persistence
- **Routing:** `go_router` combined with a dynamic `IndexedStack` inside an `AppShell` for seamless tab transitions
- **Notifications:** `flutter_local_notifications` and `flutter_timezone` for bill reminders
- **Other Core Dependencies:**
  - `equatable` (Value equality)
  - `google_fonts` (Typography)
  - `path_provider` (Local storage access)

## 📂 Project Structure

The codebase is organized by feature, making it highly modular:

```text
lib/
├── core/                  # Shared utilities, routing, and low-level services
│   ├── common/            # Shared UI components and logic
│   ├── database/          # Sqflite database setup & migrations
│   ├── models/            # Core domain entities (Transactions, Bills, Goals, etc.)
│   ├── navigation/        # App routing configuration
│   ├── notifications/     # Local notification service logic
│   ├── presentation/      # Shared presentation layer logic
│   ├── theme/             # Design system, colors, and typography
│   └── utils/             # Helper functions and extensions
└── features/              # Feature modules containing their own UI and Logic
    ├── analytics/         # Data breakdown and visual charts
    ├── app_shell/         # Main Navigation Container & Bottom App Bar
    ├── bills/             # Bill tracking and reminders
    ├── budget/            # Spending categories and limits
    ├── dashboard/         # Main overview screen
    ├── goals/             # Saving goals and milestones
    ├── profile/           # User settings and options
    └── transactions/      # Individual income/expense tracking
```

## 🚀 Getting Started

Follow these steps to get a local copy up and running:

### Prerequisites
- Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE such as [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/finxl.git
   cd finxl
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   Ensure you have a device connected or an emulator/simulator running.
   ```bash
   flutter run
   ```

## 📱 Screenshots

> **Coming Soon!**
> You can add screenshots of your Dashboard, Analytics, and Budget screens here by placing them in an `assets/images/` folder and linking them. For example: `<img src="assets/images/dashboard.png" width="200" />`

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
