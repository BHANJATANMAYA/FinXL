import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionSourceType { manual, sms, aiGenerated }

extension TransactionTypeX on TransactionType {
  String get value {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromValue(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Unsupported transaction type: $value');
    }
  }
}

extension TransactionSourceTypeX on TransactionSourceType {
  String get value {
    switch (this) {
      case TransactionSourceType.manual:
        return 'manual';
      case TransactionSourceType.sms:
        return 'sms';
      case TransactionSourceType.aiGenerated:
        return 'ai_generated';
    }
  }

  static TransactionSourceType fromValue(String? value) {
    switch (value) {
      case 'sms':
        return TransactionSourceType.sms;
      case 'ai_generated':
        return TransactionSourceType.aiGenerated;
      case 'manual':
      case null:
      case '':
        return TransactionSourceType.manual;
      default:
        return TransactionSourceType.manual;
    }
  }
}

class Transaction extends Equatable {
  const Transaction({
    this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.paymentMethod,
    required this.categoryId,
    this.sourceType = TransactionSourceType.manual,
    this.isAutoDetected = false,
    this.smsRawBody,
  });

  final int? id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType type;
  final String paymentMethod;
  final int categoryId;
  final TransactionSourceType sourceType;
  final bool isAutoDetected;
  final String? smsRawBody;

  Transaction copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? description,
    TransactionType? type,
    String? paymentMethod,
    int? categoryId,
    TransactionSourceType? sourceType,
    bool? isAutoDetected,
    String? smsRawBody,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      categoryId: categoryId ?? this.categoryId,
      sourceType: sourceType ?? this.sourceType,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      smsRawBody: smsRawBody ?? this.smsRawBody,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'type': type.value,
      'payment_method': paymentMethod,
      'category_id': categoryId,
      'source_type': sourceType.value,
      'is_auto_detected': isAutoDetected ? 1 : 0,
      'sms_raw_body': smsRawBody,
    };
  }

  factory Transaction.fromMap(Map<String, Object?> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String,
      type: TransactionTypeX.fromValue(map['type'] as String),
      paymentMethod: map['payment_method'] as String,
      categoryId: map['category_id'] as int,
      sourceType: TransactionSourceTypeX.fromValue(
        map['source_type'] as String?,
      ),
      isAutoDetected: (map['is_auto_detected'] as int?) == 1,
      smsRawBody: map['sms_raw_body'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    date,
    description,
    type,
    paymentMethod,
    categoryId,
    sourceType,
    isAutoDetected,
    smsRawBody,
  ];
}
