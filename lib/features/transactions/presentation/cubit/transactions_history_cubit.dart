import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsHistoryState extends Equatable {
  const TransactionsHistoryState({
    this.status = LoadStatus.initial,
    this.transactions = const [],
    this.errorMessage,
    this.hasReachedMax = false,
  });

  final LoadStatus status;
  final List<core.Transaction> transactions;
  final String? errorMessage;
  final bool hasReachedMax;

  TransactionsHistoryState copyWith({
    LoadStatus? status,
    List<core.Transaction>? transactions,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return TransactionsHistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage, hasReachedMax];
}

class TransactionsHistoryCubit extends Cubit<TransactionsHistoryState> {
  TransactionsHistoryCubit(this._repository)
      : super(const TransactionsHistoryState());

  final TransactionRepository _repository;
  static const int _limit = 50;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, errorMessage: null));
    try {
      final transactions = await _repository.getTransactions(
        limit: _limit,
        offset: 0,
      );
      emit(
        state.copyWith(
          status: LoadStatus.success,
          transactions: transactions,
          hasReachedMax: transactions.length < _limit,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Failed to load transaction history.',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == LoadStatus.loading) return;

    try {
      final additionalTransactions = await _repository.getTransactions(
        limit: _limit,
        offset: state.transactions.length,
      );

      if (additionalTransactions.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            transactions: List.of(state.transactions)..addAll(additionalTransactions),
            hasReachedMax: additionalTransactions.length < _limit,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Failed to load more transactions.',
        ),
      );
    }
  }
}
