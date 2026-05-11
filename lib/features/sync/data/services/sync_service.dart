import 'dart:math';

import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/sync_metadata.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  SyncService({
    required SupabaseClient supabaseClient,
    LocalDatabaseService? databaseService,
  }) : _supabase = supabaseClient,
       _databaseService = databaseService ?? LocalDatabaseService.instance;

  final SupabaseClient _supabase;
  final LocalDatabaseService _databaseService;

  static const _lastRestorePromptUserKey = 'last_restore_prompt_user';
  static const _deviceIdKey = 'device_id';

  static const List<_SyncTableConfig> _tables = [
    _SyncTableConfig(
      localTable: LocalDatabaseService.transactionsTable,
      cloudTable: 'transactions',
      excludedCloudColumns: {'sms_raw_body', 'cloud_id'},
      boolColumns: {'is_auto_detected'},
      dateColumns: {'date', 'created_at', 'updated_at', 'deleted_at'},
    ),
    _SyncTableConfig(
      localTable: LocalDatabaseService.goalsTable,
      cloudTable: 'goals',
      excludedCloudColumns: {'cloud_id'},
      dateColumns: {'deadline', 'created_at', 'updated_at', 'deleted_at'},
    ),
    _SyncTableConfig(
      localTable: LocalDatabaseService.budgetsTable,
      cloudTable: 'budgets',
      excludedCloudColumns: {'cloud_id'},
      dateColumns: {'created_at', 'updated_at', 'deleted_at'},
    ),
    _SyncTableConfig(
      localTable: LocalDatabaseService.billsTable,
      cloudTable: 'reminders',
      excludedCloudColumns: {'cloud_id'},
      boolColumns: {'is_paid', 'is_active'},
      dateColumns: {'due_date', 'created_at', 'updated_at', 'deleted_at'},
    ),
    _SyncTableConfig(
      localTable: LocalDatabaseService.userPreferencesTable,
      cloudTable: 'user_preferences',
      excludedCloudColumns: {'cloud_id'},
      boolColumns: {'smart_sms_detection_enabled', 'notifications_enabled'},
      dateColumns: {'created_at', 'updated_at', 'deleted_at'},
    ),
  ];

  Future<bool> hasCloudBackup() async {
    final userId = _requireUserId();
    final promptedUserId = await _readMeta(_lastRestorePromptUserKey);
    if (promptedUserId == userId) return false;

    for (final table in _tables) {
      final rows = await _supabase
          .from(table.cloudTable)
          .select('id')
          .eq('user_id', userId)
          .limit(1);
      if (rows.isNotEmpty) return true;
    }
    await _writeMeta(_lastRestorePromptUserKey, userId);
    return false;
  }

  Future<void> sync() async {
    final userId = _requireUserId();
    final deviceId = await _deviceId();
    await _ensurePreferencesRow(userId: userId, deviceId: deviceId);
    for (final table in _tables) {
      await _pushPending(table, userId: userId, deviceId: deviceId);
      await _pullCloudRows(table, userId: userId);
    }
  }

  Future<void> restore() async {
    final userId = _requireUserId();
    await _writeMeta(_lastRestorePromptUserKey, userId);
    for (final table in _tables) {
      await _pullCloudRows(table, userId: userId, forceCloud: true);
    }
  }

  Future<void> skipRestore() async {
    await _writeMeta(_lastRestorePromptUserKey, _requireUserId());
  }

  Future<void> _pushPending(
    _SyncTableConfig table, {
    required String userId,
    required String deviceId,
  }) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      table.localTable,
      where: 'sync_status IN (?, ?, ?)',
      whereArgs: [
        SyncStatus.pending.value,
        SyncStatus.failed.value,
        SyncStatus.deleted.value,
      ],
    );

    for (final row in rows) {
      final payload = table.toCloudPayload(
        row,
        userId: userId,
        deviceId: deviceId,
      );
      final cloudId = row['cloud_id'] as String?;
      try {
        Map<String, dynamic> saved;
        if (cloudId == null || cloudId.isEmpty) {
          saved = await _supabase
              .from(table.cloudTable)
              .insert(payload)
              .select('id, updated_at')
              .single();
        } else {
          saved = await _supabase
              .from(table.cloudTable)
              .update(payload)
              .eq('id', cloudId)
              .select('id, updated_at')
              .single();
        }
        await db.update(
          table.localTable,
          {
            'cloud_id': saved['id'] as String,
            'user_id': userId,
            'device_id': deviceId,
            'sync_status': SyncStatus.synced.value,
            'updated_at':
                saved['updated_at'] as String? ??
                row['updated_at'] as String? ??
                DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      } catch (_) {
        await db.update(
          table.localTable,
          {'sync_status': SyncStatus.failed.value},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
        rethrow;
      }
    }
  }

  Future<void> _pullCloudRows(
    _SyncTableConfig table, {
    required String userId,
    bool forceCloud = false,
  }) async {
    final db = await _databaseService.database;
    final cloudRows = await _supabase
        .from(table.cloudTable)
        .select()
        .eq('user_id', userId)
        .order('updated_at');

    for (final cloudRow in cloudRows) {
      final cloudId = cloudRow['id'] as String;
      final localRows = await db.query(
        table.localTable,
        where: 'cloud_id = ? OR id = ?',
        whereArgs: [cloudId, cloudRow['local_id']],
        limit: 1,
      );
      final localRow = localRows.isEmpty ? null : localRows.first;
      if (localRow != null && !forceCloud) {
        final localUpdated = parseOptionalDate(localRow['updated_at']);
        final cloudUpdated = parseOptionalDate(cloudRow['updated_at']);
        final localIsNewer =
            localUpdated != null &&
            cloudUpdated != null &&
            localUpdated.isAfter(cloudUpdated);
        final localPending =
            localRow['sync_status'] == SyncStatus.pending.value ||
            localRow['sync_status'] == SyncStatus.failed.value;
        if (localPending && localIsNewer) continue;
      }

      final localValues = table.toLocalPayload(cloudRow);
      if (localRow == null) {
        await db.insert(
          table.localTable,
          localValues,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        await db.update(
          table.localTable,
          localValues..remove('id'),
          where: 'id = ?',
          whereArgs: [localRow['id']],
        );
      }
    }
  }

  Future<void> _ensurePreferencesRow({
    required String userId,
    required String deviceId,
  }) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      LocalDatabaseService.userPreferencesTable,
      where: 'deleted_at IS NULL',
      limit: 1,
    );
    if (rows.isNotEmpty) return;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert(LocalDatabaseService.userPreferencesTable, {
      'user_id': userId,
      'smart_sms_detection_enabled': 0,
      'notifications_enabled': 0,
      'currency_code': 'INR',
      'created_at': now,
      'updated_at': now,
      'sync_status': SyncStatus.pending.value,
      'device_id': deviceId,
    });
  }

  String _requireUserId() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('User must be signed in to sync.');
    }
    return userId;
  }

  Future<String> _deviceId() async {
    final existing = await _readMeta(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final id = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((part) => part.toRadixString(16).padLeft(2, '0')).join();
    await _writeMeta(_deviceIdKey, id);
    return id;
  }

  Future<String?> _readMeta(String key) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      LocalDatabaseService.syncMetaTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> _writeMeta(String key, String value) async {
    final db = await _databaseService.database;
    await db.insert(
      LocalDatabaseService.syncMetaTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class _SyncTableConfig {
  const _SyncTableConfig({
    required this.localTable,
    required this.cloudTable,
    required this.excludedCloudColumns,
    this.boolColumns = const {},
    this.dateColumns = const {},
  });

  final String localTable;
  final String cloudTable;
  final Set<String> excludedCloudColumns;
  final Set<String> boolColumns;
  final Set<String> dateColumns;

  Map<String, Object?> toCloudPayload(
    Map<String, Object?> localRow, {
    required String userId,
    required String deviceId,
  }) {
    final payload = <String, Object?>{};
    for (final entry in localRow.entries) {
      final key = entry.key;
      if (key == 'id') {
        payload['local_id'] = entry.value;
      } else if (!excludedCloudColumns.contains(key)) {
        payload[key] = _toCloudValue(key, entry.value);
      }
    }
    payload['user_id'] = userId;
    payload['device_id'] = deviceId;
    payload['sync_status'] = localRow['sync_status'] == SyncStatus.deleted.value
        ? SyncStatus.deleted.value
        : SyncStatus.synced.value;
    return payload;
  }

  Map<String, Object?> toLocalPayload(Map<String, dynamic> cloudRow) {
    final payload = <String, Object?>{};
    for (final entry in cloudRow.entries) {
      final key = entry.key;
      if (key == 'id') {
        payload['cloud_id'] = entry.value;
      } else if (key == 'local_id') {
        if (entry.value != null) payload['id'] = entry.value;
      } else {
        payload[key] = _toLocalValue(key, entry.value);
      }
    }
    payload['sync_status'] = SyncStatus.synced.value;
    return payload;
  }

  Object? _toCloudValue(String key, Object? value) {
    if (boolColumns.contains(key)) {
      if (value is bool) return value;
      return (value as int? ?? 0) == 1;
    }
    return value;
  }

  Object? _toLocalValue(String key, Object? value) {
    if (boolColumns.contains(key)) {
      return value == true ? 1 : 0;
    }
    if (dateColumns.contains(key) && value is DateTime) {
      return value.toIso8601String();
    }
    return value;
  }
}
