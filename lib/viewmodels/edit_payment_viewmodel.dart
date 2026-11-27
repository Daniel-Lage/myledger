import 'package:flutter/foundation.dart';
import 'package:myledger/models/payment_model.dart';
import 'package:myledger/repositories/payment_repository.dart';
import 'package:myledger/routing/routes.dart';

class EditPaymentViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  EditPaymentViewModel(
    this.payment, {
    required PaymentRepository paymentRepository,
  }) : sendingValue = payment.type == PaymentType.sending ? payment.value : 0,
       receivingValue = payment.type == PaymentType.receiving
           ? payment.value
           : 0,
       description = payment.description ?? '',
       _paymentRepository = paymentRepository;

  final PaymentObject payment;
  int sendingValue;
  int receivingValue;
  String description;
  EditPaymentViewAction action = EditPaymentViewAction.none;

  bool get canSubmit => sendingValue != 0 || receivingValue != 0;

  void setSendingValue(int value) {
    if (sendingValue == value) return;
    sendingValue = value;
    action = EditPaymentViewAction.value;
    notifyListeners();
  }

  void setReceivingValue(int value) {
    if (receivingValue == value) return;
    receivingValue = value;
    action = EditPaymentViewAction.value;
    notifyListeners();
  }

  void setDescription(String value) {
    if (description == value) return;
    description = value;
    if (action == EditPaymentViewAction.none) {
      action = EditPaymentViewAction.description;
    }
  }

  PaymentObject createEditedPayment() {
    final isSending = sendingValue != 0;
    return PaymentObject(
      id: payment.id,
      contactName: payment.contactName,
      value: isSending ? sendingValue : receivingValue,
      type: isSending ? PaymentType.sending : PaymentType.receiving,
      createdAt: payment.createdAt,
      description: description,
    );
  }

  Future<void> save(PaymentObject payment) async {
    await _paymentRepository.update(payment);
  }
}
