import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

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

class Transaction extends Equatable {
  const Transaction({
    this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.paymentMethod,
    required this.categoryId,
  });

  final int? id;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionType type;
  final String paymentMethod;
  final int categoryId;

  Transaction copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? description,
    TransactionType? type,
    String? paymentMethod,
    int? categoryId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      categoryId: categoryId ?? this.categoryId,
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
  ];
}
