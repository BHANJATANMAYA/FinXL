import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/budget_spending.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyCurrentMonthSpend only includes the current month', () {
    final budgets = [
      const Budget(categoryName: 'Food', limitAmount: 10000, spentAmount: 0),
    ];
    final transactions = [
      core.Transaction(
        amount: 1500,
        date: DateTime(2026, 4, 5),
        description: 'Groceries',
        type: core.TransactionType.expense,
        paymentMethod: 'UPI',
        categoryId: 1,
      ),
      core.Transaction(
        amount: 2200,
        date: DateTime(2026, 3, 28),
        description: 'Last month groceries',
        type: core.TransactionType.expense,
        paymentMethod: 'UPI',
        categoryId: 1,
      ),
    ];

    final result = BudgetSpending.applyCurrentMonthSpend(
      budgets,
      transactions,
      now: DateTime(2026, 4, 10),
    );

    expect(result.single.spentAmount, 1500);
  });
}
