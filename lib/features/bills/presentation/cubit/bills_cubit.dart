import 'package:equatable/equatable.dart';
import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/notifications/local_notification_service.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsCubit extends Cubit<BillsState> {
  BillsCubit(this._repository, this._notificationService)
    : super(const BillsState());

  final BillsRepository _repository;
  final LocalNotificationService _notificationService;

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
          errorMessage: 'Unable to load reminders right now.',
          isSaving: false,
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  void selectFilter(BillFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<bool> createBill({
    required String title,
    required double amount,
    required DateTime dueDate,
    required BillCategory category,
    required String recurrence,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final id = await _repository.addBill(
        Bill(
          title: title,
          amount: amount,
          dueDate: dueDate,
          isPaid: false,
          recurrence: recurrence,
          type: _typeValue(category),
          isActive: true,
        ),
      );
      final created = await _repository.getBillById(id);
      if (created != null) {
        await _notificationService.syncBillReminder(created);
      }
      await load(showLoading: false);
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Unable to save reminder.',
        ),
      );
      return false;
    }
  }

  Future<void> toggleReminder(String reminderId) async {
    final id = int.tryParse(reminderId);
    if (id == null) return;

    final current = await _repository.getBillById(id);
    if (current == null) return;

    final nextActive = !current.isActive;
    await _repository.toggleBillActive(id, nextActive);
    final updated = current.copyWith(isActive: nextActive);
    await _notificationService.syncBillReminder(updated);
    await load(showLoading: false);
  }

  String _typeValue(BillCategory category) {
    return switch (category) {
      BillCategory.subscription => 'subscription',
      BillCategory.bill => 'bill',
      BillCategory.emi => 'emi',
    };
  }
}

class BillsState extends Equatable {
  const BillsState({
    this.status = LoadStatus.initial,
    this.overview,
    this.selectedFilter = BillFilter.all,
    this.errorMessage,
    this.isSaving = false,
  });

  final LoadStatus status;
  final BillsOverview? overview;
  final BillFilter selectedFilter;
  final String? errorMessage;
  final bool isSaving;

  BillsState copyWith({
    LoadStatus? status,
    BillsOverview? overview,
    BillFilter? selectedFilter,
    String? errorMessage,
    bool? isSaving,
  }) {
    return BillsState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
    status,
    overview,
    selectedFilter,
    errorMessage,
    isSaving,
  ];
}
