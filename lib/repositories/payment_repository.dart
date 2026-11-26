import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PaymentRepository {
  final DatabaseService _database;

  PaymentRepository({required DatabaseService database}) : _database = database;

  Future<Database> get database async {
    return await _database.database;
  }

  Future<List<PaymentObject>> listByContactName(String contactName) async {
    final db = await database;

    final paymentsTable = await db.query(
      PaymentObject.tableName,
      where: '${PaymentObject.contactNameColumnName} = ?',
      whereArgs: [contactName],
    );

    return paymentsTable
        .map((paymentMap) => PaymentObject.fromMap(paymentMap))
        .toList();
  }

  Future<int> create(PaymentObject payment) async {
    // Returns payment id
    final db = await database;

    final id = await db.insert(PaymentObject.tableName, payment.toMap());

    return id;
  }

  Future<PaymentObject?> read(int id) async {
    final db = await database;

    final paymentsTable = await db.query(
      PaymentObject.tableName,
      where: '${PaymentObject.idColumnName} = ?',
      whereArgs: [id],
    );

    if (paymentsTable.isEmpty) return null;

    final paymentMap = paymentsTable.first;

    return PaymentObject.fromMap(paymentMap);
  }

  Future<int> update(PaymentObject payment) async {
    final db = await database;

    final result = await db.update(
      PaymentObject.tableName,
      payment.toMap(),
      where: '${PaymentObject.idColumnName} = ?',
      whereArgs: [payment.id],
    );

    return result;
  }

  Future<int> delete(PaymentObject payment) async {
    final db = await database;

    final result = await db.delete(
      PaymentObject.tableName,
      where: '${PaymentObject.idColumnName} = ?',
      whereArgs: [payment.id],
    );

    return result;
  }
}
