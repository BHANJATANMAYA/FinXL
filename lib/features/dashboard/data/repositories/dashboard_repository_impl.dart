import 'dart:math' as math;

import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/budget_spending.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/ai_categorization/data/services/transaction_insight_engine.dart';
import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:finxl/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    LocalDatabaseService? databaseService,
    TransactionInsightEngine? insightEngine,
  }) : _databaseService = databaseService ?? LocalDatabaseService.instance,
       _insightEngine = insightEngine ?? TransactionInsightEngine();

  final LocalDatabaseService _databaseService;
  final TransactionInsightEngine _insightEngine;

  @override
  Future<DashboardSnapshot> fetchSnapshot() async {
    final transactions = await _getTransactions();
    final now = DateTime.now();
    final budgets = await _getBudgets(transactions, now);
    final goals = await _getGoals();
    final bills = await _getBills();
    final weeklyTrend = _buildWeeklyTrend(transactions, now);

    final monthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);
    final monthlyTransactions = transactions
        .where(
          (transaction) =>
              _isInRange(transaction.date, monthStart, nextMonthStart),
        )
        .toList(growable: false);

    final monthlyIncome = _sumTransactions(
      monthlyTransactions,
      core.TransactionType.income,
    );
    final monthlySpent = _sumTransactions(
      monthlyTransactions,
      core.TransactionType.expense,
    );
    final totalBalance =
        _sumTransactions(transactions, core.TransactionType.income) -
        _sumTransactions(transactions, core.TransactionType.expense);

    final totalBudget = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.limitAmount,
    );
    final totalBudgetSpent = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.spentAmount,
    );
    final remainingBudgetRatio = totalBudget <= 0
        ? 0.0
        : ((totalBudget - totalBudgetSpent) / totalBudget)
              .clamp(0, 1)
              .toDouble();

    final totalGoalTarget = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalGoalSaved = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final goalProgress = FinanceLookups.safeRatio(
      totalGoalSaved,
      totalGoalTarget,
    );
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final sortedTransactions = List<core.Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions
        .take(5)
        .toList(growable: false);

    final sortedBills = List<Bill>.from(bills)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final recentUpcomingBills = sortedBills.take(3).toList(growable: false);

    final budgetAlerts = budgets
        .where((b) => b.limitAmount > 0 && b.spentAmount >= b.limitAmount * 0.9)
        .toList(growable: false);
    final smartInsights = _insightEngine.generateInsights(
      transactions,
      budgets,
      now: now,
    );

    Goal? activeGoal;
    final activeGoals = goals
        .where((g) => g.currentAmount < g.targetAmount)
        .toList();
    if (activeGoals.isNotEmpty) {
      activeGoals.sort((a, b) {
        final aRatio = FinanceLookups.safeRatio(
          a.currentAmount,
          a.targetAmount,
        );
        final bRatio = FinanceLookups.safeRatio(
          b.currentAmount,
          b.targetAmount,
        );
        return bRatio.compareTo(aRatio);
      });
      activeGoal = activeGoals.first;
    }

    return DashboardSnapshot(
      totalBalance: totalBalance,
      savedThisMonth: monthlyIncome - monthlySpent,
      monthlyIncome: monthlyIncome,
      monthlySpent: monthlySpent,
      remainingBudgetRatio: remainingBudgetRatio,
      daysLeft: math.max(lastDayOfMonth.day - now.day, 0),
      weeklyTrend: weeklyTrend.values,
      weeklyTrendLabels: weeklyTrend.labels,
      highlights: [
        DashboardHighlight(
          title: 'Goal Progress',
          value: '${(goalProgress * 100).round()}%',
          iconKey: 'goals',
          accent: 'secondary',
        ),
        DashboardHighlight(
          title: 'Budget Left',
          value: '${(remainingBudgetRatio * 100).round()}%',
          iconKey: 'bank',
          accent: 'tertiary',
        ),
      ],
      recentTransactions: recentTransactions,
      upcomingBills: recentUpcomingBills,
      budgetAlerts: budgetAlerts,
      smartInsights: smartInsights,
      activeGoal: activeGoal,
    );
  }

  Future<List<core.Transaction>> _getTransactions() async {
    final db = await _databaseService.database;
    final rows = await db.query(LocalDatabaseService.transactionsTable);
    return rows.map(core.Transaction.fromMap).toList(growable: false);
  }

  Future<List<Budget>> _getBudgets(
    List<core.Transaction> transactions,
    DateTime now,
  ) async {
    final db = await _databaseService.database;
    final rows = await db.query(LocalDatabaseService.budgetsTable);
    final budgets = rows.map(Budget.fromMap).toList(growable: false);
    return BudgetSpending.applyCurrentMonthSpend(
      budgets,
      transactions,
      now: now,
    );
  }

  Future<List<Goal>> _getGoals() async {
    final db = await _databaseService.database;
    final rows = await db.query(LocalDatabaseService.goalsTable);
    return rows.map(Goal.fromMap).toList(growable: false);
  }

  Future<List<Bill>> _getBills() async {
    final db = await _databaseService.database;
    final rows = await db.query(
      LocalDatabaseService.billsTable,
      where: 'is_active = ? AND is_paid = ?',
      whereArgs: [1, 0],
    );
    return rows.map(Bill.fromMap).toList(growable: false);
  }

  double _sumTransactions(
    List<core.Transaction> transactions,
    core.TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  bool _isInRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  ({List<double> values, List<String> labels}) _buildWeeklyTrend(
    List<core.Transaction> transactions,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final values = List<double>.generate(7, (index) {
      final dayStart = today.subtract(Duration(days: 6 - index));
      final dayEnd = dayStart.add(const Duration(days: 1));
      return transactions
          .where(
            (transaction) =>
                transaction.type == core.TransactionType.expense &&
                _isInRange(transaction.date, dayStart, dayEnd),
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    });
    final labels = List<String>.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      return FinanceLookups.shortWeekdayLabel(day);
    });

    final maxValue = values.fold<double>(0, math.max);
    if (maxValue <= 0) {
      return (values: List<double>.filled(7, 0), labels: labels);
    }

    return (
      values: values.map((value) => value / maxValue).toList(growable: false),
      labels: labels,
    );
  }
}
