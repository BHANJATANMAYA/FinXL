import 'dart:math' as math;

import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/core/utils/finance_lookups.dart';

class SpendingPatternSummary {
  const SpendingPatternSummary({
    required this.weekendSpend,
    required this.weekdaySpend,
    required this.currentMonthByCategory,
    required this.previousMonthByCategory,
    required this.recurringMerchants,
    required this.spikeCategories,
    required this.topCategoryId,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.savedThisMonth,
    required this.closeBudgets,
  });

  final double weekendSpend;
  final double weekdaySpend;
  final Map<int, double> currentMonthByCategory;
  final Map<int, double> previousMonthByCategory;
  final List<String> recurringMerchants;
  final List<int> spikeCategories;
  final int? topCategoryId;
  final double monthlyIncome;
  final double monthlyExpense;
  final double savedThisMonth;
  final List<Budget> closeBudgets;
}

class SpendingPatternAnalyzer {
  SpendingPatternSummary analyze(
    List<Transaction> transactions,
    List<Budget> budgets, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final monthStart = DateTime(clock.year, clock.month);
    final nextMonthStart = DateTime(clock.year, clock.month + 1);
    final previousMonthStart = DateTime(clock.year, clock.month - 1);

    final currentMonth = transactions
        .where((item) => _isInRange(item.date, monthStart, nextMonthStart))
        .toList(growable: false);
    final previousMonth = transactions
        .where((item) => _isInRange(item.date, previousMonthStart, monthStart))
        .toList(growable: false);

    final weekendSpend = currentMonth
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              (item.date.weekday == DateTime.saturday ||
                  item.date.weekday == DateTime.sunday),
        )
        .fold<double>(0, (sum, item) => sum + item.amount);
    final weekdaySpend = currentMonth
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.date.weekday != DateTime.saturday &&
              item.date.weekday != DateTime.sunday,
        )
        .fold<double>(0, (sum, item) => sum + item.amount);

    final currentByCategory = _sumByCategory(currentMonth);
    final previousByCategory = _sumByCategory(previousMonth);
    final recurringMerchants = _recurringMerchants(transactions);
    final spikeCategories = _spikeCategories(
      currentByCategory,
      previousByCategory,
    );
    final topCategoryId = currentByCategory.entries.isEmpty
        ? null
        : currentByCategory.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
    final income = currentMonth
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expense = currentMonth
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final closeBudgets = budgets
        .where(
          (budget) =>
              budget.limitAmount > 0 &&
              budget.spentAmount >= budget.limitAmount * 0.82,
        )
        .toList(growable: false);

    return SpendingPatternSummary(
      weekendSpend: weekendSpend,
      weekdaySpend: weekdaySpend,
      currentMonthByCategory: currentByCategory,
      previousMonthByCategory: previousByCategory,
      recurringMerchants: recurringMerchants,
      spikeCategories: spikeCategories,
      topCategoryId: topCategoryId,
      monthlyIncome: income,
      monthlyExpense: expense,
      savedThisMonth: income - expense,
      closeBudgets: closeBudgets,
    );
  }

  Map<int, double> _sumByCategory(List<Transaction> transactions) {
    final values = <int, double>{};
    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) continue;
      values.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return values;
  }

  List<String> _recurringMerchants(List<Transaction> transactions) {
    final counts = <String, int>{};
    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) continue;
      final merchant = transaction.description.trim();
      if (merchant.length < 3) continue;
      counts.update(merchant, (value) => value + 1, ifAbsent: () => 1);
    }
    final entries = counts.entries.where((entry) => entry.value >= 2).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).map((entry) => entry.key).toList(growable: false);
  }

  List<int> _spikeCategories(
    Map<int, double> current,
    Map<int, double> previous,
  ) {
    final spikes = <int>[];
    for (final entry in current.entries) {
      final oldValue = previous[entry.key] ?? 0;
      if (entry.value >= math.max(500, oldValue * 1.35) && oldValue > 0) {
        spikes.add(entry.key);
      }
    }
    return spikes;
  }

  bool _isInRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  String categoryLabel(int categoryId) {
    return FinanceLookups.transactionCategory(categoryId).label;
  }
}
