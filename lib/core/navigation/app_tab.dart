enum AppTab { dashboard, analytics, goals, budget, bills }

extension AppTabX on AppTab {
  String get location {
    return switch (this) {
      AppTab.dashboard => '/dashboard',
      AppTab.analytics => '/analytics',
      AppTab.goals => '/goals',
      AppTab.budget => '/budget',
      AppTab.bills => '/bills',
    };
  }

  String get label {
    return switch (this) {
      AppTab.dashboard => 'HOME',
      AppTab.analytics => 'INSIGHTS',
      AppTab.goals => 'GOALS',
      AppTab.budget => 'BUDGET',
      AppTab.bills => 'BILLS',
    };
  }

  static AppTab fromLocation(String location) {
    if (location.startsWith('/analytics')) return AppTab.analytics;
    if (location.startsWith('/goals')) return AppTab.goals;
    if (location.startsWith('/budget')) return AppTab.budget;
    if (location.startsWith('/bills')) return AppTab.bills;
    return AppTab.dashboard;
  }
}
