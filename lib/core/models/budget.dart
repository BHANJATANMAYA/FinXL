import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/sync_metadata.dart';

class Budget extends Equatable {
  const Budget({
    this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.spentAmount,
    this.syncMetadata = const SyncMetadata(),
  });

  final int? id;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final SyncMetadata syncMetadata;

  Budget copyWith({
    int? id,
    String? categoryName,
    double? limitAmount,
    double? spentAmount,
    SyncMetadata? syncMetadata,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      syncMetadata: syncMetadata ?? this.syncMetadata,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category_name': categoryName,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
      ...syncMetadata.toMap(),
    };
  }

  factory Budget.fromMap(Map<String, Object?> map) {
    return Budget(
      id: map['id'] as int?,
      categoryName: map['category_name'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num).toDouble(),
      syncMetadata: SyncMetadata(
        userId: map['user_id'] as String?,
        createdAt: parseOptionalDate(map['created_at']),
        updatedAt: parseOptionalDate(map['updated_at']),
        syncStatus: SyncStatusX.fromValue(map['sync_status'] as String?),
        deletedAt: parseOptionalDate(map['deleted_at']),
        deviceId: map['device_id'] as String?,
        cloudId: map['cloud_id'] as String?,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryName,
    limitAmount,
    spentAmount,
    syncMetadata,
  ];
}
