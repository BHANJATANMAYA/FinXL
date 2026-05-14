import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/sync_metadata.dart';

enum RecurrenceType { monthly, yearly }

extension RecurrenceTypeX on RecurrenceType {
  String get value {
    return switch (this) {
      RecurrenceType.monthly => 'monthly',
      RecurrenceType.yearly => 'yearly',
    };
  }

  static RecurrenceType fromValue(String? value) {
    return switch (value) {
      'yearly' => RecurrenceType.yearly,
      'monthly' || _ => RecurrenceType.monthly,
    };
  }
}

class Subscription extends Equatable {
  const Subscription({
    this.id,
    required this.name,
    required this.amount,
    required this.recurrence,
    required this.startDate,
    required this.nextRenewalDate,
    required this.isActive,
    this.categoryId,
    this.syncMetadata = const SyncMetadata(),
  });

  final int? id;
  final String name;
  final double amount;
  final RecurrenceType recurrence;
  final DateTime startDate;
  final DateTime nextRenewalDate;
  final bool isActive;
  final int? categoryId;
  final SyncMetadata syncMetadata;

  Subscription copyWith({
    int? id,
    String? name,
    double? amount,
    RecurrenceType? recurrence,
    DateTime? startDate,
    DateTime? nextRenewalDate,
    bool? isActive,
    int? categoryId,
    SyncMetadata? syncMetadata,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      syncMetadata: syncMetadata ?? this.syncMetadata,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'recurrence': recurrence.value,
      'start_date': startDate.toIso8601String(),
      'next_renewal_date': nextRenewalDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'category_id': categoryId,
      ...syncMetadata.toMap(),
    };
  }

  factory Subscription.fromMap(Map<String, Object?> map) {
    return Subscription(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      recurrence: RecurrenceTypeX.fromValue(map['recurrence'] as String?),
      startDate: DateTime.parse(map['start_date'] as String),
      nextRenewalDate: DateTime.parse(map['next_renewal_date'] as String),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      categoryId: map['category_id'] as int?,
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
        name,
        amount,
        recurrence,
        startDate,
        nextRenewalDate,
        isActive,
        categoryId,
        syncMetadata,
      ];
}
