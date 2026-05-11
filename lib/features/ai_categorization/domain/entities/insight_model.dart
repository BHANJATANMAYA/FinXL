import 'package:equatable/equatable.dart';

enum InsightType { trend, budget, savings, recurring, spike }

class InsightModel extends Equatable {
  const InsightModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.confidence,
    required this.iconKey,
    required this.accent,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String message;
  final InsightType type;
  final double confidence;
  final String iconKey;
  final String accent;
  final String? actionLabel;

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    confidence,
    iconKey,
    accent,
    actionLabel,
  ];
}
