import 'package:finxl/features/budget/domain/entities/budget_overview.dart';
import 'package:finxl/features/budget/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  const BudgetRepositoryImpl();

  @override
  Future<BudgetOverview> fetchOverview() async {
    return const BudgetOverview(
      totalBudget: 4800,
      remainingBudget: 2450,
      alertTitle: 'Critical Alert',
      alertMessage: '80% of the budget is used. Entertainment is running above plan.',
      categories: [
        BudgetCategory(
          title: 'Rent',
          iconKey: 'housing',
          statusLabel: 'On Track',
          accent: 'primary',
          spent: 1200,
          limit: 1200,
        ),
        BudgetCategory(
          title: 'Food',
          iconKey: 'restaurant',
          statusLabel: 'Getting Close',
          accent: 'warning',
          spent: 540,
          limit: 600,
        ),
        BudgetCategory(
          title: 'Entertainment',
          iconKey: 'entertainment',
          statusLabel: 'Exceeded',
          accent: 'danger',
          spent: 330,
          limit: 300,
          exceeded: true,
        ),
        BudgetCategory(
          title: 'Utilities',
          iconKey: 'utilities',
          statusLabel: 'Healthy',
          accent: 'primary',
          spent: 185,
          limit: 450,
        ),
        BudgetCategory(
          title: 'Subscriptions',
          iconKey: 'subscription',
          statusLabel: 'On Track',
          accent: 'secondary',
          spent: 98,
          limit: 150,
        ),
      ],
    );
  }
}
