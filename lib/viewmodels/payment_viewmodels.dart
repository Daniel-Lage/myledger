import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/services/database_service.dart';

class NewPaymentViewModel extends ChangeNotifier {
  int sendingValue = 0;
  int receivingValue = 0;
  String description = '';

  void setSendingValue(int value) {
    sendingValue = value;
    notifyListeners();
  }

  void setReceivingValue(int value) {
    receivingValue = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
  }

  bool get canSubmit => sendingValue != 0 || receivingValue != 0;

  PaymentObject? createPayment(ContactObject contact) {
    if (!canSubmit) return null;

    final isSending = sendingValue != 0;
    return PaymentObject(
      contactName: contact.name,
      value: isSending ? sendingValue : receivingValue,
      type: isSending ? PaymentType.sending : PaymentType.receiving,
      createdAt: DateTime.now(),
      description: description,
    );
  }
}

class EditPaymentViewModel extends ChangeNotifier {
  final DatabaseService _database;

  EditPaymentViewModel(PaymentObject payment, {DatabaseService? database})
    : _payment = payment,
      sendingValue = payment.type == PaymentType.sending ? payment.value : 0,
      receivingValue = payment.type == PaymentType.receiving
          ? payment.value
          : 0,
      description = payment.description ?? '',
      _database = database ?? DatabaseService.instance;

  final PaymentObject _payment;
  int sendingValue;
  int receivingValue;
  String description;
  EditPaymentPageAction action = EditPaymentPageAction.none;

  bool get canSubmit => sendingValue != 0 || receivingValue != 0;

  void setSendingValue(int value) {
    if (sendingValue == value) return;
    sendingValue = value;
    action = EditPaymentPageAction.value;
    notifyListeners();
  }

  void setReceivingValue(int value) {
    if (receivingValue == value) return;
    receivingValue = value;
    action = EditPaymentPageAction.value;
    notifyListeners();
  }

  void setDescription(String value) {
    if (description == value) return;
    description = value;
    if (action == EditPaymentPageAction.none) {
      action = EditPaymentPageAction.description;
    }
  }

  PaymentObject createEditedPayment() {
    final isSending = sendingValue != 0;
    return PaymentObject(
      id: _payment.id,
      contactName: _payment.contactName,
      value: isSending ? sendingValue : receivingValue,
      type: isSending ? PaymentType.sending : PaymentType.receiving,
      createdAt: _payment.createdAt,
      description: description,
    );
  }

  Future<void> save(PaymentObject payment) async {
    await _database.updatePayment(payment);
  }
}

class PaymentViewModel extends ChangeNotifier {
  final DatabaseService _database;

  PaymentViewModel(this.payment, this.contact, {
    DatabaseService? database,
  }) : _database = database ?? DatabaseService.instance;

  PaymentObject payment;
  ContactObject contact;
  PaymentPageAction action = PaymentPageAction.none;

  Future<void> updatePayment(PaymentObject updatedPayment) async {
    await _database.updatePayment(updatedPayment);

    final oldValue = payment.type == PaymentType.receiving
        ? payment.value
        : -payment.value;
    final newValue = updatedPayment.type == PaymentType.receiving
        ? updatedPayment.value
        : -updatedPayment.value;

    contact.balance += newValue - oldValue;
    await _database.updateContact(contact);

    payment = updatedPayment;
    action = PaymentPageAction.update;
    notifyListeners();
  }

  Future<void> deletePayment() async {
    await _database.deletePayment(payment);
    action = PaymentPageAction.delete;
    notifyListeners();
  }
}
