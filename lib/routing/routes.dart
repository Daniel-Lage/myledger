import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/payment_model.dart';

final homePath = '/';

final preferencesPath = '/preferences';

final newContactPath = '/new_contact';

class NewContactResult {
  final ContactObject? contact;

  NewContactResult({required this.contact});
}

final contactPath = '/contact';

class ContactExtra {
  final ContactObject contact;

  ContactExtra({required this.contact});
}

enum ContactViewAction { none, update, delete }

class ContactResult {
  final ContactObject contact;
  final ContactViewAction action;

  ContactResult({required this.contact, required this.action});
}

final newPaymentPath = '/new_payment';

class NewPaymentExtra {
  final ContactObject contact;

  NewPaymentExtra({required this.contact});
}

class NewPaymentResult {
  final PaymentObject? payment;

  NewPaymentResult({required this.payment});
}

final editPaymentPath = '/edit_payment';

class EditPaymentExtra {
  final PaymentObject payment;

  EditPaymentExtra({required this.payment});
}

class EditPaymentResult {
  final PaymentObject? payment;
  final EditPaymentViewAction? action;

  EditPaymentResult({required this.payment, required this.action});
}

enum EditPaymentViewAction { description, value, none }

final paymentPath = '/payment';

class PaymentExtra {
  final PaymentObject payment;
  final ContactObject contact;

  PaymentExtra({required this.payment, required this.contact});
}

class PaymentResult {
  final PaymentObject payment;
  final PaymentViewAction action;

  PaymentResult({required this.payment, required this.action});
}

enum PaymentViewAction { delete, update, none }
