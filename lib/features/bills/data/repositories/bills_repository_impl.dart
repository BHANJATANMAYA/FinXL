import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';

class BillsRepositoryImpl implements BillsRepository {
  const BillsRepositoryImpl();

  @override
  Future<BillsOverview> fetchOverview() async {
    return const BillsOverview(
      scheduledAmount: 1482.5,
      reminderCount: 8,
      reminders: [
        BillReminder(
          id: 'mortgage',
          title: 'Home Mortgage',
          sectionLabel: 'Due This Week',
          dueLabel: 'Jun 05',
          amount: 1200,
          iconKey: 'housing',
          accent: 'secondary',
          category: BillCategory.bill,
          isActive: true,
        ),
        BillReminder(
          id: 'netflix',
          title: 'Netflix Premium',
          sectionLabel: 'Due This Week',
          dueLabel: 'Jun 08',
          amount: 19.99,
          iconKey: 'subscription',
          accent: 'tertiary',
          category: BillCategory.subscription,
          isActive: true,
        ),
        BillReminder(
          id: 'electricity',
          title: 'Electricity Bill',
          sectionLabel: 'Later This Month',
          dueLabel: 'Jun 15',
          amount: 142,
          iconKey: 'utilities',
          accent: 'primary',
          category: BillCategory.bill,
          isActive: false,
        ),
        BillReminder(
          id: 'car-loan',
          title: 'Auto EMI',
          sectionLabel: 'Later This Month',
          dueLabel: 'Jun 22',
          amount: 85.4,
          iconKey: 'emi',
          accent: 'warning',
          category: BillCategory.emi,
          isActive: false,
          isFaded: true,
        ),
        BillReminder(
          id: 'internet',
          title: 'Fiber Internet',
          sectionLabel: 'Later This Month',
          dueLabel: 'Jun 28',
          amount: 65,
          iconKey: 'wifi',
          accent: 'secondary',
          category: BillCategory.subscription,
          isActive: true,
        ),
      ],
    );
  }
}
