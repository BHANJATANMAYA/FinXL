import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/presentation/widgets/state_message_view.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/transactions/presentation/cubit/transactions_history_cubit.dart';
import 'package:finxl/features/transactions/presentation/widgets/transaction_list_card.dart';
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
    List<core.Transaction> transactions,
  ) {
    final grouped = <String, List<core.Transaction>>{};
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
      'December',
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
          child:
              BlocBuilder<TransactionsHistoryCubit, TransactionsHistoryState>(
                builder: (context, state) {
                  if (state.status == LoadStatus.initial ||
                      (state.status == LoadStatus.loading &&
                          state.transactions.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == LoadStatus.failure &&
                      state.transactions.isEmpty) {
                    return StateMessageView(
                      message:
                          state.errorMessage ??
                          'Failed to load transaction history.',
                      icon: Icons.receipt_long_outlined,
                      actionLabel: 'Retry',
                      onAction: () =>
                          context.read<TransactionsHistoryCubit>().load(),
                    );
                  }

                  if (state.transactions.isEmpty) {
                    return const StateMessageView(
                      message: 'No transactions found.',
                      icon: Icons.inbox_outlined,
                    );
                  }

                  final grouped = _groupTransactionsByMonth(state.transactions);
                  final keys = grouped.keys.toList(growable: false);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
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
                              padding: const EdgeInsets.only(
                                left: 8,
                                bottom: 16,
                              ),
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
                            TransactionListCard(transactions: transactions),
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
