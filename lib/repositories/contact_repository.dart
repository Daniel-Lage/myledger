import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ContactRepository {
  final DatabaseService _database;

  ContactRepository({required DatabaseService database}) : _database = database;

  Future<Database> get database async {
    return await _database.database;
  }

  Future<void> create(ContactObject contact) async {
    final db = await database;

    final hasContact = (await db.query(
      ContactObject.tableName,
      where: '${ContactObject.nameColumnName} = ?',
      whereArgs: [contact.name],
    )).isNotEmpty;

    if (!hasContact) {
      await db.insert(ContactObject.tableName, contact.toMap());
    }
  }

  Future<List<ContactObject>> list() async {
    final db = await database;

    final contactsTable = await db.query(ContactObject.tableName);

    return contactsTable
        .map((contactMap) => ContactObject.fromMap(contactMap))
        .toList();
  }

  Future<ContactObject?> readByName(String name) async {
    final db = await database;

    final contactsTable = await db.query(
      ContactObject.tableName,
      where: '${ContactObject.nameColumnName} = ?',
      whereArgs: [name],
    );

    if (contactsTable.isEmpty) return null;

    final contactMap = contactsTable.first;

    return ContactObject.fromMap(contactMap);
  }

  Future<void> update(ContactObject contact) async {
    final db = await database;

    await db.update(
      ContactObject.tableName,
      contact.toMap(),
      where: '${ContactObject.nameColumnName} = ?',
      whereArgs: [contact.name],
    );
  }

  Future<void> delete(String name) async {
    final db = await database;

    await db.delete(
      ContactObject.tableName,
      where: '${ContactObject.nameColumnName} = ?',
      whereArgs: [name],
    );

    await db.delete(
      PaymentObject.tableName,
      where: '${PaymentObject.contactNameColumnName} = ?',
      whereArgs: [name],
    );
  }
}
