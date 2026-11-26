import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/repositories/contact_repository.dart';
import 'package:myledger/repositories/payment_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  final ContactRepository _contactRepository;
  final PaymentRepository _paymentRepository;

  PaymentViewModel(
    this.payment,
    this.contact, {
    required ContactRepository contactRepository,
    required PaymentRepository paymentRepository,
  }) : _contactRepository = contactRepository,
       _paymentRepository = paymentRepository;

  PaymentObject payment;
  ContactObject contact;
  PaymentViewAction action = PaymentViewAction.none;

  Future<void> updatePayment(PaymentObject updatedPayment) async {
    await _paymentRepository.update(updatedPayment);

    final oldValue = payment.type == PaymentType.sending
        ? payment.value
        : -payment.value;

    final newValue = updatedPayment.type == PaymentType.sending
        ? updatedPayment.value
        : -updatedPayment.value;

    contact.balance += newValue - oldValue;

    await _contactRepository.update(contact);

    payment = updatedPayment;
    action = PaymentViewAction.update;

    notifyListeners();
  }

  Future<void> deletePayment() async {
    await _paymentRepository.delete(payment);
    action = PaymentViewAction.delete;
    notifyListeners();
  }
}
