import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'main.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        db.execute('''CREATE TABLE ${ContactObject.tableName} (
        ${ContactObject.nameColumnName} TEXT PRIMARY KEY,
        ${ContactObject.balanceColumnName} INTEGER NOT NULL
      )''');
        db.execute('''CREATE TABLE ${PaymentObject.tableName} (
        ${PaymentObject.idColumnName} INTEGER PRIMARY KEY,
        ${PaymentObject.contactNameColumnName} TEXT,
        ${PaymentObject.valueColumnName} INTEGER,
        ${PaymentObject.typeColumnName} INTEGER,
        ${PaymentObject.createdAtColumnName} INTEGER NOT NULL,
        ${PaymentObject.descriptionColumnName} TEXT
      )''');
      },
    );
  }

  Future<void> resetDatabase() async {
    String databasesPath = await getDatabasesPath();

    final path = join(databasesPath, 'main.db');

    final db = await database;

    await db.close();

    await deleteDatabase(path);

    _database = await _initDatabase();
  }
}
