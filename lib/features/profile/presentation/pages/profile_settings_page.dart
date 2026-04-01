import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Profile & Settings',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: FinxlPageBody(
        maxWidth: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 16),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
                final balance = dashboardState.snapshot?.totalBalance ?? 0;
                return _QuickStatCard(
                  title: 'Current balance',
                  value: formatCurrency(balance),
                  icon: Icons.account_balance_wallet_outlined,
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<GoalsCubit, GoalsState>(
                    builder: (context, state) => _QuickStatCard(
                      title: 'Goals \ntracked',
                      value: '${state.overview?.goals.length ?? 0}',
                      icon: Icons.track_changes,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BlocBuilder<BillsCubit, BillsState>(
                    builder: (context, state) => _QuickStatCard(
                      title: 'Active reminders',
                      value: '${state.overview?.reminderCount ?? 0}',
                      icon: Icons.notifications_active_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActionTile(
                    icon: Icons.notifications_outlined,
                    title: 'Enable notifications',
                    subtitle: 'Request reminder permissions on this device.',
                    onTap: () async {
                      await LocalNotificationService.instance
                          .requestPermissions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Notification permissions requested.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _ActionTile(
                    icon: Icons.flag_outlined,
                    title: 'Add a new goal',
                    subtitle: 'Create a savings milestone.',
                    onTap: () => context.push(AppRouter.addGoalPath),
                  ),
                  _ActionTile(
                    icon: Icons.pie_chart_outline,
                    title: 'Create a budget',
                    subtitle: 'Set a monthly spending limit.',
                    onTap: () => context.push(AppRouter.addBudgetPath),
                  ),
                  _ActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Add a reminder',
                    subtitle: 'Schedule a bill, EMI, or subscription reminder.',
                    onTap: () => context.push(AppRouter.addBillPath),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                final remaining = state.overview?.remainingBudget ?? 0;
                return _QuickStatCard(
                  title: 'Budget remaining',
                  value: formatCurrency(remaining),
                  icon: Icons.savings_outlined,
                );
              },
            ),
            const SizedBox(height: 16),

            //todo : add logout button
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceContainer,
            ),
            child: const Icon(Icons.person, size: 34, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FinXL User',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Offline-first personal finance command center.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppTheme.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
