import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:finxl/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading || state.snapshot == null) {
      emit(state.copyWith(status: LoadStatus.loading, errorMessage: null));
    }

    try {
      final snapshot = await _repository.fetchSnapshot();
      emit(
        state.copyWith(
          status: LoadStatus.success,
          snapshot: snapshot,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Unable to load dashboard data.',
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  void dismissInsight(String insightId) {
    emit(
      state.copyWith(
        dismissedInsightIds: {...state.dismissedInsightIds, insightId},
      ),
    );
  }
}

class DashboardState extends Equatable {
  const DashboardState({
    this.status = LoadStatus.initial,
    this.snapshot,
    this.dismissedInsightIds = const {},
    this.errorMessage,
  });

  final LoadStatus status;
  final DashboardSnapshot? snapshot;
  final Set<String> dismissedInsightIds;
  final String? errorMessage;

  DashboardState copyWith({
    LoadStatus? status,
    DashboardSnapshot? snapshot,
    Set<String>? dismissedInsightIds,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      dismissedInsightIds: dismissedInsightIds ?? this.dismissedInsightIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    snapshot,
    dismissedInsightIds,
    errorMessage,
  ];
}
