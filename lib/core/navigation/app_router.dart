import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/features/analytics/presentation/pages/analytics_page.dart';
import 'package:finxl/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:finxl/features/bills/presentation/pages/add_bill_page.dart';
import 'package:finxl/features/bills/presentation/pages/bills_page.dart';
import 'package:finxl/features/budget/presentation/pages/add_budget_page.dart';
import 'package:finxl/features/budget/presentation/pages/budget_page.dart';
import 'package:finxl/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:finxl/features/goals/presentation/pages/add_goal_page.dart';
import 'package:finxl/features/goals/presentation/pages/goals_page.dart';
import 'package:finxl/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finxl/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:finxl/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static const String profilePath = '/profile';
  static const String addTransactionPath = '/transaction/new';
  static const String addGoalPath = '/goals/new';
  static const String addBudgetPath = '/budget/new';
  static const String addBillPath = '/bills/new';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
  static final _analyticsNavigatorKey = GlobalKey<NavigatorState>();
  static final _goalsNavigatorKey = GlobalKey<NavigatorState>();
  static final _budgetNavigatorKey = GlobalKey<NavigatorState>();
  static final _billsNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppTab.dashboard.location,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: AppTab.dashboard.location,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _analyticsNavigatorKey,
            routes: [
              GoRoute(
                path: AppTab.analytics.location,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AnalyticsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _goalsNavigatorKey,
            routes: [
              GoRoute(
                path: AppTab.goals.location,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: GoalsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _budgetNavigatorKey,
            routes: [
              GoRoute(
                path: AppTab.budget.location,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: BudgetPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _billsNavigatorKey,
            routes: [
              GoRoute(
                path: AppTab.bills.location,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: BillsPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: addTransactionPath,
        pageBuilder: (context, state) => _buildPage(
          state,
          BlocProvider(
            create: (_) =>
                TransactionCubit(context.read<TransactionRepository>())..load(),
            child: const AddTransactionPage(),
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: addGoalPath,
        pageBuilder: (context, state) => _buildPage(state, const AddGoalPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: addBudgetPath,
        pageBuilder: (context, state) =>
            _buildPage(state, const AddBudgetPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: addBillPath,
        pageBuilder: (context, state) => _buildPage(state, const AddBillPage()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: profilePath,
        pageBuilder: (context, state) =>
            _buildPage(state, const ProfileSettingsPage()),
      ),
    ],
  );

  static CustomTransitionPage<void> _buildPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
