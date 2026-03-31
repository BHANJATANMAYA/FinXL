import 'package:equatable/equatable.dart';

class BudgetOverview extends Equatable {
  const BudgetOverview({
    required this.totalBudget,
    required this.remainingBudget,
    required this.alertTitle,
    required this.alertMessage,
    required this.categories,
  });

  final double totalBudget;
  final double remainingBudget;
  final String alertTitle;
  final String alertMessage;
  final List<BudgetCategory> categories;

  @override
  List<Object> get props => [
    totalBudget,
    remainingBudget,
    alertTitle,
    alertMessage,
    categories,
  ];
}

class BudgetCategory extends Equatable {
  const BudgetCategory({
    required this.title,
    required this.iconKey,
    required this.statusLabel,
    required this.accent,
    required this.spent,
    required this.limit,
    this.exceeded = false,
  });

  final String title;
  final String iconKey;
  final String statusLabel;
  final String accent;
  final double spent;
  final double limit;
  final bool exceeded;

  double get progress => spent / limit;

  @override
  List<Object> get props => [
    title,
    iconKey,
    statusLabel,
    accent,
    spent,
    limit,
    exceeded,
  ];
}
