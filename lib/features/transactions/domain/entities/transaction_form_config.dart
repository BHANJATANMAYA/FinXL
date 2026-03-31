import 'package:equatable/equatable.dart';

enum TransactionType { expense, income }

enum PaymentMethod { upi, cash, card }

class TransactionFormConfig extends Equatable {
  const TransactionFormConfig({
    required this.categories,
    required this.paymentMethods,
  });

  final List<TransactionCategory> categories;
  final List<PaymentMethod> paymentMethods;

  @override
  List<Object> get props => [categories, paymentMethods];
}

class TransactionCategory extends Equatable {
  const TransactionCategory({
    required this.id,
    required this.label,
    required this.iconKey,
  });

  final String id;
  final String label;
  final String iconKey;

  @override
  List<Object> get props => [id, label, iconKey];
}
