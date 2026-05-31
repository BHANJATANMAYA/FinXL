import 'package:finxl/core/common/load_status.dart';
import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/features/sms_detection/domain/entities/sms_transaction_candidate.dart';
import 'package:finxl/features/sms_detection/presentation/bloc/sms_detection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SmsTransactionReviewScreen extends StatelessWidget {
  const SmsTransactionReviewScreen({super.key});

  static Future<void> showReviewSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SmsDetectionBloc>(),
        child: const _SmsTransactionReviewSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Review SMS Transaction',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: const FinxlPageBody(
        maxWidth: 760,
        child: _ReviewContent(isFullPage: true),
      ),
    );
  }
}

class _SmsTransactionReviewSheet extends StatelessWidget {
  const _SmsTransactionReviewSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: const _ReviewContent(),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({this.isFullPage = false});

  final bool isFullPage;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmsDetectionBloc, SmsDetectionState>(
      listenWhen: (previous, current) =>
          !previous.savedTransaction && current.savedTransaction,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-detected transaction saved.')),
        );
        if (!isFullPage) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final candidate = state.pendingCandidate;
        if (candidate == null) {
          return SectionCard(
            child: Text(
              'No transaction is waiting for review.',
              style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: Column(
            key: ValueKey(candidate.rawBody),
            mainAxisSize: isFullPage ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isFullPage)
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              _DetectionHeader(candidate: candidate),
              const SizedBox(height: 16),
              _CandidateDetails(candidate: candidate),
              const SizedBox(height: 16),
              Text(
                candidate.rawBody,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<SmsDetectionBloc>().dismissPending();
                        if (!isFullPage) Navigator.of(context).pop();
                      },
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.status == LoadStatus.loading
                          ? null
                          : () => context
                                .read<SmsDetectionBloc>()
                                .confirmPending(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text(
                        state.status == LoadStatus.loading
                            ? 'Saving...'
                            : 'Confirm',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetectionHeader extends StatelessWidget {
  const _DetectionHeader({required this.candidate});

  final SmsTransactionCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final color = candidate.type == TransactionType.income
        ? AppTheme.primary
        : AppTheme.secondary;
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.86, end: 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.auto_awesome, color: color),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto-detected transaction',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${(candidate.confidence * 100).round()}% confidence',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CandidateDetails extends StatelessWidget {
  const _CandidateDetails({required this.candidate});

  final SmsTransactionCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _DetailRow(label: 'Amount', value: formatCurrency(candidate.amount)),
          _DetailRow(label: 'Merchant', value: candidate.merchant),
          _DetailRow(
            label: 'Type',
            value: candidate.type == TransactionType.income
                ? 'Credit'
                : 'Debit',
          ),
          _DetailRow(
            label: 'Payment',
            value: candidate.paymentMethod.label,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
