import 'package:finxl/core/models/budget.dart';
import 'package:finxl/features/budget/domain/entities/budget_overview.dart';

abstract class BudgetRepository {
  Future<BudgetOverview> fetchOverview();
  Future<List<Budget>> getBudgets();
  Future<Budget?> getBudgetById(int id);
  Future<int> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
}
