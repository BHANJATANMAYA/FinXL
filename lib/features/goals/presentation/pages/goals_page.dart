import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/progress_bar.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/status_badge.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<GoalsCubit, GoalsState>(
          builder: (context, state) {
        if (state.status == LoadStatus.loading && state.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.failure && state.overview == null) {
          return _FailureState(
            message: state.errorMessage ?? 'Unable to load goals.',
            onRetry: () => context.read<GoalsCubit>().load(),
          );
        }

        final overview = state.overview!;
        return RefreshIndicator(
          onRefresh: () => context.read<GoalsCubit>().refresh(),
          child: FinxlPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FINANCIAL JOURNEY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Goals',
                  style: GoogleFonts.manrope(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  overview.progressMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: overview.goals
                      .map(
                        (goal) =>
                            SizedBox(width: 430, child: _GoalCard(goal: goal)),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 24),
                const _AddGoalCard(),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 430,
                      child: _SummaryCard(
                        title: 'Total Saved',
                        value: formatCurrency(overview.totalSaved),
                        iconKey: 'savings',
                        accent: AppTheme.secondary,
                      ),
                    ),
                    SizedBox(
                      width: 430,
                      child: _SummaryCard(
                        title: 'Completed',
                        value: overview.completedMilestone,
                        iconKey: 'celebration',
                        accent: AppTheme.primary,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
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

class _FailureState extends StatelessWidget {
  const _FailureState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(goal.accent);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(resolveIcon(goal.iconKey), color: accent),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (goal.badgeLabel != null) ...[
                    StatusBadge(label: goal.badgeLabel!, accent: accent),
                    const SizedBox(width: 4),
                  ],
                  _GoalMenuBuilder(goal: goal),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            goal.title,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            goal.subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(goal.savedAmount),
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'OF ${formatCurrency(goal.targetAmount)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                formatPercent(goal.progress * 100),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FinxlProgressBar(
            value: goal.progress,
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.7)],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddGoalCard extends StatelessWidget {
  const _AddGoalCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRouter.addGoalPath),
      borderRadius: BorderRadius.circular(28),
      child: SectionCard(
        color: AppTheme.surfaceContainerLow,
        border: Border.all(color: AppTheme.surfaceContainerHighest),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.onSurface.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: AppTheme.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Create a New Goal',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Define your future, one focused milestone at a time.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.iconKey,
    required this.accent,
    this.isCompact = false,
  });

  final String title;
  final String value;
  final String iconKey;
  final Color accent;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: accent.withValues(alpha: 0.08),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(resolveIcon(iconKey), color: accent),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: isCompact ? 14 : 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
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

class _GoalMenuBuilder extends StatelessWidget {
  const _GoalMenuBuilder({required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppTheme.onSurfaceVariant),
      color: AppTheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          context.push(AppRouter.addGoalPath, extra: goal);
        } else if (value == 'delete') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppTheme.surfaceContainerLowest,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Delete Goal',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              content: Text(
                'Are you sure you want to delete the ${goal.title} goal?',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.onSurfaceVariant,
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<GoalsCubit>().deleteGoal(goal.id!);
                    ctx.pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: AppTheme.onSurface),
              const SizedBox(width: 12),
              Text(
                'Edit Goal',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
              const SizedBox(width: 12),
              Text(
                'Delete Goal',
                style: GoogleFonts.inter(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
