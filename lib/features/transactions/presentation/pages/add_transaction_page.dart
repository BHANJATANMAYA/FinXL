import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/presentation/widgets/segmented_control.dart';
import 'package:finxl/core/presentation/widgets/state_message_view.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:finxl/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:finxl/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:finxl/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';
import 'package:finxl/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionCubit, TransactionState>(
      listenWhen: (previous, current) =>
          previous.submitted != current.submitted ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.submitted) {
          context.read<DashboardCubit>().refresh();
          context.read<AnalyticsCubit>().refresh();
          context.read<BudgetCubit>().refresh();
          // Push the new transaction to Supabase immediately
          context.read<SyncBloc>().syncInBackground();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
          title: Text(
            'Add Transaction',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SizedBox(
                height: 60,
                child: BlocSelector<TransactionCubit, TransactionState, bool>(
                  selector: (state) => state.isSubmitting,
                  builder: (context, isSubmitting) {
                    return FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : context.read<TransactionCubit>().submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Add Transaction',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        body:
            BlocSelector<
              TransactionCubit,
              TransactionState,
              ({LoadStatus status, TransactionFormConfig? config})
            >(
              selector: (state) => (status: state.status, config: state.config),
              builder: (context, viewState) {
                if (viewState.config == null) {
                  if (viewState.status == LoadStatus.failure) {
                    return StateMessageView(
                      message: 'Unable to load transaction form.',
                      icon: Icons.receipt_long_outlined,
                      actionLabel: 'Retry',
                      onAction: () => context.read<TransactionCubit>().load(),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                return const _TransactionFormContent();
              },
            ),
      ),
    );
  }
}

class _TransactionFormContent extends StatelessWidget {
  const _TransactionFormContent();

  @override
  Widget build(BuildContext context) {
    return FinxlPageBody(
      maxWidth: 760,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TransactionTypeSelector(),
          SizedBox(height: 40),
          _AmountField(),
          SizedBox(height: 24),
          _DateSelector(),
          SizedBox(height: 40),
          _CategorySection(),
          _PaymentMethodsSection(),
          SizedBox(height: 32),
          _NoteField(),
        ],
      ),
    );
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  const _TransactionTypeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TransactionCubit, TransactionState, TransactionType>(
      selector: (state) => state.type,
      builder: (context, type) {
        return FinxlSegmentedControl<TransactionType>(
          value: type,
          options: const [
            SegmentedOption(value: TransactionType.expense, label: 'Expense'),
            SegmentedOption(value: TransactionType.income, label: 'Income'),
          ],
          onChanged: context.read<TransactionCubit>().selectType,
        );
      },
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'AMOUNT',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 4),
              child: Text(
                '₹',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                key: const Key('amount-field'),
                onChanged: context.read<TransactionCubit>().updateAmount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: GoogleFonts.manrope(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  hintText: '0',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 96,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TransactionCubit, TransactionState, DateTime>(
      selector: (state) => state.date,
      builder: (context, selectedDate) {
        return SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: AppTheme.surfaceContainerLow,
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Transaction date'),
            subtitle: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (selected != null && context.mounted) {
                context.read<TransactionCubit>().updateDate(selected);
              }
            },
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TransactionCubit,
      TransactionState,
      ({
        TransactionFormConfig? config,
        TransactionType type,
        String? selectedCategoryId,
      })
    >(
      selector: (state) => (
        config: state.config,
        type: state.type,
        selectedCategoryId: state.selectedCategoryId,
      ),
      builder: (context, viewState) {
        if (viewState.config == null ||
            viewState.type != TransactionType.expense) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryGrid(
              config: viewState.config!,
              selectedCategoryId: viewState.selectedCategoryId,
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.config, required this.selectedCategoryId});

  final TransactionFormConfig config;
  final String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final expenseCategories = config.categories
        .where((category) => category.id != 'income')
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 520 ? 4 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseCategories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.84,
              ),
              itemBuilder: (context, index) {
                final category = expenseCategories[index];
                final isSelected = category.id == selectedCategoryId;
                return InkWell(
                  onTap: () => context.read<TransactionCubit>().selectCategory(
                    category.id,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryContainer.withValues(
                                    alpha: 0.22,
                                  )
                                : AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            resolveIcon(category.iconKey),
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.onSurfaceVariant,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PaymentMethodsSection extends StatelessWidget {
  const _PaymentMethodsSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TransactionCubit,
      TransactionState,
      ({
        TransactionFormConfig? config,
        TransactionType type,
        PaymentMethod paymentMethod,
      })
    >(
      selector: (state) => (
        config: state.config,
        type: state.type,
        paymentMethod: state.paymentMethod,
      ),
      builder: (context, viewState) {
        final config = viewState.config;
        if (config == null) {
          return const SizedBox.shrink();
        }

        final methods = viewState.type == TransactionType.income
            ? config.paymentMethods
                  .where((method) => method != PaymentMethod.card)
                  .toList(growable: false)
            : config.paymentMethods;

        return _PaymentMethods(
          methods: methods,
          selected: viewState.paymentMethod,
        );
      },
    );
  }
}

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods({required this.methods, required this.selected});

  final List<PaymentMethod> methods;
  final PaymentMethod selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: methods
              .map((method) {
                final isSelected = method == selected;
                final label = switch (method) {
                  PaymentMethod.upi => 'UPI',
                  PaymentMethod.cash => 'Cash',
                  PaymentMethod.card => 'Card',
                };
                final iconKey = switch (method) {
                  PaymentMethod.upi => 'upi',
                  PaymentMethod.cash => 'cash',
                  PaymentMethod.card => 'card',
                };
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        resolveIcon(iconKey),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => context
                      .read<TransactionCubit>()
                      .selectPaymentMethod(method),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceContainerLowest,
                  labelStyle: GoogleFonts.inter(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  side: BorderSide(
                    color: AppTheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppTheme.surfaceContainerLow,
      child: TextField(
        onChanged: context.read<TransactionCubit>().updateNote,
        maxLines: 3,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.edit_note),
          hintText: 'Add a quick note...',
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
