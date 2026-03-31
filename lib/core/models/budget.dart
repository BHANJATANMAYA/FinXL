import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  const Budget({
    this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.spentAmount,
  });

  final int? id;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;

  Budget copyWith({
    int? id,
    String? categoryName,
    double? limitAmount,
    double? spentAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category_name': categoryName,
      'limit_amount': limitAmount,
      'spent_amount': spentAmount,
    };
  }

  factory Budget.fromMap(Map<String, Object?> map) {
    return Budget(
      id: map['id'] as int?,
      categoryName: map['category_name'] as String,
      limitAmount: (map['limit_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, categoryName, limitAmount, spentAmount];
}
