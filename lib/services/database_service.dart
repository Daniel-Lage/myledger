import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  final String _contactsTableName = "contacts";
  final String _contactsNameColumnName = "name";
  final String _contactsDebtColumnName = "debt";

  final String _transactionsTableName = "transactions";
  final String _transactionsContactNameColumnName = "contactName";
  final String _transactionsIdColumnName = "id";
  final String _transactionsValueColumnName = "value";
  final String _transactionsTypeColumnName = "type";

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async => await openDatabase(
    join(await getDatabasesPath(), 'main.db'),
    version: 1,
    onCreate: (db, version) {
      db.execute('''CREATE TABLE $_contactsTableName (
        $_contactsNameColumnName TEXT PRIMARY KEY,
        $_contactsDebtColumnName INTEGER NOT NULL
      )''');
      db.execute('''CREATE TABLE $_transactionsTableName (
        $_transactionsIdColumnName INTEGER NOT NULL AUTO_INCREMENT,
        $_transactionsContactNameColumnName TEXT,
        $_transactionsValueColumnName INTEGER,
        $_transactionsTypeColumnName INTEGER,
        PRIMARY KEY ($_transactionsIdColumnName)
      )''');
    },
  );

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
        _transactionsTableName,
        where: '$_transactionsContactNameColumnName = ?',
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

  Future<List<TransactionObject>> getTransactionsTable() async {
    final db = await database;
    final transactionsTable = await db.query(_transactionsTableName);
    return transactionsTable
        .map(
          (transactionMap) => TransactionObject(
            contactName:
                transactionMap[_transactionsContactNameColumnName] as String,
            value: transactionMap[_transactionsValueColumnName] as int,
            type: transactionMap[_transactionsTypeColumnName] == 1
                ? TransactionType.minus
                : TransactionType.plus,
          ),
        )
        .toList();
  }

  Future<List<TransactionObject>> getContactsTransactions(
    String contactName,
  ) async {
    final db = await database;
    final transactionsTable = await db.query(
      _transactionsTableName,
      where: '$_transactionsContactNameColumnName = ?',
      whereArgs: [contactName],
    );
    return transactionsTable
        .map(
          (transactionMap) => TransactionObject(
            contactName:
                transactionMap[_transactionsContactNameColumnName] as String,
            value: transactionMap[_transactionsValueColumnName] as int,
            type: transactionMap[_transactionsTypeColumnName] == 1
                ? TransactionType.minus
                : TransactionType.plus,
          ),
        )
        .toList();
  }

  Future<void> addTransaction(TransactionObject transaction) async {
    final db = await database;
    await db.insert(_transactionsTableName, {
      _transactionsContactNameColumnName: transaction.contactName,
      _transactionsValueColumnName: transaction.value,
      _transactionsTypeColumnName: transaction.type == TransactionType.minus
          ? 1
          : 0,
    });
  }
}
