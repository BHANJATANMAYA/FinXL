import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/features/sms_detection/data/services/sms_parser_engine.dart';
import 'package:finxl/features/sms_detection/domain/entities/detected_sms_message.dart';
import 'package:finxl/features/sms_detection/domain/entities/sms_transaction_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsParserEngine Tests', () {
    late SmsParserEngine parser;

    setUp(() {
      parser = SmsParserEngine();
    });

    test('should parse debit transaction with exact merchant Starbucks', () {
      final msg = DetectedSmsMessage(
        body: 'Rs 500.00 debited from A/c XXXXXX1234 towards UPI payment to Starbucks.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'STARBUCKS-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNotNull);
      expect(candidate!.amount, 500.0);
      expect(candidate.merchant, 'Starbucks');
      expect(candidate.type, TransactionType.expense);
      expect(candidate.paymentMethod, SmsPaymentMethod.upi);
    });

    test('should parse debit transaction with comma amount and extract Amazon Pay', () {
      final msg = DetectedSmsMessage(
        body: 'Your a/c x1234 is debited for Rs.1,500.00 on 12-04-23 by UPI ref no 3102 to Amazon Pay.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'BANK-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNotNull);
      expect(candidate!.amount, 1500.0);
      expect(candidate.merchant, 'Amazon Pay');
      expect(candidate.type, TransactionType.expense);
      expect(candidate.paymentMethod, SmsPaymentMethod.upi);
    });

    test('should ignore OTP messages', () {
      final msg = DetectedSmsMessage(
        body: 'Dear Customer, OTP for transaction of Rs 5000.00 at Swiggy is 482910. Do not share this with anyone.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'OTP-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNull);
    });

    test('should parse credit/income transaction with John Doe', () {
      final msg = DetectedSmsMessage(
        body: 'Rs. 200.00 received in your A/c XXXXXX5678 via UPI from John Doe.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'BANK-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNotNull);
      expect(candidate!.amount, 200.0);
      expect(candidate.merchant, 'John Doe');
      expect(candidate.type, TransactionType.income);
      expect(candidate.paymentMethod, SmsPaymentMethod.upi);
    });

    test('should ignore promo messages', () {
      final msg = DetectedSmsMessage(
        body: 'Get 50% off on your next purchase at Dominos! Use coupon DOM50. Valid till tomorrow.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'DOMINOS-PROMO',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNull);
    });

    test('should parse spent transaction using Card and extract Uber India', () {
      final msg = DetectedSmsMessage(
        body: 'Transaction alert: Rs. 120.00 spent on Uber India using Card ending 9876.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'BANK-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNotNull);
      expect(candidate!.amount, 120.0);
      expect(candidate.merchant, 'Uber India');
      expect(candidate.type, TransactionType.expense);
      expect(candidate.paymentMethod, SmsPaymentMethod.card);
    });

    test('should ignore general account charges / SMS charges', () {
      final msg = DetectedSmsMessage(
        body: 'Dear customer, Rs 45.00 has been debited from your account for SMS charges.',
        receivedAt: DateTime(2026, 6, 3),
        sender: 'BANK-ALERT',
      );

      final candidate = parser.parse(msg);

      expect(candidate, isNull);
    });
  });
}
