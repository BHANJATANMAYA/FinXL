import 'package:finxl/core/navigation/app_tab.dart';
import 'package:finxl/core/presentation/widgets/finxl_bottom_nav.dart';
import 'package:finxl/core/presentation/widgets/finxl_top_bar.dart';
import 'package:finxl/features/analytics/presentation/pages/analytics_page.dart';
import 'package:finxl/features/app_shell/presentation/cubit/navigation_cubit.dart';
import 'package:finxl/features/bills/presentation/pages/bills_page.dart';
import 'package:finxl/features/budget/presentation/pages/budget_page.dart';
import 'package:finxl/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:finxl/features/goals/presentation/pages/goals_page.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finxl/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:finxl/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  static const List<Widget> _pages = [
    DashboardPage(),
    AnalyticsPage(),
    GoalsPage(),
    BudgetPage(),
    BillsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppTab>(
      builder: (context, currentTab) {
        return Scaffold(
          appBar: const FinxlTopBar(),
          extendBody: true,
          body: IndexedStack(index: currentTab.index, children: _pages),
          floatingActionButton: currentTab == AppTab.dashboard
              ? FloatingActionButton(
                  tooltip: 'Add transaction',
                  onPressed: () => _openComposer(context),
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: FinxlBottomNav(
            currentTab: currentTab,
            onTabSelected: context.read<NavigationCubit>().selectTab,
          ),
        );
      },
    );
  }

  void _openComposer(BuildContext context) {
    final repository = context.read<TransactionRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => TransactionCubit(repository)..load(),
          child: const AddTransactionPage(),
        ),
      ),
    );
  }
}
