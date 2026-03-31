import 'package:equatable/equatable.dart';

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
  });

  final int? id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String recurrence;
  final String type;
  final bool isActive;

  Bill copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? recurrence,
    String? type,
    bool? isActive,
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
  ];
}
