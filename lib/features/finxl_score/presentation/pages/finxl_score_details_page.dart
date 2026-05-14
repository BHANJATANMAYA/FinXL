import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/finxl_score/domain/entities/finxl_score.dart';
import 'package:finxl/features/finxl_score/presentation/cubit/finxl_score_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FinXLScoreDetailsPage extends StatelessWidget {
  const FinXLScoreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Health',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<FinXLScoreCubit, FinXLScoreState>(
        builder: (context, state) {
          final score = state.score;
          if (score == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FinxlPageBody(
            child: ListView(
              children: [
                _ScoreHeader(score: score.totalScore),
                const SizedBox(height: 32),
                Text(
                  'SCORE BREAKDOWN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...score.factors.map((f) => _FactorTile(factor: f)).toList(),
                const SizedBox(height: 32),
                Text(
                  'IMPROVEMENT SUGGESTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...score.suggestions.map((s) => _SuggestionCard(suggestion: s)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final int score;
  const _ScoreHeader({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'YOUR FINXL SCORE',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$score',
          style: GoogleFonts.manrope(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: _getScoreColor(score),
          ),
        ),
        Text(
          'out of 100',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.primary;
    if (score >= 60) return AppTheme.tertiary;
    return AppTheme.danger;
  }
}

class _FactorTile extends StatelessWidget {
  final ScoreFactor factor;
  const _FactorTile({required this.factor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factor.title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      factor.message,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(factor.score * 100).round()}/100',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: factor.isPositive ? AppTheme.primary : AppTheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.score,
              backgroundColor: AppTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                factor.isPositive ? AppTheme.primary : AppTheme.tertiary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String suggestion;
  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        padding: const EdgeInsets.all(16),
        child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppTheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              suggestion,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
