import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(this._repository) : super(const BudgetState());

  final BudgetRepository _repository;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading || state.overview == null) {
      emit(state.copyWith(status: LoadStatus.loading, errorMessage: null));
    }

    try {
      final overview = await _repository.fetchOverview();
      emit(
        state.copyWith(
          status: LoadStatus.success,
          overview: overview,
          errorMessage: null,
          isSaving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Unable to load budgets right now.',
          isSaving: false,
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  Future<bool> createBudget({
    required String categoryName,
    required double limitAmount,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _repository.addBudget(
        Budget(
          categoryName: categoryName,
          limitAmount: limitAmount,
          spentAmount: 0,
        ),
      );
      await load(showLoading: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(isSaving: false, errorMessage: 'Unable to save budget.'),
      );
      return false;
    }
  }

  Future<bool> updateBudget({
    required int id,
    required String categoryName,
    required double limitAmount,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _repository.updateBudget(
        Budget(
          id: id,
          categoryName: categoryName,
          limitAmount: limitAmount,
          spentAmount: 0,
        ),
      );
      await load(showLoading: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(isSaving: false, errorMessage: 'Unable to update budget.'),
      );
      return false;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      await load(showLoading: false);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unable to delete budget.'));
    }
  }
}

class BudgetState extends Equatable {
  const BudgetState({
    this.status = LoadStatus.initial,
    this.overview,
    this.errorMessage,
    this.isSaving = false,
  });

  final LoadStatus status;
  final BudgetOverview? overview;
  final String? errorMessage;
  final bool isSaving;

  BudgetState copyWith({
    LoadStatus? status,
    BudgetOverview? overview,
    String? errorMessage,
    bool? isSaving,
  }) {
    return BudgetState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage, isSaving];
}
