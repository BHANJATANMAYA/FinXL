import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/features/sms_detection/domain/entities/detected_sms_message.dart';
import 'package:finxl/features/sms_detection/domain/entities/sms_transaction_candidate.dart';

class SmsParserEngine {
  static final _amountRegex = RegExp(
    r'(?:₹|rs\.?|inr)\s*([0-9,]+(?:\.[0-9]{1,2})?)|([0-9,]+(?:\.[0-9]{1,2})?)\s*(?:rs|inr)',
    caseSensitive: false,
  );
  static final _otpRegex = RegExp(
    r'\b(otp|one\s*time\s*password|verification\s*code|login\s*code|do\s*not\s*share)\b',
    caseSensitive: false,
  );
  static final _promoRegex = RegExp(
    r'\b(sale|offer|cashback offer|coupon|discount|win|deal|subscribe|valid till)\b',
    caseSensitive: false,
  );
  static final _financialRegex = RegExp(
    r'\b(debited|credited|spent|paid|received|used|withdrawn|purchase|upi|card|a/c|account|wallet|bank)\b',
    caseSensitive: false,
  );
  static final _debitRegex = RegExp(
    r'\b(debited|spent|paid|used|withdrawn|purchase|sent)\b',
    caseSensitive: false,
  );
  static final _creditRegex = RegExp(
    r'\b(credited|received|deposited|refund|cashback received)\b',
    caseSensitive: false,
  );

  SmsTransactionCandidate? parse(DetectedSmsMessage message) {
    final body = message.body.trim();
    if (body.isEmpty || !_isLikelyFinancialTransaction(body)) return null;

    final amount = _extractAmount(body);
    if (amount == null || amount <= 0) return null;

    final type = _creditRegex.hasMatch(body) && !_debitRegex.hasMatch(body)
        ? TransactionType.income
        : TransactionType.expense;
    final paymentMethod = _extractPaymentMethod(body);
    final merchant = _extractMerchant(body, fallback: paymentMethod.label);

    return SmsTransactionCandidate(
      amount: amount,
      merchant: merchant,
      type: type,
      paymentMethod: paymentMethod,
      timestamp: message.receivedAt,
      rawBody: body,
      sender: message.sender,
      confidence: _confidenceFor(body, merchant),
    );
  }

  bool _isLikelyFinancialTransaction(String body) {
    if (_otpRegex.hasMatch(body)) return false;
    if (_promoRegex.hasMatch(body) && !_financialRegex.hasMatch(body)) {
      return false;
    }
    return _financialRegex.hasMatch(body) && _amountRegex.hasMatch(body);
  }

  double? _extractAmount(String body) {
    final match = _amountRegex.firstMatch(body);
    final raw = match?.group(1) ?? match?.group(2);
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  SmsPaymentMethod _extractPaymentMethod(String body) {
    final lower = body.toLowerCase();
    if (lower.contains('upi')) return SmsPaymentMethod.upi;
    if (lower.contains('wallet') || lower.contains('paytm')) {
      return SmsPaymentMethod.wallet;
    }
    if (lower.contains('card') || lower.contains('ending')) {
      return SmsPaymentMethod.card;
    }
    return SmsPaymentMethod.bank;
  }

  String _extractMerchant(String body, {required String fallback}) {
    final patterns = [
      RegExp(
        r'\b(?:on|at|to|for)\s+([a-z][a-z0-9 &._-]{2,30})',
        caseSensitive: false,
      ),
      RegExp(
        r'\b([a-z][a-z0-9 &._-]{2,30})\s+(?:debited|credited|spent|used|paid)',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      final raw = match?.group(1);
      if (raw == null) continue;
      final cleaned = _cleanMerchant(raw);
      if (cleaned.isNotEmpty && !_looksLikeBankingNoise(cleaned)) {
        return cleaned;
      }
    }
    return fallback;
  }

  String _cleanMerchant(String value) {
    final words = value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(
            r'\b(?:rs|inr|via|using|ending|a/c|account)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (words.isEmpty) return '';
    return words
        .split(' ')
        .map((part) {
          if (part.isEmpty) return part;
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  bool _looksLikeBankingNoise(String value) {
    final lower = value.toLowerCase();
    return lower.contains('via') ||
        lower.contains('card') ||
        lower.contains('account') ||
        lower.contains('bank') ||
        lower.length < 2;
  }

  double _confidenceFor(String body, String merchant) {
    var score = 0.62;
    if (_debitRegex.hasMatch(body) || _creditRegex.hasMatch(body)) {
      score += 0.12;
    }
    if (!_looksLikeBankingNoise(merchant)) score += 0.12;
    if (RegExp(
      r'\b(upi|card|wallet|a/c|bank)\b',
      caseSensitive: false,
    ).hasMatch(body)) {
      score += 0.1;
    }
    return score.clamp(0.45, 0.96);
  }
}
