import 'dart:math' as math;

import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/segmented_control.dart';
import 'package:finxl/core/presentation/widgets/status_badge.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';
import 'package:finxl/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading && state.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.failure && state.overview == null) {
          return _FailureState(
            message: state.errorMessage ?? 'Unable to load analytics.',
            onRetry: () => context.read<AnalyticsCubit>().load(),
          );
        }

        final overview = state.overview!;
        final insight = overview.insightFor(state.selectedPeriod);

        return RefreshIndicator(
          onRefresh: () => context.read<AnalyticsCubit>().refresh(),
          child: FinxlPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AnalyticsHeader(
                  insight: insight,
                  selectedPeriod: state.selectedPeriod,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _CategoryDistribution(
                              categories: overview.categories,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _SpendingTrendCard(
                              insight: insight,
                              categories: overview.categories,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _CategoryDistribution(categories: overview.categories),
                        const SizedBox(height: 24),
                        _SpendingTrendCard(
                          insight: insight,
                          categories: overview.categories,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: overview.insights
                      .map(
                        (item) => SizedBox(
                          width: 280,
                          child: _InsightCard(insight: item),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
          ),
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

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.insight, required this.selectedPeriod});

  final AnalyticsPeriodInsight insight;
  final AnalyticsPeriod selectedPeriod;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isWide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FINANCIAL INSIGHTS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(insight.headlineAmount, decimals: 2),
                  style: GoogleFonts.manrope(
                    fontSize: isWide ? 46 : 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  insight.comparisonLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            if (!isWide) const SizedBox(height: 20),
            FinxlSegmentedControl<AnalyticsPeriod>(
              value: selectedPeriod,
              options: const [
                SegmentedOption(
                  value: AnalyticsPeriod.monthly,
                  label: 'Monthly',
                ),
                SegmentedOption(value: AnalyticsPeriod.weekly, label: 'Weekly'),
              ],
              onChanged: context.read<AnalyticsCubit>().selectPeriod,
            ),
          ],
        );
      },
    );
  }
}

class _CategoryDistribution extends StatelessWidget {
  const _CategoryDistribution({required this.categories});

  final List<AnalyticsCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return SectionCard(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No category data available',
              style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }
    return SectionCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: RepaintBoundary(
              child: SizedBox(
                width: 208,
                height: 208,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(208),
                      painter: _DonutChartPainter(categories: categories),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatPercent(categories.first.percentage),
                          style: GoogleFonts.manrope(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          categories.first.label.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: categories
                .map((item) => _LegendItem(category: item))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.category});

  final AnalyticsCategory category;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(category.accent);
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingTrendCard extends StatelessWidget {
  const _SpendingTrendCard({required this.insight, required this.categories});

  final AnalyticsPeriodInsight insight;
  final List<AnalyticsCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return SectionCard(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No spending data available',
              style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }
    return SectionCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trends',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              StatusBadge(
                label: insight.trendLabel,
                accent: AppTheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(insight.trendValues.length, (index) {
                final value = insight.trendValues[index];
                final isHighest =
                    value ==
                    insight.trendValues.reduce((a, b) => a > b ? a : b);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: value,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isHighest
                                    ? AppTheme.primary.withValues(alpha: 0.18)
                                    : AppTheme.surfaceContainer,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                border: isHighest
                                    ? const Border(
                                        top: BorderSide(
                                          color: AppTheme.primary,
                                          width: 4,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.trendLabels[index],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isHighest
                              ? AppTheme.primary
                              : AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resolveIcon(
                      categories.first.accent == 'primary'
                          ? 'restaurant'
                          : 'savings',
                    ),
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOP SPENDING',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        categories.first.label,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatPercent(categories.first.percentage),
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final AnalyticsInsight insight;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(insight.accent);
    return SectionCard(
      color: accent.withValues(alpha: 0.08),
      border: Border.all(color: accent.withValues(alpha: 0.14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(resolveIcon(insight.iconKey), color: accent, size: 30),
          const SizedBox(height: 14),
          Text(
            insight.title,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.categories});

  final List<AnalyticsCategory> categories;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 24.0;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final backgroundPaint = Paint()
      ..color = AppTheme.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    var startAngle = -math.pi / 2;
    for (final category in categories) {
      final sweepAngle = (category.percentage / 100) * math.pi * 2;
      final paint = Paint()
        ..color = AppTheme.accentColor(category.accent)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + 0.05;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}
