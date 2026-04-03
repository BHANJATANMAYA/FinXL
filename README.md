<div align="center">
  <h1>💰 FinXL</h1>
  <p><strong>A Modern, Intelligent, and Secure Personal Finance Tracking Application</strong></p>
  
  <p>
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
    <a href="https://supabase.com/"><img src="https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" /></a>
    <a href="https://pub.dev/packages/flutter_bloc"><img src="https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge" alt="BLoC" /></a>
  </p>
</div>

---

FinXL is a comprehensive personal finance tracking application built with Flutter and powered by Supabase. It provides users with an intuitive, beautifully designed interface to manage their financial ecosystem, track goals, monitor budgets, and oversee their bills—all while keeping data synced and secure.

## ✨ Key Features

- **🔐 Secure Authentication:** Seamlessly sign up and log in using Email/Password or **Google Sign-In**. 
- **🛡️ Password Security Score:** Real-time password strength indicator enforcing strict security standards (Symbol, Case-sensitivity, Numbers).
- **📊 Dashboard:** Get an at-a-glance view of your total balance, monthly income, spending, and recent transaction highlights.
- **📈 Analytics:** Dive into in-depth breakdowns of your expenses and identify spending trends over time.
- **🎯 Goals Tracking:** Set financial milestones, allocate funds, and monitor your progress towards achieving them.
- **💰 Budgeting:** Organize your spending into custom categories with defined monthly limits to stay on track.
- **🗓️ Bills Management:** Keep track of upcoming bills, manage recurring payments, and receive local notifications before due dates.
- **🎨 Custom UI System:** Enjoy a cohesive, sleek design system featuring glassmorphism elements, custom routing patterns, and fully responsive layouts.
- **☁️ Cloud Sync:** Powered by Supabase, your financial data is securely synced across devices while maintaining offline-first responsiveness.

## 🛠️ Architecture & Tech Stack

The application strictly adheres to a feature-based architecture pattern (inspired by Clean Architecture) to ensure scalability, testability, and separation of concerns.

### Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.11.1)
- **Backend-as-a-Service:** [Supabase](https://supabase.com/)
- **State Management:** `flutter_bloc` (utilizing the Cubit pattern)
- **Database:** `sqflite` (local) + Supabase (cloud)
- **Routing:** `go_router`
- **Environment Management:** `flutter_dotenv`
- **Authentication:** `supabase_flutter` & `google_sign_in`

## 📂 Project Structure

The codebase is organized by feature, making it highly modular:

```text
lib/
├── core/                  # Shared utilities, routing, and low-level services
│   ├── common/            # Shared UI components and logic
│   ├── database/          # Sqflite database setup & migrations
│   ├── navigation/        # App routing configuration
│   ├── notifications/     # Local notification service logic
│   ├── theme/             # Design system, colors, and typography
│   └── utils/             # Helper functions and extensions
└── features/              # Feature modules containing their own UI and Logic
    ├── auth/              # Authentication (Sign In, Sign Up, Google Auth)
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
- A Supabase account and project.
- Google Cloud Console project (for Google Auth).

### Configuration

1. **Create a `.env` file** in the root directory:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
   GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id
   ```

2. **Supabase Setup:**
   - Enable Email/Password Auth.
   - Enable Google Auth Provider.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/BHANJATANMAYA/finxl.git
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

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
