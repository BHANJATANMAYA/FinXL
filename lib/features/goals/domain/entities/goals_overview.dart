import 'package:equatable/equatable.dart';
import 'package:finxl/core/utils/finance_lookups.dart';

class GoalsOverview extends Equatable {
  const GoalsOverview({
    required this.progressMessage,
    required this.goals,
    required this.totalSaved,
    required this.completedMilestone,
  });

  final String progressMessage;
  final List<SavingsGoal> goals;
  final double totalSaved;
  final String completedMilestone;

  @override
  List<Object> get props => [
    progressMessage,
    goals,
    totalSaved,
    completedMilestone,
  ];
}

class SavingsGoal extends Equatable {
  const SavingsGoal({
    required this.title,
    required this.subtitle,
    required this.savedAmount,
    required this.targetAmount,
    required this.iconKey,
    required this.accent,
    this.badgeLabel,
  });

  final String title;
  final String subtitle;
  final double savedAmount;
  final double targetAmount;
  final String iconKey;
  final String accent;
  final String? badgeLabel;

  double get progress => FinanceLookups.safeRatio(savedAmount, targetAmount);

  @override
  List<Object?> get props => [
    title,
    subtitle,
    savedAmount,
    targetAmount,
    iconKey,
    accent,
    badgeLabel,
  ];
}
