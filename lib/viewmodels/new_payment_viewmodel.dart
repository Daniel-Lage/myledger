import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';

class NewPaymentViewModel extends ChangeNotifier {
  NewPaymentViewModel(ContactObject contact)
    : payment = PaymentObject(
        contactName: contact.name,
        value: 0,
        type: PaymentType.sending,
        createdAt: DateTime.now(),
        description: '',
      );

  final PaymentObject payment;
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

  PaymentObject? createPayment() {
    if (!canSubmit) return null;

    final isSending = sendingValue != 0;
    return PaymentObject(
      contactName: payment.contactName,
      value: isSending ? sendingValue : receivingValue,
      type: isSending ? PaymentType.sending : PaymentType.receiving,
      createdAt: DateTime.now(),
      description: description,
    );
  }
}
