import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/sync_metadata.dart';

class Goal extends Equatable {
  const Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.color,
    this.icon,
    this.syncMetadata = const SyncMetadata(),
  });

  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? color;
  final String? icon;
  final SyncMetadata syncMetadata;

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? color,
    String? icon,
    SyncMetadata? syncMetadata,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      syncMetadata: syncMetadata ?? this.syncMetadata,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'color': color,
      'icon': icon,
      ...syncMetadata.toMap(),
    };
  }

  factory Goal.fromMap(Map<String, Object?> map) {
    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      color: map['color'] as String?,
      icon: map['icon'] as String?,
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
    title,
    targetAmount,
    currentAmount,
    deadline,
    color,
    icon,
    syncMetadata,
  ];
}
