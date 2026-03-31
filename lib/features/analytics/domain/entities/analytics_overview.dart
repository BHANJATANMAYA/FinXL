import 'package:equatable/equatable.dart';

enum AnalyticsPeriod { monthly, weekly }

class AnalyticsOverview extends Equatable {
  const AnalyticsOverview({
    required this.monthlyInsight,
    required this.weeklyInsight,
    required this.categories,
    required this.insights,
  });

  final AnalyticsPeriodInsight monthlyInsight;
  final AnalyticsPeriodInsight weeklyInsight;
  final List<AnalyticsCategory> categories;
  final List<AnalyticsInsight> insights;

  AnalyticsPeriodInsight insightFor(AnalyticsPeriod period) {
    return period == AnalyticsPeriod.monthly ? monthlyInsight : weeklyInsight;
  }

  @override
  List<Object> get props => [monthlyInsight, weeklyInsight, categories, insights];
}

class AnalyticsPeriodInsight extends Equatable {
  const AnalyticsPeriodInsight({
    required this.period,
    required this.headlineAmount,
    required this.comparisonLabel,
    required this.trendLabel,
    required this.trendValues,
  });

  final AnalyticsPeriod period;
  final double headlineAmount;
  final String comparisonLabel;
  final String trendLabel;
  final List<double> trendValues;

  @override
  List<Object> get props => [period, headlineAmount, comparisonLabel, trendLabel, trendValues];
}

class AnalyticsCategory extends Equatable {
  const AnalyticsCategory({
    required this.label,
    required this.percentage,
    required this.accent,
  });

  final String label;
  final double percentage;
  final String accent;

  @override
  List<Object> get props => [label, percentage, accent];
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
