import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/progress_bar.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/status_badge.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state.status == LoadStatus.loading && state.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.failure && state.overview == null) {
          return _FailureState(
            message: state.errorMessage ?? 'Unable to load budgets.',
            onRetry: () => context.read<BudgetCubit>().load(),
          );
        }

        final overview = state.overview!;
        final overspentList = overview.categories
            .where((item) => item.exceeded)
            .toList(growable: false);
        final regular = overview.categories
            .where((item) => !item.exceeded)
            .toList(growable: false);
        final remainingRatio = overview.totalBudget <= 0
            ? 0.0
            : overview.remainingBudget / overview.totalBudget;

        Color alertColor;
        Color alertBgColor;
        Color alertIconBgColor;
        IconData alertIcon;

        if (overview.alertTitle == 'Critical Alert') {
          alertColor = AppTheme.danger;
          alertBgColor = AppTheme.danger.withValues(alpha: 0.08);
          alertIconBgColor = AppTheme.danger.withValues(alpha: 0.15);
          alertIcon = Icons.warning_amber_rounded;
        } else if (overview.alertTitle == 'Heads Up') {
          alertColor = AppTheme.warning;
          alertBgColor = AppTheme.warning.withValues(alpha: 0.08);
          alertIconBgColor = AppTheme.warning.withValues(alpha: 0.15);
          alertIcon = Icons.info_outline_rounded;
        } else if (overview.alertTitle == 'No Budgets Yet') {
          alertColor = AppTheme.secondary;
          alertBgColor = AppTheme.secondary.withValues(alpha: 0.08);
          alertIconBgColor = AppTheme.secondary.withValues(alpha: 0.15);
          alertIcon = Icons.account_balance_wallet_outlined;
        } else {
          alertColor = AppTheme.primary;
          alertBgColor = AppTheme.primary.withValues(alpha: 0.08);
          alertIconBgColor = AppTheme.primary.withValues(alpha: 0.15);
          alertIcon = Icons.check_circle_outline_rounded;
        }

        return RefreshIndicator(
          onRefresh: () => context.read<BudgetCubit>().refresh(),
          child: FinxlPageBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MONTHLY BUDGET STATUS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatCurrency(overview.remainingBudget, decimals: 2),
                          style: GoogleFonts.manrope(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Left from ${formatCurrency(overview.totalBudget, decimals: 2)} total',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatPercent(remainingRatio * 100),
                          style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'REMAINING',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SectionCard(
                  color: alertBgColor,
                  border: Border(
                    left: BorderSide(color: alertColor, width: 4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: alertIconBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          alertIcon,
                          color: alertColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overview.alertTitle,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: alertColor,
                              ),
                            ),
                            Text(
                              overview.alertMessage,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: alertColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: regular
                      .map(
                        (category) => SizedBox(
                          width: 430,
                          child: _BudgetCard(category: category),
                        ),
                      )
                      .toList(growable: false),
                ),
                if (overspentList.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  ...overspentList.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ExceededCard(category: category),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                InkWell(
                  onTap: () => context.push(AppRouter.addBudgetPath),
                  borderRadius: BorderRadius.circular(28),
                  child: SectionCard(
                    color: AppTheme.surfaceContainerLow,
                    border: Border.all(color: AppTheme.surfaceContainerHighest),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create New Budget Category',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.category});

  final BudgetCategory category;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(category.accent);
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
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(resolveIcon(category.iconKey), color: accent),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(label: category.statusLabel, accent: accent),
                  const SizedBox(width: 4),
                  _BudgetMenuBuilder(category: category),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            category.title,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatCurrency(category.spent),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of ${formatCurrency(category.limit)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FinxlProgressBar(value: category.progress, color: accent),
        ],
      ),
    );
  }
}

class _ExceededCard extends StatelessWidget {
  const _ExceededCard({required this.category});

  final BudgetCategory category;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 620;
          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 116,
                      height: 116,
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.danger,
                        ),
                        backgroundColor: AppTheme.surfaceContainer,
                      ),
                    ),
                    Text(
                      formatPercent(category.progress * 100),
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isWide ? 28 : 0, height: isWide ? 0 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: isWide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: isWide
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                resolveIcon(category.iconKey),
                                color: AppTheme.danger,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category.title,
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        if (isWide)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(
                                label: 'Exceeded',
                                accent: AppTheme.danger,
                              ),
                              const SizedBox(width: 4),
                              _BudgetMenuBuilder(category: category),
                            ],
                          ),
                        if (!isWide)
                          _BudgetMenuBuilder(category: category),
                      ],
                    ),
                    if (!isWide) ...[
                      const SizedBox(height: 12),
                      StatusBadge(
                        label: 'Exceeded',
                        accent: AppTheme.danger,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'You have spent ${formatCurrency(category.spent, decimals: 2)}, which is ${formatCurrency(category.spent - category.limit, decimals: 2)} over your planned limit of ${formatCurrency(category.limit, decimals: 2)}.',
                      textAlign: isWide ? TextAlign.left : TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ADJUST LIMIT',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetMenuBuilder extends StatelessWidget {
  const _BudgetMenuBuilder({required this.category});

  final BudgetCategory category;

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
          context.push(AppRouter.addBudgetPath, extra: category);
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
                'Delete Budget',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              content: Text(
                'Are you sure you want to delete the ${category.title} budget?',
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
                    context.read<BudgetCubit>().deleteBudget(category.id!);
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
                'Edit Budget',
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
                'Delete Budget',
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

