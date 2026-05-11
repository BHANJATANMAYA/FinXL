import 'package:finxl/core/utils/finance_lookups.dart';

class CategoryPrediction {
  const CategoryPrediction({
    required this.categoryId,
    required this.categoryLabel,
    required this.confidence,
    required this.reason,
  });

  final int categoryId;
  final String categoryLabel;
  final double confidence;
  final String reason;
}

class AiCategorizationService {
  static const Map<String, String> _merchantCategoryMap = {
    'swiggy': 'food',
    'zomato': 'food',
    'uber': 'travel',
    'ola': 'travel',
    'netflix': 'subscriptions',
    'spotify': 'subscriptions',
    'amazon': 'shopping',
    'flipkart': 'shopping',
    'apollo': 'health',
    'pharmacy': 'health',
  };

  static const Map<String, List<String>> _keywordMap = {
    'food': ['restaurant', 'cafe', 'dining', 'pizza', 'burger', 'food'],
    'travel': ['cab', 'taxi', 'fuel', 'metro', 'flight', 'train'],
    'subscriptions': ['prime', 'subscription', 'renewal', 'monthly plan'],
    'shopping': ['store', 'mall', 'mart', 'shop', 'retail'],
    'health': ['clinic', 'doctor', 'hospital', 'medical', 'medicine'],
    'bills': ['electricity', 'utility', 'broadband', 'mobile bill', 'gas'],
  };

  CategoryPrediction predictCategory(String merchantOrDescription) {
    final normalized = merchantOrDescription.toLowerCase();

    for (final entry in _merchantCategoryMap.entries) {
      if (normalized.contains(entry.key)) {
        return _prediction(entry.value, 0.94, 'Matched known merchant');
      }
    }

    for (final entry in _keywordMap.entries) {
      final matched = entry.value.any(normalized.contains);
      if (matched) {
        return _prediction(entry.key, 0.78, 'Matched spending keyword');
      }
    }

    if (normalized.contains('pay') || normalized.contains('upi')) {
      return _prediction('other', 0.54, 'Payment text with no clear merchant');
    }

    return _prediction('other', 0.48, 'Fallback category');
  }

  CategoryPrediction _prediction(
    String categoryFormId,
    double confidence,
    String reason,
  ) {
    final category = FinanceLookups.transactionCategories.firstWhere(
      (item) => item.id == categoryFormId,
      orElse: () => FinanceLookups.transactionCategories.firstWhere(
        (item) => item.id == 'other',
      ),
    );
    return CategoryPrediction(
      categoryId: FinanceLookups.transactionCategoryDbId(category.id),
      categoryLabel: category.label,
      confidence: confidence,
      reason: reason,
    );
  }
}
