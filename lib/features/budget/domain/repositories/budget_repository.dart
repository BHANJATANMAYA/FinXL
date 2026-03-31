import 'package:finxl/features/budget/domain/entities/budget_overview.dart';

abstract class BudgetRepository {
  Future<BudgetOverview> fetchOverview();
}
