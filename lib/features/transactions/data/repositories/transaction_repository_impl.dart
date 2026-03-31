import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl();

  @override
  Future<TransactionFormConfig> fetchConfig() async {
    return const TransactionFormConfig(
      categories: [
        TransactionCategory(id: 'food', label: 'Food', iconKey: 'restaurant'),
        TransactionCategory(id: 'shopping', label: 'Shopping', iconKey: 'shopping'),
        TransactionCategory(id: 'travel', label: 'Travel', iconKey: 'travel'),
        TransactionCategory(id: 'health', label: 'Health', iconKey: 'health'),
        TransactionCategory(id: 'bills', label: 'Bills', iconKey: 'bill'),
        TransactionCategory(id: 'subscriptions', label: 'Subs', iconKey: 'subscription'),
        TransactionCategory(id: 'fitness', label: 'Gym', iconKey: 'gym'),
        TransactionCategory(id: 'other', label: 'Other', iconKey: 'other'),
      ],
      paymentMethods: [PaymentMethod.upi, PaymentMethod.cash, PaymentMethod.card],
    );
  }
}
