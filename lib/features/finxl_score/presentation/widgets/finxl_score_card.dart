import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/features/finxl_score/presentation/cubit/finxl_score_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FinXLScoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const FinXLScoreCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinXLScoreCubit, FinXLScoreState>(
      builder: (context, state) {
        if (state.isLoading && state.score == null) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final score = state.score?.totalScore ?? 0;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getScoreColor(score),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$score',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FINXL SCORE',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getScoreLabel(score),
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on your recent activity',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.primary;
    if (score >= 60) return AppTheme.tertiary;
    return AppTheme.danger;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }
}
