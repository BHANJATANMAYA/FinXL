import 'package:equatable/equatable.dart';

class ScoreFactor extends Equatable {
  final String title;
  final double score; // 0 to 1
  final double weight; // 0 to 1
  final String message;
  final bool isPositive;

  const ScoreFactor({
    required this.title,
    required this.score,
    required this.weight,
    required this.message,
    required this.isPositive,
  });

  @override
  List<Object?> get props => [title, score, weight, message, isPositive];
}

class FinXLScore extends Equatable {
  final int totalScore;
  final List<ScoreFactor> factors;
  final List<String> suggestions;

  const FinXLScore({
    required this.totalScore,
    required this.factors,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [totalScore, factors, suggestions];
}
