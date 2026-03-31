import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsCubit extends Cubit<BillsState> {
  BillsCubit(this._repository) : super(const BillsState());

  final BillsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final overview = await _repository.fetchOverview();
    emit(state.copyWith(status: LoadStatus.success, overview: overview));
  }

  void selectFilter(BillFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  void toggleReminder(String reminderId) {
    final overview = state.overview;
    if (overview == null) {
      return;
    }

    final updated = overview.reminders
        .map(
          (reminder) => reminder.id == reminderId
              ? reminder.copyWith(isActive: !reminder.isActive)
              : reminder,
        )
        .toList(growable: false);

    emit(
      state.copyWith(
        overview: BillsOverview(
          scheduledAmount: overview.scheduledAmount,
          reminderCount: overview.reminderCount,
          reminders: updated,
        ),
      ),
    );
  }
}

class BillsState extends Equatable {
  const BillsState({
    this.status = LoadStatus.initial,
    this.overview,
    this.selectedFilter = BillFilter.all,
  });

  final LoadStatus status;
  final BillsOverview? overview;
  final BillFilter selectedFilter;

  BillsState copyWith({
    LoadStatus? status,
    BillsOverview? overview,
    BillFilter? selectedFilter,
  }) {
    return BillsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [status, overview, selectedFilter];
}
