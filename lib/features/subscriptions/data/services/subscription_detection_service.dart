import 'package:finxl/core/models/subscription.dart';
import 'package:finxl/core/models/transaction.dart';

class SubscriptionDetectionService {
  static const List<String> subscriptionKeywords = [
    'netflix',
    'spotify',
    'prime',
    'youtube',
    'chatgpt',
    'apple',
    'google play',
    'cloud',
    'openai',
    'microsoft',
    'adobe',
    'figma',
    'github',
    'canva',
    'hotstar',
    'zee5',
    'sony liv',
    'jio',
    'airtel',
  ];

  /// Detects potential subscriptions from a list of transactions.
  List<SubscriptionCandidate> detectCandidates(List<Transaction> transactions) {
    final Map<String, List<Transaction>> groupedByMerchant = {};

    for (final tx in transactions) {
      if (tx.type != TransactionType.expense) continue;

      final merchant = _normalizeMerchant(tx.description);
      groupedByMerchant.putIfAbsent(merchant, () => []).add(tx);
    }

    final List<SubscriptionCandidate> candidates = [];

    groupedByMerchant.forEach((merchant, txs) {
      if (txs.length < 2) return;

      // Sort by date descending
      txs.sort((a, b) => b.date.compareTo(a.date));

      final double avgAmount = txs.map((e) => e.amount).reduce((a, b) => a + b) / txs.length;
      final bool consistentAmount = txs.every((tx) => (tx.amount - avgAmount).abs() / avgAmount <= 0.05);

      if (!consistentAmount) return;

      final List<int> intervals = [];
      for (int i = 0; i < txs.length - 1; i++) {
        intervals.add(txs[i].date.difference(txs[i + 1].date).inDays);
      }

      final bool isMonthly = intervals.every((days) => days >= 25 && days <= 35);
      final bool isYearly = intervals.every((days) => days >= 330 && days <= 390);

      if (isMonthly || isYearly) {
        candidates.add(SubscriptionCandidate(
          name: merchant,
          amount: avgAmount,
          recurrence: isMonthly ? RecurrenceType.monthly : RecurrenceType.yearly,
          transactions: txs,
        ));
      } else if (_isKnownSubscription(merchant)) {
        // Even if frequency is slightly off, if it's a known sub and frequent enough
        candidates.add(SubscriptionCandidate(
          name: merchant,
          amount: avgAmount,
          recurrence: RecurrenceType.monthly, // Default to monthly
          transactions: txs,
        ));
      }
    });

    return candidates;
  }

  String _normalizeMerchant(String description) {
    String normalized = description.toLowerCase();
    // Remove common transaction noise
    normalized = normalized.replaceAll(RegExp(r'\d+'), '');
    normalized = normalized.replaceAll(RegExp(r'up[iI]'), '');
    normalized = normalized.replaceAll(RegExp(r'txn'), '');
    normalized = normalized.trim();
    return normalized;
  }

  bool _isKnownSubscription(String merchant) {
    final lowerMerchant = merchant.toLowerCase();
    return subscriptionKeywords.any((keyword) => lowerMerchant.contains(keyword));
  }
}

class SubscriptionCandidate {
  final String name;
  final double amount;
  final RecurrenceType recurrence;
  final List<Transaction> transactions;

  SubscriptionCandidate({
    required this.name,
    required this.amount,
    required this.recurrence,
    required this.transactions,
  });
}
