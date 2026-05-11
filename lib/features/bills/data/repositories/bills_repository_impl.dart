import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/bill.dart';
import 'package:finxl/core/models/sync_metadata.dart';
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/bills/domain/entities/bills_overview.dart';
import 'package:finxl/features/bills/domain/repositories/bills_repository.dart';

class BillsRepositoryImpl implements BillsRepository {
  BillsRepositoryImpl({LocalDatabaseService? databaseService})
    : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<BillsOverview> fetchOverview() async {
    final bills = await getBills();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledBills = bills
        .where(
          (bill) =>
              bill.isActive &&
              !bill.isPaid &&
              !_dateOnly(bill.dueDate).isBefore(today),
        )
        .toList(growable: false);

    return BillsOverview(
      scheduledAmount: scheduledBills.fold<double>(
        0,
        (sum, bill) => sum + bill.amount,
      ),
      reminderCount: scheduledBills.length,
      reminders: bills
          .map((bill) {
            final category = FinanceLookups.billCategory(bill.type, bill.title);
            return BillReminder(
              id: (bill.id ?? 0).toString(),
              title: bill.title,
              sectionLabel: FinanceLookups.billSectionLabel(bill.dueDate, now),
              dueLabel: FinanceLookups.formatShortDate(bill.dueDate),
              amount: bill.amount,
              iconKey: FinanceLookups.billIconKey(category, bill.title),
              accent: FinanceLookups.billAccent(category),
              category: category,
              isActive: bill.isActive,
              isFaded: bill.isPaid || !bill.isActive,
            );
          })
          .toList(growable: false),
    );
  }

  @override
  Future<List<Bill>> getBills() async {
    final rows = await _databaseService.queryAll(
      LocalDatabaseService.billsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'due_date ASC',
    );
    return rows.map(Bill.fromMap).toList(growable: false);
  }

  @override
  Future<Bill?> getBillById(int id) async {
    final row = await _databaseService.queryById(
      LocalDatabaseService.billsTable,
      id,
    );
    if (row == null) return null;
    return Bill.fromMap(row);
  }

  @override
  Future<int> addBill(Bill bill) async {
    final values = withLocalSyncDefaults(
      Map<String, Object?>.from(bill.toMap())..remove('id'),
    );
    return _databaseService.insert(LocalDatabaseService.billsTable, values);
  }

  @override
  Future<void> updateBill(Bill bill) async {
    final id = bill.id;
    if (id == null) {
      throw ArgumentError('Bill id is required for update.');
    }

    final values = withLocalSyncDefaults(
      Map<String, Object?>.from(bill.toMap())..remove('id'),
    )..remove('created_at');
    await _databaseService.update(LocalDatabaseService.billsTable, values, id);
  }

  @override
  Future<void> toggleBillActive(int id, bool isActive) async {
    await _databaseService.rawUpdate(
      'UPDATE ${LocalDatabaseService.billsTable} SET is_active = ?, sync_status = ?, updated_at = ? WHERE id = ?',
      [
        isActive ? 1 : 0,
        SyncStatus.pending.value,
        DateTime.now().toUtc().toIso8601String(),
        id,
      ],
    );
  }

  @override
  Future<void> deleteBill(int id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _databaseService.rawUpdate(
      'UPDATE ${LocalDatabaseService.billsTable} SET sync_status = ?, deleted_at = ?, updated_at = ? WHERE id = ?',
      [SyncStatus.deleted.value, now, now, id],
    );
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
