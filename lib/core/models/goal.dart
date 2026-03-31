import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  const Goal({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.color,
    this.icon,
  });

  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? color;
  final String? icon;

  Goal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? color,
    String? icon,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
      icon: icon ?? this.icon,
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
  ];
}
