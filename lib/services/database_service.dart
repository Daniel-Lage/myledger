import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  final String _contactsTableName = "contacts";
  final String _contactsNameColumnName = "name";
  final String _contactsDebtColumnName = "debt";

  final String _paymentsTableName = "payments";
  final String _paymentsContactNameColumnName = "contactName";
  final String _paymentsIdColumnName = "id";
  final String _paymentsValueColumnName = "value";
  final String _paymentsTypeColumnName = "type";

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
        db.execute('''CREATE TABLE $_contactsTableName (
        $_contactsNameColumnName TEXT PRIMARY KEY,
        $_contactsDebtColumnName INTEGER NOT NULL
      )''');
        db.execute('''CREATE TABLE $_paymentsTableName (
        $_paymentsIdColumnName INTEGER PRIMARY KEY,
        $_paymentsContactNameColumnName TEXT,
        $_paymentsValueColumnName INTEGER,
        $_paymentsTypeColumnName INTEGER
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

  Future<void> addContact(ContactObject contact) async {
    final db = await database;

    final hasContact = (await db.query(
      _contactsTableName,
      where: '$_contactsNameColumnName = ?',
      whereArgs: [contact.name],
    )).isNotEmpty;

    if (!hasContact) {
      await db.insert(_contactsTableName, {
        _contactsNameColumnName: contact.name,
        _contactsDebtColumnName: contact.debt,
      });
    }
  }

  Future<void> removeContact(String name) async {
    final db = await database;

    final hasContact = (await db.query(
      _contactsTableName,
      where: '$_contactsNameColumnName = ?',
      whereArgs: [name],
    )).isNotEmpty;

    if (hasContact) {
      await db.delete(
        _contactsTableName,
        where: '$_contactsNameColumnName = ?',
        whereArgs: [name],
      );

      await db.delete(
        _paymentsTableName,
        where: '$_paymentsContactNameColumnName = ?',
        whereArgs: [name],
      );
    }
  }

  Future<List<ContactObject>> getContactsTable() async {
    final db = await database;
    final contactsTable = await db.query(_contactsTableName);
    return contactsTable
        .map(
          (contactMap) => ContactObject(
            name: contactMap[_contactsNameColumnName] as String,
            debt: contactMap[_contactsDebtColumnName] as int,
          ),
        )
        .toList();
  }

  Future<void> updateContact(ContactObject contact) async {
    final db = await database;
    await db.update(
      _contactsTableName,
      contact.toMap(),
      where: '$_contactsNameColumnName = ?',
      whereArgs: [contact.name],
    );
  }

  Future<List<PaymentObject>> getPaymentsTable() async {
    final db = await database;
    final paymentsTable = await db.query(_paymentsTableName);
    return paymentsTable
        .map(
          (paymentMap) => PaymentObject(
            contactName: paymentMap[_paymentsContactNameColumnName] as String,
            value: paymentMap[_paymentsValueColumnName] as int,
            type: paymentMap[_paymentsTypeColumnName] == 1
                ? PaymentType.minus
                : PaymentType.plus,
          ),
        )
        .toList();
  }

  Future<List<PaymentObject>> getContactsPayments(String contactName) async {
    final db = await database;
    final paymentsTable = await db.query(
      _paymentsTableName,
      where: '$_paymentsContactNameColumnName = ?',
      whereArgs: [contactName],
    );
    return paymentsTable
        .map(
          (paymentMap) => PaymentObject(
            contactName: paymentMap[_paymentsContactNameColumnName] as String,
            value: paymentMap[_paymentsValueColumnName] as int,
            type: paymentMap[_paymentsTypeColumnName] == 1
                ? PaymentType.minus
                : PaymentType.plus,
          ),
        )
        .toList();
  }

  Future<void> addPayment(PaymentObject payment) async {
    final db = await database;
    await db.insert(_paymentsTableName, {
      _paymentsContactNameColumnName: payment.contactName,
      _paymentsValueColumnName: payment.value,
      _paymentsTypeColumnName: payment.type == PaymentType.minus ? 1 : 0,
    });
  }
}
