import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:finxl/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final snapshot = await _repository.fetchSnapshot();
    emit(state.copyWith(status: LoadStatus.success, snapshot: snapshot));
  }
}

class DashboardState extends Equatable {
  const DashboardState({this.status = LoadStatus.initial, this.snapshot});

  final LoadStatus status;
  final DashboardSnapshot? snapshot;

  DashboardState copyWith({LoadStatus? status, DashboardSnapshot? snapshot}) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  @override
  List<Object?> get props => [status, snapshot];
}
