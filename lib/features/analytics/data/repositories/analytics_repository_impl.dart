import 'package:finxl/features/analytics/domain/entities/analytics_overview.dart';
import 'package:finxl/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl();

  @override
  Future<AnalyticsOverview> fetchOverview() async {
    return const AnalyticsOverview(
      monthlyInsight: AnalyticsPeriodInsight(
        period: AnalyticsPeriod.monthly,
        headlineAmount: 4280.5,
        comparisonLabel: '12% less than last month',
        trendLabel: 'SURPLUS',
        trendValues: [0.40, 0.65, 0.30, 0.90, 0.55, 0.75, 0.45],
      ),
      weeklyInsight: AnalyticsPeriodInsight(
        period: AnalyticsPeriod.weekly,
        headlineAmount: 1120,
        comparisonLabel: '8% more than last week',
        trendLabel: 'ON TRACK',
        trendValues: [0.35, 0.50, 0.42, 0.68, 0.58, 0.62, 0.48],
      ),
      categories: [
        AnalyticsCategory(label: 'Food & Dining', percentage: 45, accent: 'primary'),
        AnalyticsCategory(label: 'Housing', percentage: 25, accent: 'secondary'),
        AnalyticsCategory(label: 'Lifestyle', percentage: 18, accent: 'tertiary'),
        AnalyticsCategory(label: 'Others', percentage: 12, accent: 'warning'),
      ],
      insights: [
        AnalyticsInsight(
          title: 'Potential Savings',
          description: 'Reducing dining out by 10% could save you ₹7,500 monthly.',
          iconKey: 'savings',
          accent: 'primary',
        ),
        AnalyticsInsight(
          title: 'Upcoming Bills',
          description: 'Rent and utilities worth ₹38,000 are due in 4 days.',
          iconKey: 'bill',
          accent: 'secondary',
        ),
        AnalyticsInsight(
          title: 'Goal Reached',
          description: 'You have fully funded your monsoon emergency buffer.',
          iconKey: 'celebration',
          accent: 'tertiary',
        ),
      ],
    );
  }
}
