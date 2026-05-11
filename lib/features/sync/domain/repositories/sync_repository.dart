abstract class SyncRepository {
  Future<bool> hasCloudBackup();
  Future<void> sync();
  Future<void> restore();
  Future<void> skipRestore();
}
