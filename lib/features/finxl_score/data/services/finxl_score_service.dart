import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/models/subscription.dart';
import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/features/finxl_score/domain/entities/finxl_score.dart';

class FinXLScoreService {
  FinXLScore calculateScore({
    required List<Transaction> transactions,
    required List<Budget> budgets,
    required List<Goal> goals,
    required List<Subscription> subscriptions,
  }) {
    final factors = <ScoreFactor>[];
    final suggestions = <String>[];

    // 1. Savings Ratio (35%)
    final savingsFactor = _calculateSavingsFactor(transactions);
    factors.add(savingsFactor);
    if (!savingsFactor.isPositive) {
      suggestions.add('Try to save at least 20% of your income to boost your score.');
    }

    // 2. Budget Discipline (25%)
    final budgetFactor = _calculateBudgetFactor(budgets);
    factors.add(budgetFactor);
    if (!budgetFactor.isPositive) {
      suggestions.add('Staying within your budget limits significantly improves financial health.');
    }

    // 3. Spending Consistency (20%)
    final consistencyFactor = _calculateConsistencyFactor(transactions);
    factors.add(consistencyFactor);
    if (!consistencyFactor.isPositive) {
      suggestions.add('Large spikes in spending can hurt your score. Aim for more consistent daily expenses.');
    }

    // 4. Subscription Control (10%)
    final subFactor = _calculateSubscriptionFactor(subscriptions);
    factors.add(subFactor);
    if (!subFactor.isPositive) {
      suggestions.add('Review your active subscriptions. Cancelling unused ones can save you ${subFactor.message}.');
    }

    // 5. Goal Progress (10%)
    final goalFactor = _calculateGoalFactor(goals);
    factors.add(goalFactor);
    if (!goalFactor.isPositive) {
      suggestions.add('Contributing to your goals regularly is a key sign of financial health.');
    }

    double totalWeightedScore = 0;
    for (final f in factors) {
      totalWeightedScore += f.score * f.weight;
    }

    return FinXLScore(
      totalScore: (totalWeightedScore * 100).round(),
      factors: factors,
      suggestions: suggestions,
    );
  }

  ScoreFactor _calculateSavingsFactor(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);

    for (final tx in transactions) {
      if (tx.date.isBefore(thisMonth)) continue;
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    double ratio = income > 0 ? (income - expense) / income : 0;
    if (ratio < 0) ratio = 0;
    if (ratio > 0.5) ratio = 1.0; // Max score if saving > 50%
    else ratio = ratio / 0.5;

    return ScoreFactor(
      title: 'Savings Ratio',
      score: ratio,
      weight: 0.35,
      message: income > 0 ? '${((income - expense) / income * 100).round()}% saved' : 'No income recorded',
      isPositive: ratio > 0.4,
    );
  }

  ScoreFactor _calculateBudgetFactor(List<Budget> budgets) {
    if (budgets.isEmpty) {
      return const ScoreFactor(
        title: 'Budget Discipline',
        score: 0.5,
        weight: 0.25,
        message: 'No budgets set',
        isPositive: false,
      );
    }

    int exceeded = 0;
    for (final b in budgets) {
      if (b.spentAmount > b.limitAmount) exceeded++;
    }

    double score = 1.0 - (exceeded / budgets.length);
    return ScoreFactor(
      title: 'Budget Discipline',
      score: score,
      weight: 0.25,
      message: exceeded == 0 ? 'All budgets on track' : '$exceeded budgets exceeded',
      isPositive: exceeded == 0,
    );
  }

  ScoreFactor _calculateConsistencyFactor(List<Transaction> transactions) {
    // Simplified consistency: compare last 7 days vs previous 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    double recent = 0;
    double previous = 0;

    for (final tx in transactions) {
      if (tx.type != TransactionType.expense) continue;
      if (tx.date.isAfter(sevenDaysAgo)) {
        recent += tx.amount;
      } else if (tx.date.isAfter(fourteenDaysAgo)) {
        previous += tx.amount;
      }
    }

    double diff = (recent - previous).abs();
    double score = previous > 0 ? 1.0 - (diff / previous) : 1.0;
    if (score < 0) score = 0;

    return ScoreFactor(
      title: 'Consistency',
      score: score,
      weight: 0.20,
      message: score > 0.8 ? 'Stable spending' : 'Volatile spending',
      isPositive: score > 0.8,
    );
  }

  ScoreFactor _calculateSubscriptionFactor(List<Subscription> subscriptions) {
    final active = subscriptions.where((s) => s.isActive).toList();
    double total = active.fold(0, (sum, s) => sum + (s.recurrence == RecurrenceType.monthly ? s.amount : s.amount / 12));

    double score = 1.0;
    if (total > 5000) score = 0.4;
    else if (total > 2000) score = 0.7;
    else if (total > 0) score = 0.9;

    return ScoreFactor(
      title: 'Subscription Control',
      score: score,
      weight: 0.10,
      message: '₹${total.round()}/month',
      isPositive: score > 0.7,
    );
  }

  ScoreFactor _calculateGoalFactor(List<Goal> goals) {
    if (goals.isEmpty) {
      return const ScoreFactor(
        title: 'Goal Progress',
        score: 0.5,
        weight: 0.10,
        message: 'No active goals',
        isPositive: false,
      );
    }

    double avgProgress = goals.fold(0.0, (sum, g) => sum + (g.currentAmount / g.targetAmount)) / goals.length;
    if (avgProgress > 1.0) avgProgress = 1.0;

    return ScoreFactor(
      title: 'Goal Progress',
      score: avgProgress,
      weight: 0.10,
      message: '${(avgProgress * 100).round()}% overall progress',
      isPositive: avgProgress > 0.3,
    );
  }
}
