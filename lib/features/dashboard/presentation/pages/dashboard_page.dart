import 'dart:math' as math;

import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/progress_bar.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/state_message_view.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/ai_categorization/domain/entities/insight_model.dart';
import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/transactions/presentation/widgets/transaction_list_card.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
        if (state.status == LoadStatus.loading && state.snapshot == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.failure && state.snapshot == null) {
          return StateMessageView(
            message: state.errorMessage ?? 'Unable to load dashboard data.',
            icon: Icons.dashboard_outlined,
            actionLabel: 'Retry',
            onAction: () => context.read<DashboardCubit>().load(),
          );
        }

        final snapshot = state.snapshot!;
        final visibleInsights = snapshot.smartInsights
            .where((item) => !state.dismissedInsightIds.contains(item.id))
            .toList(growable: false);
        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().refresh(),
          child: FinxlPageBody(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (snapshot.budgetAlerts.isNotEmpty) ...[
                  _BudgetAlertsCard(alerts: snapshot.budgetAlerts),
                  const SizedBox(height: 16),
                ],
                _BalanceSection(snapshot: snapshot),
                const SizedBox(height: 32),
                _MonthlyFlowCard(snapshot: snapshot),
                if (visibleInsights.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SmartInsightsSection(insights: visibleInsights),
                ],
                const SizedBox(height: 16),
                if (snapshot.activeGoal != null) ...[
                  _ActiveGoalCard(goal: snapshot.activeGoal!),
                  const SizedBox(height: 16),
                ],
                _WeeklyTrendCard(snapshot: snapshot),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 500 ? double.infinity : 342.0;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: snapshot.highlights
                          .map(
                            (highlight) => SizedBox(
                              width: width,
                              child: _HighlightCard(highlight: highlight),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
                if (snapshot.upcomingBills.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _UpcomingBillsCard(bills: snapshot.upcomingBills),
                ],
                if (snapshot.recentTransactions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _RecentTransactionsCard(
                    transactions: snapshot.recentTransactions,
                  ),
                ],
              ],
            ),
          ),
        );
          },
        );
      },
    );
  }
}

class _SmartInsightsSection extends StatelessWidget {
  const _SmartInsightsSection({required this.insights});

  final List<InsightModel> insights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SMART INSIGHTS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return SizedBox(
                width: 300,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 260 + index * 80),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(18 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: Dismissible(
                    key: ValueKey(insight.id),
                    direction: DismissDirection.up,
                    onDismissed: (_) => context
                        .read<DashboardCubit>()
                        .dismissInsight(insight.id),
                    child: _InsightCard(insight: insight),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final InsightModel insight;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(insight.accent);
    return SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  resolveIcon(insight.iconKey),
                  color: accent,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                '${(insight.confidence * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              insight.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.35,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final isPositive = snapshot.savedThisMonth >= 0;
    final badgeColor = isPositive ? AppTheme.primary : AppTheme.danger;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRouter.addTransactionPath),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(snapshot.totalBalance),
                    style: GoogleFonts.manrope(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRouter.transactionsHistoryPath),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: badgeColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPositive
                        ? 'You saved ${formatCurrency(snapshot.savedThisMonth)} this month'
                        : 'You spent ${formatCurrency(snapshot.savedThisMonth.abs())} more than earned',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyFlowCard extends StatelessWidget {
  const _MonthlyFlowCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: () => context.go('/analytics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MetricColumn(
                caption: 'MONTHLY FLOW',
                value: formatCurrency(snapshot.monthlyIncome),
                suffix: 'Income',
              ),
              _MetricColumn(
                caption: '',
                value: formatCurrency(snapshot.monthlySpent),
                suffix: 'Spent',
                accent: AppTheme.secondary,
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
          FinxlProgressBar(
            value: snapshot.remainingBudgetRatio < 0
                ? 0.0
                : snapshot.remainingBudgetRatio,
            gradient: AppTheme.primaryGradient,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snapshot.remainingBudgetRatio < 0
                    ? 'NO BUDGET SET'
                    : '${formatPercent(snapshot.remainingBudgetRatio * 100)} BUDGET REMAINING',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${snapshot.daysLeft} ${snapshot.daysLeft == 1 ? 'DAY' : 'DAYS'} LEFT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.caption,
    required this.value,
    required this.suffix,
    this.accent,
    this.alignEnd = false,
  });

  final String caption;
  final String value;
  final String suffix;
  final Color? accent;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (caption.isNotEmpty)
          Text(
            caption,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$value ',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            Text(
              suffix,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeeklyTrendCard extends StatelessWidget {
  const _WeeklyTrendCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final peak = snapshot.weeklyTrend.fold<double>(0, math.max);

    return SectionCard(
      onTap: () => context.go('/analytics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY TRENDS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Activity',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Icon(Icons.insights, color: AppTheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(snapshot.weeklyTrend.length, (index) {
                final value = snapshot.weeklyTrend[index];
                final isPeak = peak > 0 && value == peak;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPeak
                                ? AppTheme.primaryContainer
                                : AppTheme.surfaceContainerHigh,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(snapshot.weeklyTrendLabels.length, (index) {
              return Text(
                snapshot.weeklyTrendLabels[index],
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceVariant,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.highlight});

  final DashboardHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(highlight.accent);
    return SectionCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.go('/analytics'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(resolveIcon(highlight.iconKey), color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            highlight.title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            highlight.value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.transactions});

  final List<core.Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT TRANSACTIONS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRouter.transactionsHistoryPath),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TransactionListCard(transactions: transactions),
      ],
    );
  }
}

class _BudgetAlertsCard extends StatelessWidget {
  const _BudgetAlertsCard({required this.alerts});

  final List<Budget> alerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts
          .map((budget) {
            final isExceeded = budget.spentAmount > budget.limitAmount;
            final color = isExceeded ? AppTheme.danger : AppTheme.tertiary;
            final icon = isExceeded
                ? Icons.error_outline
                : Icons.warning_amber_rounded;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.go('/budget'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isExceeded
                                    ? 'Budget Exceeded'
                                    : 'Nearing Budget Limit',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              Text(
                                '${budget.categoryName} (${formatCurrency(budget.spentAmount)} / ${formatCurrency(budget.limitAmount)})',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _ActiveGoalCard extends StatelessWidget {
  const _ActiveGoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final ratio = FinanceLookups.safeRatio(
      goal.currentAmount,
      goal.targetAmount,
    );
    return SectionCard(
      onTap: () => context.go('/goals'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE GOAL',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Icon(Icons.track_changes, color: AppTheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (goal.icon != null && goal.icon!.isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      resolveIcon(goal.icon!),
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(goal.currentAmount)} of ${formatCurrency(goal.targetAmount)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(ratio * 100).round()}%',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FinxlProgressBar(value: ratio),
        ],
      ),
    );
  }
}

class _UpcomingBillsCard extends StatelessWidget {
  const _UpcomingBillsCard({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING BILLS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          onTap: () => context.go('/bills'),
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(bills.length, (index) {
              final bill = bills[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppTheme.tertiary,
                      ),
                    ),
                    title: Text(
                      bill.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Due ${FinanceLookups.formatShortDate(bill.dueDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.danger,
                      ),
                    ),
                    trailing: Text(
                      formatCurrency(bill.amount),
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (index < bills.length - 1)
                    const Divider(height: 1, indent: 80, endIndent: 16),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
