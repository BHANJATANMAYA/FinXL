import 'package:finxl/core/database/local_database_service.dart';
import 'package:finxl/core/models/sync_metadata.dart';
import 'package:finxl/core/models/transaction.dart' as core;
import 'package:finxl/core/utils/finance_lookups.dart';
import 'package:finxl/features/transactions/domain/entities/transaction_form_config.dart';
import 'package:finxl/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({LocalDatabaseService? databaseService})
    : _databaseService = databaseService ?? LocalDatabaseService.instance;

  final LocalDatabaseService _databaseService;

  @override
  Future<TransactionFormConfig> fetchConfig() async {
    return const TransactionFormConfig(
      categories: FinanceLookups.transactionCategories,
      paymentMethods: [
        PaymentMethod.upi,
        PaymentMethod.cash,
        PaymentMethod.card,
      ],
    );
  }

  @override
  Future<List<core.Transaction>> getTransactions({
    int? limit,
    int? offset,
  }) async {
    final db = await _databaseService.database;
    final rows = await db.query(
      LocalDatabaseService.transactionsTable,
      where: 'deleted_at IS NULL',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map(core.Transaction.fromMap).toList(growable: false);
  }

  @override
  Future<core.Transaction?> getTransactionById(int id) async {
    final row = await _databaseService.queryById(
      LocalDatabaseService.transactionsTable,
      id,
    );

    if (row == null) return null;
    return core.Transaction.fromMap(row);
  }

  @override
  Future<int> addTransaction(core.Transaction transaction) async {
    final values = withLocalSyncDefaults(
      Map<String, Object?>.from(transaction.toMap())..remove('id'),
    );
    return _databaseService.insert(
      LocalDatabaseService.transactionsTable,
      values,
    );
  }

  @override
  Future<void> updateTransaction(core.Transaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError('Transaction id is required for update.');
    }

    final values = withLocalSyncDefaults(
      Map<String, Object?>.from(transaction.toMap())..remove('id'),
    )..remove('created_at');
    await _databaseService.update(
      LocalDatabaseService.transactionsTable,
      values,
      id,
    );
  }

  @override
  Future<void> deleteTransaction(int id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _databaseService.rawUpdate(
      'UPDATE ${LocalDatabaseService.transactionsTable} SET sync_status = ?, deleted_at = ?, updated_at = ? WHERE id = ?',
      [SyncStatus.deleted.value, now, now, id],
    );
  }
}
