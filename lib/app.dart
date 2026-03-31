import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:finxl/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:finxl/features/app_shell/presentation/cubit/navigation_cubit.dart';
import 'package:finxl/features/app_shell/presentation/pages/app_shell_page.dart';
import 'package:finxl/features/bills/data/repositories/bills_repository_impl.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:finxl/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/goals/data/repositories/goals_repository_impl.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:finxl/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinXL extends StatelessWidget {
  const FinXL({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DashboardRepository>(
          create: (_) => const DashboardRepositoryImpl(),
        ),
        RepositoryProvider<AnalyticsRepository>(
          create: (_) => const AnalyticsRepositoryImpl(),
        ),
        RepositoryProvider<GoalsRepository>(
          create: (_) => const GoalsRepositoryImpl(),
        ),
        RepositoryProvider<BudgetRepository>(
          create: (_) => const BudgetRepositoryImpl(),
        ),
        RepositoryProvider<BillsRepository>(
          create: (_) => const BillsRepositoryImpl(),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) => const TransactionRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(
            create: (context) => DashboardCubit(
              context.read<DashboardRepository>(),
            )..load(),
          ),
          BlocProvider(
            create: (context) => AnalyticsCubit(
              context.read<AnalyticsRepository>(),
            )..load(),
          ),
          BlocProvider(
            create: (context) => GoalsCubit(
              context.read<GoalsRepository>(),
            )..load(),
          ),
          BlocProvider(
            create: (context) => BudgetCubit(
              context.read<BudgetRepository>(),
            )..load(),
          ),
          BlocProvider(
            create: (context) => BillsCubit(context.read<BillsRepository>())..load(),
          ),
        ],
        child: MaterialApp(
          title: 'FinXL',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AppShellPage(),
        ),
      ),
    );
  }
}
