import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(this._repository) : super(const BudgetState());

  final BudgetRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final overview = await _repository.fetchOverview();
    emit(state.copyWith(status: LoadStatus.success, overview: overview));
  }
}

class BudgetState extends Equatable {
  const BudgetState({this.status = LoadStatus.initial, this.overview});

  final LoadStatus status;
  final BudgetOverview? overview;

  BudgetState copyWith({LoadStatus? status, BudgetOverview? overview}) {
    return BudgetState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
    );
  }

  @override
  List<Object?> get props => [status, overview];
}
