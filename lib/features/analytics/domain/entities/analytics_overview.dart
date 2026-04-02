import 'package:equatable/equatable.dart';

enum AnalyticsPeriod { monthly, weekly }

class AnalyticsOverview extends Equatable {
  const AnalyticsOverview({
    required this.monthlyInsight,
    required this.weeklyInsight,
    required this.monthlyCategories,
    required this.weeklyCategories,
    required this.insights,
  });

  final AnalyticsPeriodInsight monthlyInsight;
  final AnalyticsPeriodInsight weeklyInsight;
  final List<AnalyticsCategory> monthlyCategories;
  final List<AnalyticsCategory> weeklyCategories;
  final List<AnalyticsInsight> insights;

  AnalyticsPeriodInsight insightFor(AnalyticsPeriod period) {
    return period == AnalyticsPeriod.monthly ? monthlyInsight : weeklyInsight;
  }

  List<AnalyticsCategory> categoriesFor(AnalyticsPeriod period) {
    return period == AnalyticsPeriod.monthly ? monthlyCategories : weeklyCategories;
  }

  @override
  List<Object> get props => [
    monthlyInsight,
    weeklyInsight,
    monthlyCategories,
    weeklyCategories,
    insights,
  ];
}

class AnalyticsPeriodInsight extends Equatable {
  const AnalyticsPeriodInsight({
    required this.period,
    required this.headlineAmount,
    required this.totalIncome,
    required this.totalExpense,
    required this.previousTotalExpense,
    required this.comparisonLabel,
    required this.trendLabel,
    required this.trendValues,
    required this.trendLabels,
  });

  final AnalyticsPeriod period;
  final double headlineAmount;
  final double totalIncome;
  final double totalExpense;
  final double previousTotalExpense;
  final String comparisonLabel;
  final String trendLabel;
  final List<double> trendValues;
  final List<String> trendLabels;

  @override
  List<Object> get props => [
    period,
    headlineAmount,
    totalIncome,
    totalExpense,
    previousTotalExpense,
    comparisonLabel,
    trendLabel,
    trendValues,
    trendLabels,
  ];
}

class AnalyticsCategory extends Equatable {
  const AnalyticsCategory({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.accent,
  });

  final String label;
  final double amount;
  final double percentage;
  final String accent;

  @override
  List<Object> get props => [label, amount, percentage, accent];
}

class AnalyticsInsight extends Equatable {
  const AnalyticsInsight({
    required this.title,
    required this.description,
    required this.iconKey,
    required this.accent,
  });

  final String title;
  final String description;
  final String iconKey;
  final String accent;

  @override
  List<Object> get props => [title, description, iconKey, accent];
}
