<div align="center">
  <h1>💰 FinXL</h1>
  <p><strong>A Modern, Intelligent & Secure Personal Finance Tracking Application</strong></p>

  <p>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
    <a href="https://supabase.com/"><img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" /></a>
    <a href="https://pub.dev/packages/flutter_bloc"><img src="https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge" alt="BLoC" /></a>
    <img src="https://img.shields.io/badge/Version-2.4.0-brightgreen?style=for-the-badge" alt="Version" />
  </p>
</div>

---

FinXL is a comprehensive personal finance tracking app built with **Flutter** and powered by **Supabase**. It delivers a premium, beautifully designed interface to manage your entire financial ecosystem — from transactions and budgets to savings goals, bills, and AI-powered insights — all offline-first with seamless cloud sync.

## ✨ Features

### 🔐 Authentication & Security
- Email/Password and **Google Sign-In** support.
- Real-time **password strength meter** enforcing symbols, mixed case, and numbers.
- Session management with graceful sign-out.

### 🏠 Interactive Dashboard
- At-a-glance view of **Total Balance**, **Monthly Income vs. Spend**, and **Budget Remaining**.
- **Tappable widgets** — every card navigates directly to its relevant screen (Add Transaction, Analytics, Goals, Budget, Bills).
- **Budget Alerts** banner highlights overspent or near-limit categories with a tap-to-Budget shortcut.
- **Active Goal** progress card and **Upcoming Bills** preview.
- Dismissible **Smart Insights** carousel powered by the on-device AI engine.
- Pull-to-refresh for live data updates.

### 📈 Analytics
- Period selector (Monthly / Weekly).
- **Donut chart** category distribution with percentage breakdowns.
- **Spending trend bar chart** highlighting peak spend periods.
- Per-category insight cards with confidence scores.

### 🎯 Goals Tracking
- Create, edit, and delete savings goals with emoji icons and target amounts.
- Visual progress bars and percentage completion.
- Summary cards for Total Saved and Completed milestones.
- Goal reached celebrations via analytics insights.

### 💰 Budgeting
- Custom spending categories with monthly limits.
- Per-category spend tracking and progress bars.
- Dynamic alert banner (Critical / Heads Up / On Track) that adapts colors in both light and dark mode.
- Overspent category highlighting.

### 🗓️ Bills & Reminders
- Track bills, EMIs, and subscriptions with due dates.
- Filter by All / Subscriptions / Bills / EMIs.
- Sections: Overdue / Due This Week / Later This Month / Upcoming.
- **Local push notifications** scheduled per due date using `flutter_local_notifications`.

### 📩 SMS Auto-Detection
- Background SMS listener detects bank/payment messages.
- On-device **SMS Parser Engine** extracts amounts, merchants, and transaction types.
- **Review screen** lets users confirm, edit, or reject auto-detected transactions before they are saved.

### 🤖 AI-Powered Smart Insights
- `TransactionInsightEngine` generates on-device contextual insights from spending patterns.
- Confidence-scored insight cards surfaced on the Dashboard and Analytics screens.
- Insight dismissal persisted across sessions.

### ☁️ Cloud Sync
- Full backup and restore via **Supabase**.
- Sync indicator in the top bar with real-time status (syncing / synced / failed / restore available).
- One-tap **restore dialog** on first sign-in when cloud data is detected.

### 🎨 Theming & UI
- **Full Dark Mode / Light Mode** toggle, persisted via `shared_preferences`.
- Dynamic `ThemeCubit` — all screens (Dashboard, Analytics, Goals, Budget, Bills, App Shell) rebuild instantly on theme change.
- Glassmorphism bottom navigation with blur effect.
- Premium typography using **Manrope** + **Inter** font families.
- Smooth micro-animations and ink ripple interactions throughout.

---

## 🛠️ Architecture & Tech Stack

The codebase follows a **feature-based Clean Architecture** pattern for scalability, testability, and strict separation of concerns.

### Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (SDK `^3.11.1`) |
| Backend-as-a-Service | Supabase (`^2.12.2`) |
| State Management | `flutter_bloc` — Cubit pattern (`^9.1.1`) |
| Routing | `go_router` (`^17.1.0`) |
| Local Database | `sqflite` (`^2.4.2`) |
| Notifications | `flutter_local_notifications` (`^21.0.0`) + `timezone` |
| Authentication | `supabase_flutter` + `google_sign_in` |
| Fonts | `google_fonts`, Inter, Manrope |
| Permissions | `permission_handler` (`^11.3.1`) |
| Environment | `flutter_dotenv` (`^6.0.0`) |
| Preferences | `shared_preferences` (`^2.5.5`) |
| Splash / Icons | `flutter_native_splash`, `flutter_launcher_icons` |

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── common/            # Shared load status & enums
│   ├── database/          # Sqflite setup, migrations & local service
│   ├── models/            # Core domain models (Transaction, Budget, Goal, Bill)
│   ├── navigation/        # GoRouter config & app tabs
│   ├── notifications/     # LocalNotificationService (schedule / cancel)
│   ├── presentation/
│   │   └── widgets/       # Reusable UI: SectionCard, ProgressBar, BottomNav, TopBar…
│   ├── theme/
│   │   ├── app_theme.dart # Design tokens, light/dark ThemeData, cardDecoration
│   │   └── theme_cubit.dart # ThemeCubit — drives app-wide theme toggling
│   └── utils/             # Formatters, FinanceLookups, IconMapper, BudgetSpending
│
└── features/
    ├── ai_categorization/ # TransactionInsightEngine — on-device smart insights
    ├── analytics/         # Analytics overview, cubit, charts
    ├── app_shell/         # Scaffold, BottomNav, sync indicator
    ├── auth/              # Sign In, Sign Up, Forgot Password, Google Auth
    ├── bills/             # Bill reminders, filter, add/edit
    ├── budget/            # Budget categories, limits, add/edit
    ├── dashboard/         # Home overview, snapshot, interactive cards
    ├── goals/             # Savings goals, milestones, add/edit
    ├── profile/           # Settings, dark mode toggle, notifications, privacy policy
    ├── sms_detection/     # SMS listener, parser engine, transaction mapper, review UI
    ├── sync/              # Supabase backup / restore service & BLoC
    └── transactions/      # Add/edit transaction, history page
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (≥ 3.11.1)
- A [Supabase](https://supabase.com/) project with Email and Google Auth enabled
- A Google Cloud Console project for Google Sign-In

### Configuration

1. **Create a `.env` file** in the project root:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
   GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
   ```

2. **Supabase Setup:**
   - Enable **Email/Password** auth provider.
   - Enable **Google** auth provider and add your OAuth credentials.

### Installation

```bash
# Clone the repository
git clone https://github.com/BHANJATANMAYA/finxl.git
cd finxl

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

---

## 🤝 Contributing

Contributions are welcome! Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
