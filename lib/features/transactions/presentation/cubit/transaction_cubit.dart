import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit(this._repository) : super(const TransactionState());

  final TransactionRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final config = await _repository.fetchConfig();
    emit(
      state.copyWith(
        status: LoadStatus.success,
        config: config,
        selectedCategoryId: config.categories.first.id,
      ),
    );
  }

  void selectType(TransactionType type) => emit(state.copyWith(type: type));

  void selectCategory(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void selectPaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void updateAmount(String amount) => emit(state.copyWith(amount: amount));

  void updateNote(String note) => emit(state.copyWith(note: note));

  void submit() {
    if (state.amount.trim().isEmpty || state.selectedCategoryId == null) {
      emit(state.copyWith(errorMessage: 'Enter an amount and choose a category.'));
      return;
    }

    emit(state.copyWith(errorMessage: null, submitted: true));
  }
}

class TransactionState extends Equatable {
  const TransactionState({
    this.status = LoadStatus.initial,
    this.config,
    this.type = TransactionType.expense,
    this.selectedCategoryId,
    this.paymentMethod = PaymentMethod.upi,
    this.amount = '',
    this.note = '',
    this.errorMessage,
    this.submitted = false,
  });

  final LoadStatus status;
  final TransactionFormConfig? config;
  final TransactionType type;
  final String? selectedCategoryId;
  final PaymentMethod paymentMethod;
  final String amount;
  final String note;
  final String? errorMessage;
  final bool submitted;

  TransactionState copyWith({
    LoadStatus? status,
    TransactionFormConfig? config,
    TransactionType? type,
    String? selectedCategoryId,
    PaymentMethod? paymentMethod,
    String? amount,
    String? note,
    String? errorMessage,
    bool? submitted,
  }) {
    return TransactionState(
      status: status ?? this.status,
      config: config ?? this.config,
      type: type ?? this.type,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      errorMessage: errorMessage,
      submitted: submitted ?? this.submitted,
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
        errorMessage,
        submitted,
      ];
}
