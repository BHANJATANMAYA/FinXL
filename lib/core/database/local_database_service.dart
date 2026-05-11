import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService instance = LocalDatabaseService._();

  static const String databaseName = 'finxl.db';
  static const int databaseVersion = 3;

  static const String transactionsTable = 'transactions';
  static const String goalsTable = 'goals';
  static const String budgetsTable = 'budgets';
  static const String billsTable = 'bills';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, databaseName);

    return openDatabase(
      dbPath,
      version: databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        source_type TEXT NOT NULL DEFAULT 'manual',
        is_auto_detected INTEGER NOT NULL DEFAULT 0,
        sms_raw_body TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE $goalsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        deadline TEXT NOT NULL,
        color TEXT,
        icon TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE $budgetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        spent_amount REAL NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE $billsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        recurrence TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'bill',
        is_active INTEGER NOT NULL DEFAULT 1
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfMissing(
        db,
        billsTable,
        'type',
        "ALTER TABLE $billsTable ADD COLUMN type TEXT NOT NULL DEFAULT 'bill'",
      );
      await _addColumnIfMissing(
        db,
        billsTable,
        'is_active',
        'ALTER TABLE $billsTable ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
    }

    if (oldVersion < 3) {
      await _addColumnIfMissing(
        db,
        transactionsTable,
        'source_type',
        "ALTER TABLE $transactionsTable ADD COLUMN source_type TEXT NOT NULL DEFAULT 'manual'",
      );
      await _addColumnIfMissing(
        db,
        transactionsTable,
        'is_auto_detected',
        'ALTER TABLE $transactionsTable ADD COLUMN is_auto_detected INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(
        db,
        transactionsTable,
        'sms_raw_body',
        'ALTER TABLE $transactionsTable ADD COLUMN sms_raw_body TEXT',
      );
    }

    if (oldVersion == newVersion) {
      return;
    }
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String statement,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((item) => item['name'] == column);
    if (!exists) {
      await db.execute(statement);
    }
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  Future<List<Map<String, Object?>>> queryAll(
    String table, {
    String? orderBy,
    String? where,
    List<Object?>? whereArgs,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );
  }

  Future<Map<String, Object?>?> queryById(String table, int id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  Future<int> update(String table, Map<String, Object?> values, int id) async {
    final db = await database;
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawUpdate(sql, arguments);
  }

  Future<void> close() async {
    if (_database == null) return;
    await _database!.close();
    _database = null;
  }
}
