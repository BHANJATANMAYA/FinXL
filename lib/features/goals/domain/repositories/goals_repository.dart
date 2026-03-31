import 'package:finxl/core/models/goal.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';

abstract class GoalsRepository {
  Future<GoalsOverview> fetchOverview();
  Future<List<Goal>> getGoals();
  Future<Goal?> getGoalById(int id);
  Future<int> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(int id);
}
