import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/sync_metadata.dart';

class Bill extends Equatable {
  const Bill({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.recurrence,
    required this.type,
    required this.isActive,
    this.syncMetadata = const SyncMetadata(),
  });

  final int? id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String recurrence;
  final String type;
  final bool isActive;
  final SyncMetadata syncMetadata;

  Bill copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? recurrence,
    String? type,
    bool? isActive,
    SyncMetadata? syncMetadata,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      recurrence: recurrence ?? this.recurrence,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      syncMetadata: syncMetadata ?? this.syncMetadata,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
      'recurrence': recurrence,
      'type': type,
      'is_active': isActive ? 1 : 0,
      ...syncMetadata.toMap(),
    };
  }

  factory Bill.fromMap(Map<String, Object?> map) {
    return Bill(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      isPaid: (map['is_paid'] as int? ?? 0) == 1,
      recurrence: map['recurrence'] as String,
      type: map['type'] as String? ?? 'bill',
      isActive: (map['is_active'] as int? ?? 1) == 1,
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
    amount,
    dueDate,
    isPaid,
    recurrence,
    type,
    isActive,
    syncMetadata,
  ];
}
