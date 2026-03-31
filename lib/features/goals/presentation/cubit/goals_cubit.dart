import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit(this._repository) : super(const GoalsState());

  final GoalsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final overview = await _repository.fetchOverview();
    emit(state.copyWith(status: LoadStatus.success, overview: overview));
  }
}

class GoalsState extends Equatable {
  const GoalsState({this.status = LoadStatus.initial, this.overview});

  final LoadStatus status;
  final GoalsOverview? overview;

  GoalsState copyWith({LoadStatus? status, GoalsOverview? overview}) {
    return GoalsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
    );
  }

  @override
  List<Object?> get props => [status, overview];
}
