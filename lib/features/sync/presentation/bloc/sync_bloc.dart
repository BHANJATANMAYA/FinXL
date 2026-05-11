import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:finxl/features/sync/domain/repositories/sync_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SyncViewStatus { idle, syncing, synced, failed, restoreAvailable }

class SyncBloc extends Cubit<SyncState> {
  SyncBloc(this._repository) : super(const SyncState()) {
    _retryTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncInBackground(),
    );
  }

  final SyncRepository _repository;
  Timer? _retryTimer;
  bool _isRunning = false;

  Future<void> checkRestoreAvailability() async {
    if (_isRunning) return;
    try {
      final available = await _repository.hasCloudBackup();
      if (available) {
        emit(
          state.copyWith(
            status: SyncViewStatus.restoreAvailable,
            restoreAvailable: true,
            errorMessage: null,
          ),
        );
      } else {
        await syncInBackground();
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: SyncViewStatus.failed,
          errorMessage: 'Unable to check cloud backup.',
        ),
      );
    }
  }

  Future<void> syncNow() => _runSync(showSyncing: true);

  Future<void> syncInBackground() => _runSync(showSyncing: false);

  Future<void> restore() async {
    if (_isRunning) return;
    _isRunning = true;
    emit(state.copyWith(status: SyncViewStatus.syncing, errorMessage: null));
    try {
      await _repository.restore();
      emit(
        state.copyWith(
          status: SyncViewStatus.synced,
          restoreAvailable: false,
          lastSyncedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SyncViewStatus.failed,
          errorMessage: 'Restore failed. Please try again.',
        ),
      );
    } finally {
      _isRunning = false;
    }
  }

  Future<void> skipRestore() async {
    await _repository.skipRestore();
    emit(
      state.copyWith(
        status: SyncViewStatus.idle,
        restoreAvailable: false,
        errorMessage: null,
      ),
    );
    await syncInBackground();
  }

  Future<void> _runSync({required bool showSyncing}) async {
    if (_isRunning || state.restoreAvailable) return;
    _isRunning = true;
    if (showSyncing) {
      emit(state.copyWith(status: SyncViewStatus.syncing, errorMessage: null));
    }
    try {
      await _repository.sync();
      emit(
        state.copyWith(
          status: SyncViewStatus.synced,
          lastSyncedAt: DateTime.now(),
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SyncViewStatus.failed,
          errorMessage: 'Sync failed. FinXL will retry in the background.',
        ),
      );
    } finally {
      _isRunning = false;
    }
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    return super.close();
  }
}

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncViewStatus.idle,
    this.restoreAvailable = false,
    this.lastSyncedAt,
    this.errorMessage,
  });

  final SyncViewStatus status;
  final bool restoreAvailable;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  SyncState copyWith({
    SyncViewStatus? status,
    bool? restoreAvailable,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      restoreAvailable: restoreAvailable ?? this.restoreAvailable,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    restoreAvailable,
    lastSyncedAt,
    errorMessage,
  ];
}
