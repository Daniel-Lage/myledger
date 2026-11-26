import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/repositories/contact_repository.dart';
import 'package:myledger/repositories/payment_repository.dart';

class ContactViewModel extends ChangeNotifier {
  final ContactRepository _contactRepository;
  final PaymentRepository _paymentRepository;

  ContactViewModel(
    this._initialContact, {
    required ContactRepository contactRepository,
    required PaymentRepository paymentRepository,
  }) : contact = _initialContact,
       action = ContactViewAction.none,
       _contactRepository = contactRepository,
       _paymentRepository = paymentRepository {
    _load();
  }

  final ContactObject _initialContact;
  ContactObject contact;
  List<PaymentObject> payments = [];
  ContactViewAction action;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _load() async {
    contact = _initialContact;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      payments = await _paymentRepository.listByContactName(contact.name);
    } catch (error) {
      errorMessage = 'Não foi possível carregar os pagamentos.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPayment(PaymentObject payment) async {
    payment.id = await _paymentRepository.create(payment);
    payments = [...payments, payment];
    action = ContactViewAction.update;
    await _calculateBalance();
  }

  Future<void> deletePayment(PaymentObject payment) async {
    await _paymentRepository.delete(payment);
    payments.removeWhere((item) => item.id == payment.id);
    action = ContactViewAction.update;
    await _calculateBalance();
  }

  Future<void> updatePayment(PaymentObject payment) async {
    await _paymentRepository.update(payment);
    payments = payments
        .map((item) => item.id == payment.id ? payment : item)
        .toList();
    action = ContactViewAction.update;
    await _calculateBalance();
  }

  Future<void> _calculateBalance() async {
    var balance = 0;

    for (final payment in payments) {
      balance += payment.type == PaymentType.sending
          ? payment.value
          : -payment.value;
    }

    contact.balance = balance;
    action = ContactViewAction.update;
    await _contactRepository.update(contact);
    notifyListeners();
  }

  Future<void> deleteContact() async {
    await _contactRepository.delete(contact.name);
    action = ContactViewAction.delete;
    notifyListeners();
  }
}
