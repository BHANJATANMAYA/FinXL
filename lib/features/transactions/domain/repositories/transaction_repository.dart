import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';

abstract class TransactionRepository {
  Future<TransactionFormConfig> fetchConfig();
  Future<List<core.Transaction>> getTransactions({int? limit, int? offset});
  Future<core.Transaction?> getTransactionById(int id);
  Future<int> addTransaction(core.Transaction transaction);
  Future<void> updateTransaction(core.Transaction transaction);
  Future<void> deleteTransaction(int id);
}
