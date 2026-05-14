import 'package:finxl/core/models/subscription.dart';
import 'package:finxl/core/presentation/widgets/finxl_page_body.dart';
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/features/subscriptions/presentation/cubit/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscriptions',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state.isLoading && state.subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return FinxlPageBody(
            child: ListView(
              children: [
                _OverviewCard(total: state.totalMonthlyAmount),
                const SizedBox(height: 24),
                if (state.candidates.isNotEmpty) ...[
                  _CandidatesSection(candidates: state.candidates),
                  const SizedBox(height: 24),
                ],
                _SubscriptionsList(subscriptions: state.subscriptions),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final double total;
  const _OverviewCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'MONTHLY TOTAL',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(total),
            style: GoogleFonts.manrope(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidatesSection extends StatelessWidget {
  final List<dynamic> candidates;
  const _CandidatesSection({required this.candidates});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DETECTED SUBSCRIPTIONS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...candidates.map((c) => _CandidateTile(candidate: c)).toList(),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final dynamic candidate;
  const _CandidateTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${formatCurrency(candidate.amount)} / ${candidate.recurrence.name}',
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final sub = Subscription(
                name: candidate.name,
                amount: candidate.amount,
                recurrence: candidate.recurrence,
                startDate: candidate.transactions.last.date,
                nextRenewalDate: DateTime.now().add(const Duration(days: 30)), // Simplified
                isActive: true,
              );
              context.read<SubscriptionBloc>().add(AddSubscription(sub));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionsList extends StatelessWidget {
  final List<Subscription> subscriptions;
  const _SubscriptionsList({required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No active subscriptions',
            style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR SUBSCRIPTIONS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: subscriptions.map((sub) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Text(
                  sub.name,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Next: ${formatShortDate(sub.nextRenewalDate)}',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(sub.amount),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      sub.recurrence.name,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                   context.read<SubscriptionBloc>().add(ToggleSubscriptionStatus(sub));
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String formatShortDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)}';
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
