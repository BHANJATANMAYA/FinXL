import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';

class FinanceLookups {
  FinanceLookups._();

  static const List<TransactionCategory> transactionCategories = [
    TransactionCategory(id: 'food', label: 'Food', iconKey: 'restaurant'),
    TransactionCategory(id: 'shopping', label: 'Shopping', iconKey: 'shopping'),
    TransactionCategory(id: 'travel', label: 'Travel', iconKey: 'travel'),
    TransactionCategory(id: 'health', label: 'Health', iconKey: 'health'),
    TransactionCategory(id: 'bills', label: 'Bills', iconKey: 'bill'),
    TransactionCategory(
      id: 'subscriptions',
      label: 'Subscriptions',
      iconKey: 'subscription',
    ),
    TransactionCategory(id: 'fitness', label: 'Gym', iconKey: 'gym'),
    TransactionCategory(id: 'other', label: 'Other', iconKey: 'other'),
  ];

  static const List<String> _accents = [
    'primary',
    'secondary',
    'tertiary',
    'warning',
  ];

  static const Map<String, int> _transactionCategoryIds = {
    'food': 1,
    'shopping': 2,
    'travel': 3,
    'health': 4,
    'bills': 5,
    'subscriptions': 6,
    'fitness': 7,
    'other': 8,
  };

  static int transactionCategoryDbId(String formId) {
    return _transactionCategoryIds[formId] ?? _transactionCategoryIds['other']!;
  }

  static int transactionCategoryDbIdFromLabel(String label) {
    final normalized = label.toLowerCase();
    final category = transactionCategories.firstWhere(
      (item) => item.label.toLowerCase() == normalized,
      orElse: () => const TransactionCategory(
        id: 'other',
        label: 'Other',
        iconKey: 'other',
      ),
    );
    return transactionCategoryDbId(category.id);
  }

  static String transactionCategoryFormId(int categoryId) {
    return _transactionCategoryIds.entries
        .firstWhere(
          (entry) => entry.value == categoryId,
          orElse: () => const MapEntry('other', 8),
        )
        .key;
  }

  static TransactionCategory transactionCategory(int categoryId) {
    final formId = transactionCategoryFormId(categoryId);
    return transactionCategories.firstWhere(
      (category) => category.id == formId,
      orElse: () => const TransactionCategory(
        id: 'other',
        label: 'Other',
        iconKey: 'other',
      ),
    );
  }

  static String accentForIndex(int index) => _accents[index % _accents.length];

  static String budgetIconKey(String categoryName) {
    final value = categoryName.toLowerCase();
    if (value.contains('rent') || value.contains('house')) {
      return 'housing';
    }
    if (value.contains('food') || value.contains('dining')) {
      return 'restaurant';
    }
    if (value.contains('movie') || value.contains('fun')) {
      return 'entertainment';
    }
    if (value.contains('utility') ||
        value.contains('electric') ||
        value.contains('water')) {
      return 'utilities';
    }
    if (value.contains('subscription')) {
      return 'subscription';
    }
    if (value.contains('travel')) {
      return 'travel';
    }
    if (value.contains('health')) {
      return 'health';
    }
    if (value.contains('gym') || value.contains('fitness')) {
      return 'gym';
    }
    if (value.contains('shop')) {
      return 'shopping';
    }
    return transactionCategories
        .firstWhere(
          (item) => item.label.toLowerCase() == value,
          orElse: () => const TransactionCategory(
            id: 'other',
            label: 'Other',
            iconKey: 'other',
          ),
        )
        .iconKey;
  }

  static String budgetStatusLabel(double progress) {
    if (progress >= 1) {
      return 'Exceeded';
    }
    if (progress >= 0.7) {
      return 'Getting Close';
    }
    return 'On Track';
  }

  static String budgetAccent(double progress) {
    if (progress > 1) {
      return 'danger';
    }
    if (progress >= 0.7) {
      return 'warning';
    }
    return 'primary';
  }

  static BillCategory billCategory(String type, String title) {
    final normalized = '$type ${title.toLowerCase()}'.toLowerCase();
    if (normalized.contains('emi') || normalized.contains('loan')) {
      return BillCategory.emi;
    }
    if (normalized.contains('subscription')) {
      return BillCategory.subscription;
    }
    return BillCategory.bill;
  }

  static String billTypeValue(BillCategory category) {
    return switch (category) {
      BillCategory.subscription => 'subscription',
      BillCategory.bill => 'bill',
      BillCategory.emi => 'emi',
    };
  }

  static String billIconKey(BillCategory category, String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('internet') || normalized.contains('wifi')) {
      return 'wifi';
    }
    if (normalized.contains('electric')) {
      return 'utilities';
    }
    if (normalized.contains('mortgage') || normalized.contains('rent')) {
      return 'housing';
    }
    return switch (category) {
      BillCategory.subscription => 'subscription',
      BillCategory.bill => 'bill',
      BillCategory.emi => 'emi',
    };
  }

  static String billAccent(BillCategory category) {
    return switch (category) {
      BillCategory.subscription => 'tertiary',
      BillCategory.bill => 'secondary',
      BillCategory.emi => 'warning',
    };
  }

  static String billSectionLabel(DateTime dueDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue';
    }
    if (difference <= 7) {
      return 'Due This Week';
    }
    if (due.month == now.month && due.year == now.year) {
      return 'Later This Month';
    }
    return 'Upcoming';
  }

  static String formatShortDate(DateTime date) {
    final month = shortMonthLabel(date);
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day';
  }

  static String shortMonthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[date.month - 1];
  }

  static String shortWeekdayLabel(DateTime date, {bool uppercase = false}) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final label = weekdays[date.weekday - 1];
    return uppercase ? label.toUpperCase() : label;
  }

  static double safeRatio(double numerator, double denominator) {
    if (denominator <= 0) {
      return 0;
    }
    final ratio = numerator / denominator;
    if (ratio.isNaN || ratio.isInfinite) {
      return 0;
    }
    return ratio.clamp(0, 1).toDouble();
  }
}
