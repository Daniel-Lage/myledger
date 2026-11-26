import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';

class ContactViewModel extends ChangeNotifier {
  final DatabaseService _database;

  ContactViewModel(this._initialContact, {DatabaseService? database})
    : _database = database ?? DatabaseService.instance;

  final ContactObject _initialContact;
  ContactObject? contact;
  List<PaymentObject> payments = [];
  ContactPageAction action = ContactPageAction.none;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    contact = _initialContact;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      payments = await _database.getContactsPayments(contact!.name);
    } catch (error) {
      errorMessage = 'Não foi possível carregar os pagamentos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPayment(PaymentObject payment) async {
    payment.id = await _database.addPayment(payment);
    payments = [...payments, payment];
    action = ContactPageAction.update;
    await _calculateBalance();
  }

  Future<void> deletePayment(PaymentObject payment) async {
    await _database.deletePayment(payment);
    payments.removeWhere((item) => item.id == payment.id);
    action = ContactPageAction.update;
    await _calculateBalance();
  }

  Future<void> updatePayment(PaymentObject payment) async {
    await _database.updatePayment(payment);
    payments = payments
        .map((item) => item.id == payment.id ? payment : item)
        .toList();
    action = ContactPageAction.update;
    await _calculateBalance();
  }

  Future<void> _calculateBalance() async {
    var balance = 0;

    for (final payment in payments) {
      balance += payment.type == PaymentType.receiving
          ? payment.value
          : -payment.value;
    }

    contact!.balance = balance;
    await _database.updateContact(contact!);
    notifyListeners();
  }

  Future<void> deleteContact() async {
    await _database.deleteContact(contact!.name);
    action = ContactPageAction.delete;
    notifyListeners();
  }
}
