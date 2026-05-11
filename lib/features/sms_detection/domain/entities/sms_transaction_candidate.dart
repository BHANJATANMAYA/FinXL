import 'package:equatable/equatable.dart';
import 'package:finxl/core/models/transaction.dart';

enum SmsPaymentMethod { upi, card, bank, wallet }

extension SmsPaymentMethodX on SmsPaymentMethod {
  String get label {
    return switch (this) {
      SmsPaymentMethod.upi => 'UPI',
      SmsPaymentMethod.card => 'Card',
      SmsPaymentMethod.bank => 'Bank',
      SmsPaymentMethod.wallet => 'Wallet',
    };
  }
}

class SmsTransactionCandidate extends Equatable {
  const SmsTransactionCandidate({
    required this.amount,
    required this.merchant,
    required this.type,
    required this.paymentMethod,
    required this.timestamp,
    required this.rawBody,
    this.sender,
    this.confidence = 0.72,
  });

  final double amount;
  final String merchant;
  final TransactionType type;
  final SmsPaymentMethod paymentMethod;
  final DateTime timestamp;
  final String rawBody;
  final String? sender;
  final double confidence;

  SmsTransactionCandidate copyWith({
    double? amount,
    String? merchant,
    TransactionType? type,
    SmsPaymentMethod? paymentMethod,
    DateTime? timestamp,
    String? rawBody,
    String? sender,
    double? confidence,
  }) {
    return SmsTransactionCandidate(
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      type: type ?? this.type,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      timestamp: timestamp ?? this.timestamp,
      rawBody: rawBody ?? this.rawBody,
      sender: sender ?? this.sender,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [
    amount,
    merchant,
    type,
    paymentMethod,
    timestamp,
    rawBody,
    sender,
    confidence,
  ];
}
