import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit(this._repository) : super(const GoalsState());

  final GoalsRepository _repository;

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
          errorMessage: 'Unable to load goals right now.',
          isSaving: false,
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  Future<bool> createGoal({
    required String title,
    required double targetAmount,
    required double savedAmount,
    required DateTime deadline,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _repository.addGoal(
        Goal(
          title: title,
          targetAmount: targetAmount,
          currentAmount: savedAmount,
          deadline: deadline,
          color: 'secondary',
          icon: 'goals',
        ),
      );
      await load(showLoading: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(isSaving: false, errorMessage: 'Unable to save goal.'),
      );
      return false;
    }
  }

  Future<bool> updateGoal({
    required int id,
    required String title,
    required double targetAmount,
    required double savedAmount,
    required DateTime deadline,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await _repository.updateGoal(
        Goal(
          id: id,
          title: title,
          targetAmount: targetAmount,
          currentAmount: savedAmount,
          deadline: deadline,
          color: 'secondary',
          icon: 'goals',
        ),
      );
      await load(showLoading: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(isSaving: false, errorMessage: 'Unable to update goal.'),
      );
      return false;
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _repository.deleteGoal(id);
      await load(showLoading: false);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unable to delete goal.'));
    }
  }
}

class GoalsState extends Equatable {
  const GoalsState({
    this.status = LoadStatus.initial,
    this.overview,
    this.errorMessage,
    this.isSaving = false,
  });

  final LoadStatus status;
  final GoalsOverview? overview;
  final String? errorMessage;
  final bool isSaving;

  GoalsState copyWith({
    LoadStatus? status,
    GoalsOverview? overview,
    String? errorMessage,
    bool? isSaving,
  }) {
    return GoalsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage, isSaving];
}
