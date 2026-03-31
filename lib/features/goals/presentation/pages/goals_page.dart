import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/progress_bar.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/status_badge.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/presentation/cubit/goals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state.status != LoadStatus.success || state.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final overview = state.overview!;
        return FinxlPageBody(
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
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: overview.goals
                    .map((goal) => SizedBox(width: 430, child: _GoalCard(goal: goal)))
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
        );
      },
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
              if (goal.badgeLabel != null)
                StatusBadge(label: goal.badgeLabel!, accent: accent),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            goal.title,
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            goal.subtitle,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant),
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
                    style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
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
    return SectionCard(
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
            child: const Icon(Icons.add, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            'Create a New Goal',
            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Define your future, one focused milestone at a time.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
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
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800),
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
