# FinXL

FinXL is a modern, responsive personal finance tracking application built with Flutter. It provides users with an intuitive interface to manage their financial ecosystem, track goals, monitor budgets, and oversee their bills.

## 📱 Features & Highlights

- **Dashboard:** At-a-glance view of total balance, monthly income/spending, and recent highlights.
- **Analytics:** In-depth breakdown of expenses and trends.
- **Goals Tracking:** Set and monitor financial goals with progress metrics.
- **Budgeting:** Organize spending into categories with defined limits.
- **Bills Management:** Keep track of upcoming bills and recurring payments.
- **Custom UI System:** A cohesive, sleek design system featuring glassmorphism elements, custom routing patterns, and responsive layouts.

## 🛠️ Architecture & Tech Stack

The application strictly adheres to a feature-based architecture pattern (similar to Clean Architecture) to ensure scalability, testability, and separation of concerns.

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** Dart
- **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) utilizing the `Cubit` pattern.
- **Routing:** Centralized component navigation utilizing a dynamic `IndexedStack` inside an `AppShell` for seamless tab transitions.
- **Core Dependencies:** 
  - `equatable` (Value equality)
  - `google_fonts` (Typography)

### Code Structure
Main feature modules include:
- `lib/features/analytics`
- `lib/features/app_shell` (Main Navigation Container)
- `lib/features/bills`
- `lib/features/budget`
- `lib/features/dashboard`
- `lib/features/goals`
- `lib/features/transactions`

## 🚀 Current Status

FinXL currently has a fully built presentation layer with robust, decoupled state management managed through Mock Repositories. The application is modular and prepared for the integration of a Business Logic and local Data persistence layer (using sqflite or Hive) to transition from static testing data to dynamic user data.

## ⚙️ Getting Started

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Clone this repository.
3. Keep the dependencies up to date:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
