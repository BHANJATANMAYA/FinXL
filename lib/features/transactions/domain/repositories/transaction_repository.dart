import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';

abstract class TransactionRepository {
  Future<TransactionFormConfig> fetchConfig();
}
