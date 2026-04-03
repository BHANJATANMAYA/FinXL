import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/presentation/widgets/section_card.dart';
import 'package:finxl/core/theme/app_theme.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/core/utils/formatters.dart';
import 'package:finxl/core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionListCard extends StatelessWidget {
  const TransactionListCard({required this.transactions, super.key});

  final List<core.Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(transactions.length, (index) {
          final transaction = transactions[index];
          return Column(
            children: [
              TransactionListTile(transaction: transaction),
              if (index < transactions.length - 1)
                const Divider(height: 1, indent: 80, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({required this.transaction, super.key});

  final core.Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final category = FinanceLookups.transactionCategory(transaction.categoryId);
    final isIncome = transaction.type == core.TransactionType.income;
    final amountColor = isIncome ? AppTheme.primary : AppTheme.onSurface;
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(resolveIcon(category.iconKey), color: AppTheme.primary),
      ),
      title: Text(
        transaction.description,
        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        transaction.paymentMethod != 'N/A'
            ? '${FinanceLookups.formatShortDate(transaction.date)} • ${transaction.paymentMethod}'
            : FinanceLookups.formatShortDate(transaction.date),
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '$prefix${formatCurrency(transaction.amount)}',
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: amountColor,
        ),
      ),
    );
  }
}
