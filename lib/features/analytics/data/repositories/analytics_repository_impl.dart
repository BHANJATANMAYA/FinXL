import 'dart:math' as math;

import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/budget_spending.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl({LocalDatabaseService? databaseService})
    : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<AnalyticsOverview> fetchOverview() async {
    final transactions = await _getTransactions();
    final now = DateTime.now();
    final budgets = await _getBudgets(transactions, now);
    final goals = await _getGoals();
    final monthlyTrend = _buildMonthlyTrend(transactions, now);
    final weeklyTrend = _buildWeeklyTrend(transactions, now);

    final monthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);
    final previousMonthStart = DateTime(now.year, now.month - 1);
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final nextWeekStart = weekStart.add(const Duration(days: 7));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));

    final monthlyTransactions = _filterByRange(
      transactions,
      monthStart,
      nextMonthStart,
    );
    final previousMonthTransactions = _filterByRange(
      transactions,
      previousMonthStart,
      monthStart,
    );
    final weeklyTransactions = _filterByRange(
      transactions,
      weekStart,
      nextWeekStart,
    );
    final previousWeekTransactions = _filterByRange(
      transactions,
      previousWeekStart,
      weekStart,
    );

    final monthlyIncome = _sumTransactions(
      monthlyTransactions,
      core.TransactionType.income,
    );
    final monthlyExpense = _sumTransactions(
      monthlyTransactions,
      core.TransactionType.expense,
    );
    final previousMonthExpense = _sumTransactions(
      previousMonthTransactions,
      core.TransactionType.expense,
    );
    final weeklyExpense = _sumTransactions(
      weeklyTransactions,
      core.TransactionType.expense,
    );
    final previousWeekExpense = _sumTransactions(
      previousWeekTransactions,
      core.TransactionType.expense,
    );

    return AnalyticsOverview(
      monthlyInsight: AnalyticsPeriodInsight(
        period: AnalyticsPeriod.monthly,
        headlineAmount: monthlyExpense,
        comparisonLabel: _comparisonLabel(
          monthlyExpense,
          previousMonthExpense,
          'last month',
        ),
        trendLabel: monthlyIncome >= monthlyExpense ? 'SURPLUS' : 'DEFICIT',
        trendValues: monthlyTrend.values,
        trendLabels: monthlyTrend.labels,
      ),
      weeklyInsight: AnalyticsPeriodInsight(
        period: AnalyticsPeriod.weekly,
        headlineAmount: weeklyExpense,
        comparisonLabel: _comparisonLabel(
          weeklyExpense,
          previousWeekExpense,
          'last week',
        ),
        trendLabel: weeklyExpense <= previousWeekExpense
            ? 'ON TRACK'
            : 'RISING',
        trendValues: weeklyTrend.values,
        trendLabels: weeklyTrend.labels,
      ),
      categories: _buildCategoryBreakdown(monthlyTransactions),
      insights: _buildInsights(monthlyTransactions, budgets, goals),
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

  List<core.Transaction> _filterByRange(
    List<core.Transaction> transactions,
    DateTime start,
    DateTime end,
  ) {
    return transactions
        .where(
          (transaction) =>
              !transaction.date.isBefore(start) &&
              transaction.date.isBefore(end),
        )
        .toList(growable: false);
  }

  double _sumTransactions(
    List<core.Transaction> transactions,
    core.TransactionType type,
  ) {
    return transactions
        .where((transaction) => transaction.type == type)
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
  }

  String _comparisonLabel(
    double current,
    double previous,
    String baselineLabel,
  ) {
    if (previous <= 0 && current <= 0) {
      return 'No change from $baselineLabel';
    }
    if (previous <= 0) {
      return 'New activity compared to $baselineLabel';
    }

    final differenceRatio = ((current - previous).abs() / previous) * 100;
    final direction = current <= previous ? 'less' : 'more';
    return '${differenceRatio.round()}% $direction than $baselineLabel';
  }

  ({List<double> values, List<String> labels}) _buildMonthlyTrend(
    List<core.Transaction> transactions,
    DateTime now,
  ) {
    final values = List<double>.generate(7, (index) {
      final month = DateTime(now.year, now.month - (6 - index));
      final nextMonth = DateTime(month.year, month.month + 1);
      final total = transactions
          .where(
            (transaction) =>
                transaction.type == core.TransactionType.expense &&
                !transaction.date.isBefore(month) &&
                transaction.date.isBefore(nextMonth),
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
      return total;
    });
    final labels = List<String>.generate(7, (index) {
      final month = DateTime(now.year, now.month - (6 - index));
      return FinanceLookups.shortMonthLabel(month).toUpperCase();
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

  ({List<double> values, List<String> labels}) _buildWeeklyTrend(
    List<core.Transaction> transactions,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final values = List<double>.generate(7, (index) {
      final dayStart = today.subtract(Duration(days: 6 - index));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final total = transactions
          .where(
            (transaction) =>
                transaction.type == core.TransactionType.expense &&
                !transaction.date.isBefore(dayStart) &&
                transaction.date.isBefore(dayEnd),
          )
          .fold<double>(0, (sum, transaction) => sum + transaction.amount);
      return total;
    });
    final labels = List<String>.generate(7, (index) {
      final dayStart = today.subtract(Duration(days: 6 - index));
      return FinanceLookups.shortWeekdayLabel(dayStart, uppercase: true);
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

  List<AnalyticsCategory> _buildCategoryBreakdown(
    List<core.Transaction> monthlyTransactions,
  ) {
    final expenses = monthlyTransactions
        .where((transaction) {
          return transaction.type == core.TransactionType.expense;
        })
        .toList(growable: false);
    final totalExpense = expenses.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    if (totalExpense <= 0) {
      return const [];
    }

    final categoryTotals = <int, double>{};
    for (final transaction in expenses) {
      categoryTotals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries
        .take(4)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final categoryEntry = entry.value;
          final category = FinanceLookups.transactionCategory(
            categoryEntry.key,
          );
          return AnalyticsCategory(
            label: category.label,
            percentage: (categoryEntry.value / totalExpense) * 100,
            accent: FinanceLookups.accentForIndex(index),
          );
        })
        .toList(growable: false);
  }

  List<AnalyticsInsight> _buildInsights(
    List<core.Transaction> monthlyTransactions,
    List<Budget> budgets,
    List<Goal> goals,
  ) {
    final insights = <AnalyticsInsight>[];
    final expenseTransactions = monthlyTransactions
        .where((transaction) {
          return transaction.type == core.TransactionType.expense;
        })
        .toList(growable: false);

    if (expenseTransactions.isEmpty) {
      insights.add(
        const AnalyticsInsight(
          title: 'Potential Savings',
          description:
              'Add expense transactions to unlock personalized savings insights.',
          iconKey: 'savings',
          accent: 'primary',
        ),
      );
    } else {
      final categoryTotals = <int, double>{};
      for (final transaction in expenseTransactions) {
        categoryTotals.update(
          transaction.categoryId,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
      final topCategory = categoryTotals.entries.reduce((current, next) {
        return current.value >= next.value ? current : next;
      });
      final category = FinanceLookups.transactionCategory(topCategory.key);
      insights.add(
        AnalyticsInsight(
          title: 'Potential Savings',
          description:
              'Reducing ${category.label.toLowerCase()} spending by 10% could save you ₹${(topCategory.value * 0.1).round()} this month.',
          iconKey: 'savings',
          accent: 'primary',
        ),
      );
    }

    if (budgets.isEmpty) {
      insights.add(
        const AnalyticsInsight(
          title: 'Budget Watch',
          description:
              'Create budgets to compare your spending against planned limits.',
          iconKey: 'bill',
          accent: 'secondary',
        ),
      );
    } else {
      final riskiestBudget = budgets.reduce((current, next) {
        final currentRatio = FinanceLookups.safeRatio(
          current.spentAmount,
          current.limitAmount,
        );
        final nextRatio = FinanceLookups.safeRatio(
          next.spentAmount,
          next.limitAmount,
        );
        return currentRatio >= nextRatio ? current : next;
      });
      final ratio = FinanceLookups.safeRatio(
        riskiestBudget.spentAmount,
        riskiestBudget.limitAmount,
      );
      insights.add(
        AnalyticsInsight(
          title: 'Budget Watch',
          description: ratio >= 1
              ? '${riskiestBudget.categoryName} has already exceeded its budget.'
              : '${riskiestBudget.categoryName} is at ${(ratio * 100).round()}% of its planned limit.',
          iconKey: 'bill',
          accent: ratio >= 1 ? 'warning' : 'secondary',
        ),
      );
    }

    if (goals.isEmpty) {
      insights.add(
        const AnalyticsInsight(
          title: 'Goal Progress',
          description:
              'Add a savings goal to track progress alongside your daily spending.',
          iconKey: 'goals',
          accent: 'tertiary',
        ),
      );
    } else {
      final completedGoal = goals
          .where((goal) => goal.currentAmount >= goal.targetAmount)
          .firstOrNull;
      final focusGoal =
          completedGoal ??
          goals.reduce((current, next) {
            final currentRatio = FinanceLookups.safeRatio(
              current.currentAmount,
              current.targetAmount,
            );
            final nextRatio = FinanceLookups.safeRatio(
              next.currentAmount,
              next.targetAmount,
            );
            return currentRatio >= nextRatio ? current : next;
          });
      final ratio = FinanceLookups.safeRatio(
        focusGoal.currentAmount,
        focusGoal.targetAmount,
      );
      insights.add(
        AnalyticsInsight(
          title: completedGoal != null ? 'Goal Reached' : 'Goal Progress',
          description: completedGoal != null
              ? 'You have fully funded ${completedGoal.title}.'
              : '${focusGoal.title} is ${(ratio * 100).round()}% funded so far.',
          iconKey: completedGoal != null ? 'celebration' : 'goals',
          accent: 'tertiary',
        ),
      );
    }

    return insights;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
