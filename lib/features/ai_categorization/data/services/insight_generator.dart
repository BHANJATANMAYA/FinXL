import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/features/ai_categorization/data/services/spending_pattern_analyzer.dart';
import 'package:finxl/features/ai_categorization/domain/entities/insight_model.dart';

class InsightGenerator {
  List<InsightModel> generate(SpendingPatternSummary summary) {
    final insights = <InsightModel>[];

    if (summary.weekendSpend > summary.weekdaySpend * 0.45 &&
        summary.weekendSpend > 0) {
      insights.add(
        InsightModel(
          id: 'weekend-spend',
          title: 'Weekend pattern',
          message: 'You spend more on weekends than your usual weekday pace.',
          type: InsightType.trend,
          confidence: 0.82,
          iconKey: 'insights',
          accent: 'secondary',
        ),
      );
    }

    for (final categoryId in summary.spikeCategories.take(2)) {
      final current = summary.currentMonthByCategory[categoryId] ?? 0;
      final previous = summary.previousMonthByCategory[categoryId] ?? 0;
      final increase = previous <= 0
          ? 0
          : ((current - previous) / previous) * 100;
      final category = FinanceLookups.transactionCategory(categoryId);
      insights.add(
        InsightModel(
          id: 'spike-$categoryId',
          title: '${category.label} increased',
          message:
              '${category.label} spending increased ${increase.round()}% versus last month.',
          type: InsightType.spike,
          confidence: 0.86,
          iconKey: category.iconKey,
          accent: 'warning',
        ),
      );
    }

    if (summary.closeBudgets.isNotEmpty) {
      final budget = summary.closeBudgets.first;
      insights.add(
        InsightModel(
          id: 'budget-${budget.id ?? budget.categoryName}',
          title: 'Budget watch',
          message: 'You are close to your ${budget.categoryName} budget.',
          type: InsightType.budget,
          confidence: 0.9,
          iconKey: FinanceLookups.budgetIconKey(budget.categoryName),
          accent: 'tertiary',
          actionLabel: 'Review budget',
        ),
      );
    }

    if (summary.savedThisMonth > 0) {
      insights.add(
        InsightModel(
          id: 'saved-this-month',
          title: 'Savings momentum',
          message:
              'You saved ${formatCurrency(summary.savedThisMonth)} this month.',
          type: InsightType.savings,
          confidence: 0.95,
          iconKey: 'cash',
          accent: 'primary',
        ),
      );
    }

    if (summary.recurringMerchants.isNotEmpty) {
      insights.add(
        InsightModel(
          id: 'recurring-${summary.recurringMerchants.first.toLowerCase()}',
          title: 'Recurring merchant',
          message:
              '${summary.recurringMerchants.first} appears often in recent spending.',
          type: InsightType.recurring,
          confidence: 0.74,
          iconKey: 'subscription',
          accent: 'secondary',
        ),
      );
    }

    return insights.take(5).toList(growable: false);
  }
}
