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
        r'\b(?:on|at|to|for|from)\s+([a-z][a-z0-9 &._-]{2,30})',
        caseSensitive: false,
      ),
      RegExp(
        r'\b([a-z][a-z0-9 &._-]{2,30})\s+(?:debited|credited|spent|used|paid|received)',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final matches = pattern.allMatches(body);
      for (final match in matches) {
        final raw = match.group(1);
        if (raw == null) continue;
        final cleaned = _cleanMerchant(raw);
        if (cleaned.isNotEmpty &&
            !_looksLikeBankingNoise(cleaned) &&
            !_isInvalidMerchant(cleaned)) {
          return cleaned;
        }
      }
    }
    return fallback;
  }

  String _cleanMerchant(String value) {
    var cleaned = value;

    // Find the first occurrence of boundary words and truncate
    final boundaryPatterns = [
      RegExp(
        r'\b(?:using|via|ending|through|with|by|a/c|account|card|bank)\b',
        caseSensitive: false,
      ),
    ];
    for (final pattern in boundaryPatterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        cleaned = cleaned.substring(0, match.start);
      }
    }

    // Trim leading/trailing punctuation and spaces
    cleaned = cleaned
        .replaceAll(RegExp(r'^[.,:;_\-\s]+'), '')
        .replaceAll(RegExp(r'[.,:;_\-\s]+$'), '');

    final words = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(
          RegExp(r'\b(?:rs|inr)\b', caseSensitive: false),
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

  bool _isInvalidMerchant(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 2) return true;

    // If it's just numbers, dots, commas, spaces, or common currency symbols
    final numericOnly = trimmed.replaceAll(RegExp(r'[0-9\s.,₹$£€-]'), '');
    if (numericOnly.isEmpty) return true;

    // If it looks like a date (e.g., 12-04-23)
    if (RegExp(r'^\d+[\/\-]\d+[\/\-]\d+$').hasMatch(trimmed)) return true;

    // If it looks like a ref/UUID/Hex noise
    if (RegExp(r'^[0-9a-fA-F\-]{8,}$').hasMatch(trimmed)) return true;

    final lower = trimmed.toLowerCase();
    final invalidKeywords = {
      'otp',
      'sms',
      'charge',
      'charges',
      'balance',
      'fee',
      'fees',
      'available',
      'limit',
      'credit limit',
      'overdraft',
      'interest',
    };
    if (invalidKeywords.contains(lower)) return true;

    return false;
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
