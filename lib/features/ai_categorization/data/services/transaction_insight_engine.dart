import 'package:finxl/core/models/budget.dart';
import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/features/ai_categorization/data/services/insight_generator.dart';
import 'package:finxl/features/ai_categorization/data/services/spending_pattern_analyzer.dart';
import 'package:finxl/features/ai_categorization/domain/entities/insight_model.dart';

class TransactionInsightEngine {
  TransactionInsightEngine({
    SpendingPatternAnalyzer? analyzer,
    InsightGenerator? generator,
  }) : _analyzer = analyzer ?? SpendingPatternAnalyzer(),
       _generator = generator ?? InsightGenerator();

  final SpendingPatternAnalyzer _analyzer;
  final InsightGenerator _generator;

  List<InsightModel> generateInsights(
    List<Transaction> transactions,
    List<Budget> budgets, {
    DateTime? now,
  }) {
    final summary = _analyzer.analyze(transactions, budgets, now: now);
    return _generator.generate(summary);
  }
}
