import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:finxl/features/transactions/presentation/cubit/transactions_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({super.key});

  @override
  State<TransactionsHistoryPage> createState() =>
      _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionsHistoryCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionsHistoryCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, List<core.Transaction>> _groupTransactionsByMonth(
      List<core.Transaction> transactions) {
    final Map<String, List<core.Transaction>> grouped = {};
    for (final transaction in transactions) {
      final month = _monthName(transaction.date.month);
      final key = '$month ${transaction.date.year}';
      grouped.putIfAbsent(key, () => []).add(transaction);
    }
    return grouped;
  }

  String _monthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Transactions',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: BlocBuilder<TransactionsHistoryCubit, TransactionsHistoryState>(
            builder: (context, state) {
              if (state.status == LoadStatus.initial ||
                  (state.status == LoadStatus.loading &&
                      state.transactions.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }

            if (state.status == LoadStatus.failure &&
                state.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'An error occurred.',
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          context.read<TransactionsHistoryCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.transactions.isEmpty) {
              return Center(
                child: Text(
                  'No transactions found.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            final grouped = _groupTransactionsByMonth(state.transactions);
            final keys = grouped.keys.toList();

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: keys.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= keys.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final key = keys[index];
                final transactions = grouped[key]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          key.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SectionCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: List.generate(
                            transactions.length,
                            (tIndex) {
                              final transaction = transactions[tIndex];
                              return Column(
                                children: [
                                  _HistoryListTile(transaction: transaction),
                                  if (tIndex < transactions.length - 1)
                                    const Divider(
                                      height: 1,
                                      indent: 80,
                                      endIndent: 16,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      ),
    );
  }
}

class _HistoryListTile extends StatelessWidget {
  const _HistoryListTile({required this.transaction});

  final core.Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final category = FinanceLookups.transactionCategory(
      transaction.categoryId,
    );
    final isIncome = transaction.type == core.TransactionType.income;
    final amountColor = isIncome ? AppTheme.primary : AppTheme.onSurface;
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          resolveIcon(category.iconKey),
          color: AppTheme.primary,
        ),
      ),
      title: Text(
        transaction.description,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        transaction.paymentMethod != 'N/A'
            ? '${FinanceLookups.formatShortDate(transaction.date)} • ${transaction.paymentMethod}'
            : FinanceLookups.formatShortDate(transaction.date),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '$prefix${formatCurrency(transaction.amount)}',
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: amountColor,
        ),
      ),
    );
  }
}
