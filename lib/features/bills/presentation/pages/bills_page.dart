import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/navigation/app_router.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/theme/theme_cubit.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/presentation/cubit/bills_cubit.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<BillsCubit, BillsState>(
          builder: (context, state) {
        if (state.status == LoadStatus.loading && state.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == LoadStatus.failure && state.overview == null) {
          return _FailureState(
            message: state.errorMessage ?? 'Unable to load reminders.',
            onRetry: () => context.read<BillsCubit>().load(),
          );
        }

        final overview = state.overview!;
        final reminders = _filterReminders(
          overview.reminders,
          state.selectedFilter,
        );
        final dueThisWeek = reminders
            .where((item) => item.sectionLabel == 'Due This Week')
            .toList(growable: false);
        final later = reminders
            .where((item) => item.sectionLabel == 'Later This Month')
            .toList(growable: false);
        final overdue = reminders
            .where((item) => item.sectionLabel == 'Overdue')
            .toList(growable: false);
        final upcoming = reminders
            .where((item) => item.sectionLabel == 'Upcoming')
            .toList(growable: false);

        return RefreshIndicator(
          onRefresh: () => context.read<BillsCubit>().refresh(),
          child: FinxlPageBody(
            maxWidth: 820,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'UPCOMING REMINDERS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(overview.scheduledAmount, decimals: 2),
                      style: GoogleFonts.manrope(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${overview.reminderCount} reminders',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Active reminders notify you 7 days before, 1 day before, and on the due date.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: BillFilter.values
                        .map((filter) {
                          final isSelected = filter == state.selectedFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChoiceChip(
                              label: Text(_filterLabel(filter)),
                              selected: isSelected,
                              onSelected: (_) => context
                                  .read<BillsCubit>()
                                  .selectFilter(filter),
                              selectedColor: AppTheme.primary,
                              labelStyle: GoogleFonts.inter(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: BorderSide(
                                color: AppTheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                              ),
                              backgroundColor: AppTheme.surfaceContainerLowest,
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildSection('OVERDUE', overdue),
                ..._buildSection('DUE THIS WEEK', dueThisWeek),
                ..._buildSection('LATER THIS MONTH', later),
                ..._buildSection('UPCOMING', upcoming),
                if (reminders.isEmpty)
                  SectionCard(
                    child: Text(
                      'No reminders match the selected filter yet.',
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.push(AppRouter.addBillPath),
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
                          'New Reminder',
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

  List<BillReminder> _filterReminders(
    List<BillReminder> reminders,
    BillFilter filter,
  ) {
    return reminders
        .where((reminder) {
          return switch (filter) {
            BillFilter.all => true,
            BillFilter.subscriptions =>
              reminder.category == BillCategory.subscription,
            BillFilter.bills => reminder.category == BillCategory.bill,
            BillFilter.emis => reminder.category == BillCategory.emi,
          };
        })
        .toList(growable: false);
  }

  String _filterLabel(BillFilter filter) {
    return switch (filter) {
      BillFilter.all => 'All',
      BillFilter.subscriptions => 'Subscriptions',
      BillFilter.bills => 'Bills',
      BillFilter.emis => 'EMIs',
    };
  }

  List<Widget> _buildSection(String title, List<BillReminder> reminders) {
    if (reminders.isEmpty) {
      return const [];
    }

    return [
      _SectionTitle(title: title),
      const SizedBox(height: 16),
      ...reminders.map(
        (reminder) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ReminderTile(reminder: reminder),
        ),
      ),
    ];
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppTheme.onSurfaceVariant,
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final BillReminder reminder;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentColor(reminder.accent);
    return Dismissible(
      key: Key('reminder_${reminder.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<BillsCubit>().deleteReminder(reminder.id);
        context.read<SyncBloc>().syncInBackground();
      },
      child: Opacity(
        opacity: reminder.isFaded ? 0.72 : 1,
        child: SectionCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(
            color: AppTheme.surfaceContainerHighest.withValues(alpha: 0.24),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(resolveIcon(reminder.iconKey), color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reminder.dueLabel}  •  ${formatCurrency(reminder.amount, decimals: 2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: reminder.isActive,
                onChanged: (_) =>
                    context.read<BillsCubit>().toggleReminder(reminder.id),
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.surfaceContainerHigh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
