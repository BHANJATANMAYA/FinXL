import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._repository) : super(const AnalyticsState());

  final AnalyticsRepository _repository;

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
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: 'Unable to load analytics right now.',
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  void selectPeriod(AnalyticsPeriod period) {
    emit(state.copyWith(selectedPeriod: period));
  }
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = LoadStatus.initial,
    this.overview,
    this.selectedPeriod = AnalyticsPeriod.monthly,
    this.errorMessage,
  });

  final LoadStatus status;
  final AnalyticsOverview? overview;
  final AnalyticsPeriod selectedPeriod;
  final String? errorMessage;

  AnalyticsState copyWith({
    LoadStatus? status,
    AnalyticsOverview? overview,
    AnalyticsPeriod? selectedPeriod,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, overview, selectedPeriod, errorMessage];
}
