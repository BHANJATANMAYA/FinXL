import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/finance_lookups.dart';

class BudgetSpending {
  BudgetSpending._();

  static List<Budget> applyCurrentMonthSpend(
    List<Budget> budgets,
    List<core.Transaction> transactions, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final monthStart = DateTime(current.year, current.month);
    final nextMonthStart = DateTime(current.year, current.month + 1);
    final expenseTotals = <int, double>{};

    for (final transaction in transactions) {
      if (transaction.type != core.TransactionType.expense) {
        continue;
      }
      if (transaction.date.isBefore(monthStart) ||
          !transaction.date.isBefore(nextMonthStart)) {
        continue;
      }
      expenseTotals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return budgets
        .map((budget) {
          final categoryId = FinanceLookups.transactionCategoryDbIdFromLabel(
            budget.categoryName,
          );
          return budget.copyWith(spentAmount: expenseTotals[categoryId] ?? 0);
        })
        .toList(growable: false);
  }
}
