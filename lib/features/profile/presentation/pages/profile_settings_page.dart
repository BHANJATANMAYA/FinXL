import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:finxl/features/sms_detection/presentation/bloc/sms_detection_bloc.dart';
import 'package:finxl/features/sms_detection/presentation/pages/sms_transaction_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SmsDetectionBloc, SmsDetectionState>(
      listenWhen: (previous, current) =>
          (!previous.reviewPending && current.reviewPending) ||
          previous.errorMessage != current.errorMessage ||
          (!previous.savedTransaction && current.savedTransaction),
      listener: (context, state) {
        if (state.reviewPending) {
          SmsTransactionReviewScreen.showReviewSheet(context);
        } else if (state.savedTransaction) {
          context.read<DashboardCubit>().refresh();
        } else if (state.errorMessage != null &&
            state.status == LoadStatus.failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
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
                    const _SmartSmsDetectionTile(),
                    const SizedBox(height: 8),
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
                      subtitle:
                          'Schedule a bill, EMI, or subscription reminder.',
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
              const SizedBox(height: 24),
              SectionCard(
                child: _ActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  subtitle: 'Securely completely sign out.',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out of FinXL?',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }
}

class _SmartSmsDetectionTile extends StatelessWidget {
  const _SmartSmsDetectionTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsDetectionBloc, SmsDetectionState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: state.listening
                ? AppTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: state.listening
                    ? AppTheme.primary.withValues(alpha: 0.12)
                    : AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                state.listening
                    ? Icons.mark_chat_read_outlined
                    : Icons.sms_outlined,
                color: state.listening
                    ? AppTheme.primary
                    : AppTheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              'Smart SMS Detection',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              state.listening
                  ? 'Listening for new transactional financial SMS only.'
                  : 'Optional. Requires consent and ignores OTP or personal messages.',
              style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
            ),
            value: state.userConsented && state.listening,
            onChanged: state.status == LoadStatus.loading
                ? null
                : (enabled) async {
                    if (enabled) {
                      final accepted = await _showSmsConsentDialog(context);
                      if (accepted == true && context.mounted) {
                        context.read<SmsDetectionBloc>().enable();
                      }
                    } else {
                      context.read<SmsDetectionBloc>().disable();
                    }
                  },
          ),
        );
      },
    );
  }

  Future<bool?> _showSmsConsentDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enable Smart SMS Detection?',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'FinXL will listen only for new transactional financial SMS after permission is granted. OTP, promotional, and personal messages are ignored, and every detected transaction must be reviewed before it is saved.',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String displayName = 'FinXL User';
        if (state is AuthAuthenticated) {
          final user = state.user;
          // Use full name, fallback to email prefix if full name is missing
          displayName =
              user.fullName ??
              (user.email != null
                  ? user.email!.split('@').first
                  : 'FinXL User');
        }

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
                child: const Icon(
                  Icons.person,
                  size: 34,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Personal finance command center.',
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
      },
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
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : AppTheme.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDestructive
              ? color.withValues(alpha: 0.1)
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: isDestructive ? color : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
      ),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right),
    );
  }
}
