import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/goal.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/goals/domain/entities/goals_overview.dart';
import 'package:finxl/features/goals/domain/repositories/goals_repository.dart';

class GoalsRepositoryImpl implements GoalsRepository {
  GoalsRepositoryImpl({LocalDatabaseService? databaseService})
    : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<GoalsOverview> fetchOverview() async {
    final goals = await getGoals();
    if (goals.isEmpty) {
      return const GoalsOverview(
        progressMessage:
            'Create your first savings goal to start tracking progress.',
        goals: [],
        totalSaved: 0,
        completedMilestone: 'No completed milestones yet.',
      );
    }

    final totalSaved = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final totalTarget = goals.fold<double>(
      0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final overallProgress = FinanceLookups.safeRatio(totalSaved, totalTarget);
    final completedGoal = goals
        .where((goal) => goal.currentAmount >= goal.targetAmount)
        .firstOrNull;

    final progressPercentage = (overallProgress * 100).round();
    final progressMessage = progressPercentage > 100
        ? 'You are ${progressPercentage - 100}% ahead of your goal.'
        : 'You are $progressPercentage% closer to your total milestones.';

    return GoalsOverview(
      progressMessage: progressMessage,
      goals: goals
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final goal = entry.value;
            final progress = FinanceLookups.safeRatio(
              goal.currentAmount,
              goal.targetAmount,
            );
            return SavingsGoal(
              id: goal.id,
              deadline: goal.deadline,
              title: goal.title,
              subtitle:
                  'Target by ${FinanceLookups.formatShortDate(goal.deadline)}',
              savedAmount: goal.currentAmount,
              targetAmount: goal.targetAmount,
              iconKey: goal.icon ?? 'goals',
              accent: progress >= 1
                  ? 'primary'
                  : (goal.color ?? FinanceLookups.accentForIndex(index)),
              badgeLabel: progress >= 1
                  ? 'Completed'
                  : progress >= 0.75
                  ? 'Almost There'
                  : null,
            );
          })
          .toList(growable: false),
      totalSaved: totalSaved,
      completedMilestone: completedGoal != null
          ? '${completedGoal.title} goal reached!'
          : 'Keep going on ${goals.first.title}.',
    );
  }

  @override
  Future<List<Goal>> getGoals() async {
    final db = await _databaseService.database;
    final rows = await db.query(
      LocalDatabaseService.goalsTable,
      orderBy: 'deadline ASC',
    );

    return rows.map(Goal.fromMap).toList(growable: false);
  }

  @override
  Future<Goal?> getGoalById(int id) async {
    final row = await _databaseService.queryById(
      LocalDatabaseService.goalsTable,
      id,
    );
    if (row == null) return null;
    return Goal.fromMap(row);
  }

  @override
  Future<int> addGoal(Goal goal) async {
    final values = Map<String, Object?>.from(goal.toMap())..remove('id');
    return _databaseService.insert(LocalDatabaseService.goalsTable, values);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final id = goal.id;
    if (id == null) {
      throw ArgumentError('Goal id is required for update.');
    }

    final values = Map<String, Object?>.from(goal.toMap())..remove('id');
    await _databaseService.update(LocalDatabaseService.goalsTable, values, id);
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _databaseService.delete(LocalDatabaseService.goalsTable, id);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
