import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/budget_spending.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({LocalDatabaseService? databaseService})
    : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<BudgetOverview> fetchOverview() async {
    final budgets = await getBudgets();
    if (budgets.isEmpty) {
      return const BudgetOverview(
        totalBudget: 0,
        remainingBudget: 0,
        alertTitle: 'No Budgets Yet',
        alertMessage:
            'Create a category budget to start tracking your spending limits.',
        categories: [],
      );
    }

    final totalBudget = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.limitAmount,
    );
    final totalSpent = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.spentAmount,
    );
    final remainingBudget = totalBudget - totalSpent;
    final riskiest = budgets.reduce((current, next) {
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
    final riskiestRatio = FinanceLookups.safeRatio(
      riskiest.spentAmount,
      riskiest.limitAmount,
    );

    return BudgetOverview(
      totalBudget: totalBudget,
      remainingBudget: remainingBudget,
      alertTitle: riskiestRatio > 1
          ? 'Critical Alert'
          : riskiestRatio >= 0.7
          ? 'Heads Up'
          : 'Looking Good',
      alertMessage: riskiestRatio > 1
          ? '${riskiest.categoryName} has exceeded its budget.'
          : riskiestRatio >= 0.7
          ? '${riskiest.categoryName} is close to its spending limit.'
          : 'Your category budgets are currently within their planned range.',
      categories: budgets
          .map((budget) {
            final progress = FinanceLookups.safeRatio(
              budget.spentAmount,
              budget.limitAmount,
            );
            return BudgetCategory(
              id: budget.id,
              title: budget.categoryName,
              iconKey: FinanceLookups.budgetIconKey(budget.categoryName),
              statusLabel: FinanceLookups.budgetStatusLabel(progress),
              accent: FinanceLookups.budgetAccent(progress),
              spent: budget.spentAmount,
              limit: budget.limitAmount,
              exceeded: budget.spentAmount > budget.limitAmount,
            );
          })
          .toList(growable: false),
    );
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final budgetRows = await _databaseService.queryAll(
      LocalDatabaseService.budgetsTable,
      orderBy: 'category_name COLLATE NOCASE ASC',
    );
    final transactionRows = await _databaseService.queryAll(
      LocalDatabaseService.transactionsTable,
    );
    final budgets = budgetRows.map(Budget.fromMap).toList(growable: false);
    final transactions = transactionRows
        .map(core.Transaction.fromMap)
        .toList(growable: false);

    return BudgetSpending.applyCurrentMonthSpend(budgets, transactions);
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    final budgets = await getBudgets();
    for (final budget in budgets) {
      if (budget.id == id) return budget;
    }
    return null;
  }

  @override
  Future<int> addBudget(Budget budget) async {
    final values = Map<String, Object?>.from(budget.toMap())
      ..remove('id')
      ..['spent_amount'] = 0;
    return _databaseService.insert(LocalDatabaseService.budgetsTable, values);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final id = budget.id;
    if (id == null) {
      throw ArgumentError('Budget id is required for update.');
    }

    final values = Map<String, Object?>.from(budget.toMap())
      ..remove('id')
      ..remove('spent_amount');
    await _databaseService.update(
      LocalDatabaseService.budgetsTable,
      values,
      id,
    );
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _databaseService.delete(LocalDatabaseService.budgetsTable, id);
  }
}
