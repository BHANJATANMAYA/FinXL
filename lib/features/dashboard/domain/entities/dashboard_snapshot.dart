import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/models/transaction.dart';

class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.totalBalance,
    required this.savedThisMonth,
    required this.monthlyIncome,
    required this.monthlySpent,
    required this.remainingBudgetRatio,
    required this.daysLeft,
    required this.weeklyTrend,
    required this.weeklyTrendLabels,
    required this.highlights,
    required this.recentTransactions,
    required this.upcomingBills,
    required this.budgetAlerts,
    this.activeGoal,
  });

  final double totalBalance;
  final double savedThisMonth;
  final double monthlyIncome;
  final double monthlySpent;
  final double remainingBudgetRatio;
  final int daysLeft;
  final List<double> weeklyTrend;
  final List<String> weeklyTrendLabels;
  final List<DashboardHighlight> highlights;
  final List<Transaction> recentTransactions;
  final List<Bill> upcomingBills;
  final List<Budget> budgetAlerts;
  final Goal? activeGoal;

  @override
  List<Object?> get props => [
    totalBalance,
    savedThisMonth,
    monthlyIncome,
    monthlySpent,
    remainingBudgetRatio,
    daysLeft,
    weeklyTrend,
    weeklyTrendLabels,
    highlights,
    recentTransactions,
    upcomingBills,
    budgetAlerts,
    activeGoal,
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
