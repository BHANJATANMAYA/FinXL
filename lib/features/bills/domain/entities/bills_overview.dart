import 'package:equatable/equatable.dart';

enum BillFilter { all, subscriptions, bills, emis }

enum BillCategory { subscription, bill, emi }

class BillsOverview extends Equatable {
  const BillsOverview({
    required this.scheduledAmount,
    required this.reminderCount,
    required this.reminders,
  });

  final double scheduledAmount;
  final int reminderCount;
  final List<BillReminder> reminders;

  @override
  List<Object> get props => [scheduledAmount, reminderCount, reminders];
}

class BillReminder extends Equatable {
  const BillReminder({
    required this.id,
    required this.title,
    required this.sectionLabel,
    required this.dueLabel,
    required this.amount,
    required this.iconKey,
    required this.accent,
    required this.category,
    required this.isActive,
    this.isFaded = false,
  });

  final String id;
  final String title;
  final String sectionLabel;
  final String dueLabel;
  final double amount;
  final String iconKey;
  final String accent;
  final BillCategory category;
  final bool isActive;
  final bool isFaded;

  BillReminder copyWith({bool? isActive}) {
    return BillReminder(
      id: id,
      title: title,
      sectionLabel: sectionLabel,
      dueLabel: dueLabel,
      amount: amount,
      iconKey: iconKey,
      accent: accent,
      category: category,
      isActive: isActive ?? this.isActive,
      isFaded: isFaded,
    );
  }

  @override
  List<Object> get props => [
        id,
        title,
        sectionLabel,
        dueLabel,
        amount,
        iconKey,
        accent,
        category,
        isActive,
        isFaded,
      ];
}
