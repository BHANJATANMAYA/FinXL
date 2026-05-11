import 'package:finxl/features/sync/data/services/sync_service.dart';
import 'package:finxl/features/sync/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl(this._syncService);

  final SyncService _syncService;

  @override
  Future<bool> hasCloudBackup() => _syncService.hasCloudBackup();

  @override
  Future<void> restore() => _syncService.restore();

  @override
  Future<void> skipRestore() => _syncService.skipRestore();

  @override
  Future<void> sync() => _syncService.sync();
}
