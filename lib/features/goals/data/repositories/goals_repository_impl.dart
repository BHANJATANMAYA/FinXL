import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  const GoalsRepositoryImpl();

  @override
  Future<GoalsOverview> fetchOverview() async {
    return const GoalsOverview(
      progressMessage: 'You are 62% closer to your total milestones this quarter.',
      totalSaved: 190000,
      completedMilestone: 'MacBook Pro goal reached!',
      goals: [
        SavingsGoal(
          title: 'Euro Trip',
          subtitle: 'Dream vacation through Italy and France',
          savedAmount: 145000,
          targetAmount: 250000,
          iconKey: 'travel',
          accent: 'tertiary',
          badgeLabel: 'Primary',
        ),
        SavingsGoal(
          title: 'New Bike',
          subtitle: 'Urban commuter e-bike',
          savedAmount: 45000,
          targetAmount: 120000,
          iconKey: 'bike',
          accent: 'primary',
          badgeLabel: 'Trending Up',
        ),
      ],
    );
  }
}
