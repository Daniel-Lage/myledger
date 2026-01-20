import 'package:myledger/models/contact_model.dart';

class PaymentObject {
  final String contactName;
  final int value;
  final PaymentType type;

  PaymentObject({
    required this.contactName,
    required this.value,
    required this.type,
  });
}

enum PaymentType { plus, minus }

class NewPaymentArguments {
  final ContactObject contact;

  NewPaymentArguments({required this.contact});
}

class NewPaymentResults {
  final PaymentObject? payment;

  NewPaymentResults({required this.payment});
}
