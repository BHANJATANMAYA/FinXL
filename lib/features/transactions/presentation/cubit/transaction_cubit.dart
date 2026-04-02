import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit(this._repository) : super(TransactionState());

  final TransactionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, errorMessage: null));
    try {
      final config = await _repository.fetchConfig();
      emit(
        state.copyWith(
          status: LoadStatus.success,
          config: config,
          selectedCategoryId: config.categories.first.id,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Unable to load transaction form.',
        ),
      );
    }
  }

  void selectType(TransactionType type) {
    if (type == TransactionType.income &&
        state.paymentMethod == PaymentMethod.card) {
      emit(state.copyWith(type: type, paymentMethod: PaymentMethod.upi));
    } else {
      emit(state.copyWith(type: type));
    }
  }

  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void updateAmount(String amount) => emit(state.copyWith(amount: amount));

  void updateNote(String note) => emit(state.copyWith(note: note));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));

  Future<void> submit() async {
    final amount = double.tryParse(state.amount.trim());
    if (amount == null ||
        amount <= 0 ||
        (state.type == TransactionType.expense &&
            state.selectedCategoryId == null)) {
      emit(
        state.copyWith(
          errorMessage: 'Enter a valid amount and choose a category.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, errorMessage: null, submitted: false),
    );

    try {
      await _repository.addTransaction(
        core.Transaction(
          amount: amount,
          date: state.date,
          description: state.note.trim().isEmpty
              ? 'Transaction'
              : state.note.trim(),
          type: state.type == TransactionType.income
              ? core.TransactionType.income
              : core.TransactionType.expense,
          paymentMethod: _paymentMethodValue(state.paymentMethod),
          categoryId: state.type == TransactionType.income
              ? FinanceLookups.transactionCategoryDbId('income')
              : FinanceLookups.transactionCategoryDbId(
                  state.selectedCategoryId!,
                ),
        ),
      );
      emit(
        state.copyWith(
          isSubmitting: false,
          submitted: true,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Unable to save transaction.',
        ),
      );
    }
  }

  String _paymentMethodValue(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.upi => 'UPI',
      PaymentMethod.cash => 'Cash',
      PaymentMethod.card => 'Card',
    };
  }
}

class TransactionState extends Equatable {
  TransactionState({
    this.status = LoadStatus.initial,
    this.config,
    this.type = TransactionType.expense,
    this.selectedCategoryId,
    this.paymentMethod = PaymentMethod.upi,
    this.amount = '',
    this.note = '',
    DateTime? date,
    this.errorMessage,
    this.submitted = false,
    this.isSubmitting = false,
  }) : date = date ?? DateTime.now();

  final LoadStatus status;
  final TransactionFormConfig? config;
  final TransactionType type;
  final String? selectedCategoryId;
  final PaymentMethod paymentMethod;
  final String amount;
  final String note;
  final DateTime date;
  final String? errorMessage;
  final bool submitted;
  final bool isSubmitting;

  TransactionState copyWith({
    LoadStatus? status,
    TransactionFormConfig? config,
    TransactionType? type,
    String? selectedCategoryId,
    PaymentMethod? paymentMethod,
    String? amount,
    String? note,
    DateTime? date,
    String? errorMessage,
    bool? submitted,
    bool? isSubmitting,
  }) {
    return TransactionState(
      status: status ?? this.status,
      config: config ?? this.config,
      type: type ?? this.type,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      errorMessage: errorMessage,
      submitted: submitted ?? this.submitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    status,
    config,
    type,
    selectedCategoryId,
    paymentMethod,
    amount,
    note,
    date,
    errorMessage,
    submitted,
    isSubmitting,
  ];
}
