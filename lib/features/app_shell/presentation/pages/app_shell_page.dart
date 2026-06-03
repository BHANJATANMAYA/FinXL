import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_bottom_nav.dart';
import 'package:finxl/core/presentation/widgets/finxl_navigation_rail.dart';
import 'package:finxl/core/presentation/widgets/finxl_top_bar.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:finxl/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentTab = AppTab.values[navigationShell.currentIndex];

    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (previous, current) =>
          (!previous.restoreAvailable && current.restoreAvailable) ||
          (previous.status == SyncViewStatus.syncing &&
              current.status == SyncViewStatus.synced),
      listener: (context, state) async {
        if (state.restoreAvailable) {
          await showRestoreDialog(context);
        } else if (state.status == SyncViewStatus.synced) {
          _refreshFeatureCubits(context);
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final bool isTablet = screenWidth >= 720;

          return Scaffold(
            appBar: FinxlTopBar(
              onProfileTap: () => context.push(AppRouter.profilePath),
              syncIndicator: const _TopBarSyncIndicator(),
            ),
            extendBody: !isTablet,
            body: Row(
              children: [
                if (isTablet) ...[
                  FinxlNavigationRail(
                    currentTab: currentTab,
                    onTabSelected: (tab) {
                      navigationShell.goBranch(
                        tab.index,
                        initialLocation: tab.index == navigationShell.currentIndex,
                      );
                    },
                  ),
                ],
                Expanded(
                  child: navigationShell,
                ),
              ],
            ),
            floatingActionButton: isTablet
                ? null
                : FloatingActionButton.extended(
                    tooltip: 'Add transaction',
                    onPressed: () => context.push(AppRouter.addTransactionPath),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
            bottomNavigationBar: isTablet
                ? null
                : FinxlBottomNav(
                    currentTab: currentTab,
                    onTabSelected: (tab) {
                      navigationShell.goBranch(
                        tab.index,
                        initialLocation: tab.index == navigationShell.currentIndex,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  static Future<void> showRestoreDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Restore previous FinXL data?',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'We found your previous FinXL backup. Restore your transactions, goals, budgets, reminders, and preferences to this device.',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SyncBloc>().skipRestore();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SyncBloc>().restore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _refreshFeatureCubits(BuildContext context) {
    context.read<DashboardCubit>().refresh();
    context.read<AnalyticsCubit>().load();
    context.read<GoalsCubit>().load();
    context.read<BudgetCubit>().load();
    context.read<BillsCubit>().load();
  }
}

class _TopBarSyncIndicator extends StatelessWidget {
  const _TopBarSyncIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return switch (state.status) {
          SyncViewStatus.syncing => const SizedBox(
            width: 34,
            height: 34,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          SyncViewStatus.failed => FinxlSyncIndicator(
            icon: Icons.cloud_off_outlined,
            color: AppTheme.warning,
            tooltip: 'Cloud sync failed. Tap to retry.',
            onTap: () {
              context.read<SyncBloc>().syncNow();
            },
          ),
          SyncViewStatus.restoreAvailable => FinxlSyncIndicator(
            icon: Icons.cloud_download_outlined,
            color: AppTheme.secondary,
            tooltip: 'Restore available. Tap to restore.',
            onTap: () => AppShellPage.showRestoreDialog(context),
          ),
          SyncViewStatus.synced || SyncViewStatus.idle => FinxlSyncIndicator(
            icon: Icons.cloud_done_outlined,
            color: AppTheme.primary,
            tooltip: 'Database synced to Cloud. Tap to sync again.',
            onTap: () {
              context.read<SyncBloc>().syncNow();
            },
          ),
        };
      },
    );
  }
}
