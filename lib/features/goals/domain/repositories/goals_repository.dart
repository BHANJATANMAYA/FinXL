import 'package:finxl/features/goals/domain/entities/goals_overview.dart';

abstract class GoalsRepository {
  Future<GoalsOverview> fetchOverview();
}
