import 'package:equatable/equatable.dart';

class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.totalBalance,
    required this.savedThisMonth,
    required this.monthlyIncome,
    required this.monthlySpent,
    required this.remainingBudgetRatio,
    required this.daysLeft,
    required this.weeklyTrend,
    required this.highlights,
  });

  final double totalBalance;
  final double savedThisMonth;
  final double monthlyIncome;
  final double monthlySpent;
  final double remainingBudgetRatio;
  final int daysLeft;
  final List<double> weeklyTrend;
  final List<DashboardHighlight> highlights;

  @override
  List<Object> get props => [
    totalBalance,
    savedThisMonth,
    monthlyIncome,
    monthlySpent,
    remainingBudgetRatio,
    daysLeft,
    weeklyTrend,
    highlights,
  ];
}

class DashboardHighlight extends Equatable {
  const DashboardHighlight({
    required this.title,
    required this.value,
    required this.iconKey,
    required this.accent,
  });

  final String title;
  final String value;
  final String iconKey;
  final String accent;

  @override
  List<Object> get props => [title, value, iconKey, accent];
}
