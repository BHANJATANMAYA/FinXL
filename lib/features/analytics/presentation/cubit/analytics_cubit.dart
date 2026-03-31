import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._repository) : super(const AnalyticsState());

  final AnalyticsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final overview = await _repository.fetchOverview();
    emit(state.copyWith(status: LoadStatus.success, overview: overview));
  }

  void selectPeriod(AnalyticsPeriod period) {
    emit(state.copyWith(selectedPeriod: period));
  }
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = LoadStatus.initial,
    this.overview,
    this.selectedPeriod = AnalyticsPeriod.monthly,
  });

  final LoadStatus status;
  final AnalyticsOverview? overview;
  final AnalyticsPeriod selectedPeriod;

  AnalyticsState copyWith({
    LoadStatus? status,
    AnalyticsOverview? overview,
    AnalyticsPeriod? selectedPeriod,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [status, overview, selectedPeriod];
}
