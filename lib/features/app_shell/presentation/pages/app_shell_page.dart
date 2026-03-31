import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_bottom_nav.dart';
import 'package:finxl/core/presentation/widgets/finxl_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentTab = AppTab.values[navigationShell.currentIndex];

    return Scaffold(
      appBar: FinxlTopBar(
        onProfileTap: () => context.push(AppRouter.profilePath),
        onNotificationTap: () => context.go(AppTab.bills.location),
      ),
      extendBody: true,
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add transaction',
        onPressed: () => context.push(AppRouter.addTransactionPath),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: FinxlBottomNav(
        currentTab: currentTab,
        onTabSelected: (tab) {
          navigationShell.goBranch(
            tab.index,
            initialLocation: tab.index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
