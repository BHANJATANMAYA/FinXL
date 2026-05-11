import 'package:finxl/core/models/transaction.dart';
import 'package:finxl/features/ai_categorization/data/services/ai_categorization_service.dart';
import 'package:finxl/features/sms_detection/domain/entities/sms_transaction_candidate.dart';

class SmsTransactionMapper {
  SmsTransactionMapper({AiCategorizationService? categorizationService})
    : _categorizationService =
          categorizationService ?? AiCategorizationService();

  final AiCategorizationService _categorizationService;

  Transaction toTransaction(SmsTransactionCandidate candidate) {
    final prediction = _categorizationService.predictCategory(
      candidate.merchant,
    );
    return Transaction(
      amount: candidate.amount,
      date: candidate.timestamp,
      description: candidate.merchant,
      type: candidate.type,
      paymentMethod: candidate.paymentMethod.label,
      categoryId: candidate.type == TransactionType.income
          ? 9
          : prediction.categoryId,
      sourceType: TransactionSourceType.sms,
      isAutoDetected: true,
      smsRawBody: candidate.rawBody,
    );
  }
}
