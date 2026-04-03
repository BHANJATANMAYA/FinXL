import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:finxl/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:finxl/features/auth/data/repositories/supabase_auth_repository_impl.dart';
import 'package:finxl/features/auth/domain/repositories/auth_repository.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class FinXL extends StatelessWidget {
  const FinXL({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = LocalNotificationService.instance;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => SupabaseAuthRepositoryImpl(
            Supabase.instance.client,
            googleWebClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
            googleIosClientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
          ),
        ),
        RepositoryProvider<DashboardRepository>(
          create: (_) => DashboardRepositoryImpl(),
        ),
        RepositoryProvider<AnalyticsRepository>(
          create: (_) => AnalyticsRepositoryImpl(),
        ),
        RepositoryProvider<GoalsRepository>(
          create: (_) => GoalsRepositoryImpl(),
        ),
        RepositoryProvider<BudgetRepository>(
          create: (_) => BudgetRepositoryImpl(),
        ),
        RepositoryProvider<BillsRepository>(
          create: (_) => BillsRepositoryImpl(),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) => TransactionRepositoryImpl(),
        ),
        RepositoryProvider<LocalNotificationService>.value(
          value: notificationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                DashboardCubit(context.read<DashboardRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                AnalyticsCubit(context.read<AnalyticsRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                GoalsCubit(context.read<GoalsRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                BudgetCubit(context.read<BudgetRepository>())..load(),
          ),
          BlocProvider(
            create: (context) => BillsCubit(
              context.read<BillsRepository>(),
              context.read<LocalNotificationService>(),
            )..load(),
          ),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              AppRouter.router.go(AppRouter.dashboardPath);
            } else if (state is AuthUnauthenticated) {
              AppRouter.router.go(AppRouter.welcomePath);
            }
          },
          child: MaterialApp.router(
            title: 'FinXL',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
