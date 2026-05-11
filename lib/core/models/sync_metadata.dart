enum SyncStatus { pending, synced, failed, deleted }

extension SyncStatusX on SyncStatus {
  String get value {
    return switch (this) {
      SyncStatus.pending => 'pending',
      SyncStatus.synced => 'synced',
      SyncStatus.failed => 'failed',
      SyncStatus.deleted => 'deleted',
    };
  }

  static SyncStatus fromValue(String? value) {
    return switch (value) {
      'synced' => SyncStatus.synced,
      'failed' => SyncStatus.failed,
      'deleted' => SyncStatus.deleted,
      'pending' || null || '' => SyncStatus.pending,
      _ => SyncStatus.pending,
    };
  }
}

class SyncMetadata {
  const SyncMetadata({
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.deletedAt,
    this.deviceId,
    this.cloudId,
  });

  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;
  final DateTime? deletedAt;
  final String? deviceId;
  final String? cloudId;

  Map<String, Object?> toMap() {
    return {
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sync_status': syncStatus.value,
      'deleted_at': deletedAt?.toIso8601String(),
      'device_id': deviceId,
      'cloud_id': cloudId,
    };
  }
}

DateTime? parseOptionalDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.parse(value);
  return null;
}

Map<String, Object?> withLocalSyncDefaults(Map<String, Object?> values) {
  final now = DateTime.now().toUtc().toIso8601String();
  return values
    ..['created_at'] = values['created_at'] ?? now
    ..['updated_at'] = now
    ..['sync_status'] = SyncStatus.pending.value
    ..['deleted_at'] = values['deleted_at'];
}
