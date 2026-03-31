import 'package:finxl/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:finxl/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl();

  @override
  Future<DashboardSnapshot> fetchSnapshot() async {
    return const DashboardSnapshot(
      totalBalance: 854200,
      savedThisMonth: 3200,
      monthlyIncome: 120000,
      monthlySpent: 42000,
      remainingBudgetRatio: 0.65,
      daysLeft: 12,
      weeklyTrend: [0.40, 0.60, 0.90, 0.50, 0.70, 0.30, 0.45],
      highlights: [
        DashboardHighlight(
          title: 'Investments',
          value: '+12.4%',
          iconKey: 'bank',
          accent: 'tertiary',
        ),
        DashboardHighlight(
          title: 'Goal Progress',
          value: '88%',
          iconKey: 'goals',
          accent: 'secondary',
        ),
      ],
    );
  }
}
