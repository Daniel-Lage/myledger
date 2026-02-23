import 'package:intl/intl.dart';
import 'package:myledger/models/contact_model.dart';

class PaymentObject {
  static final DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  static final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
    locale: "pt_BR",
    decimalDigits: 2,
  );

  int? id;
  final String contactName;
  final int value;
  final PaymentType type;
  final DateTime? createdAt;
  final String? description;
  // id and createdAt not included if the payment is not yet stored in the database

  PaymentObject({
    this.id,
    required this.contactName,
    required this.value,
    required this.type,
    this.createdAt,
    this.description,
  });
}

enum PaymentType { receiving, sending }

class NewPaymentArguments {
  final ContactObject contact;

  NewPaymentArguments({required this.contact});
}

class NewPaymentResult {
  final PaymentObject? payment;

  NewPaymentResult({required this.payment});
}

class PaymentArguments {
  final PaymentObject payment;
  final ContactObject contact;

  PaymentArguments({required this.payment, required this.contact});
}

class PaymentResult {
  final PaymentPageAction? action;

  PaymentResult({required this.action});
}

enum PaymentPageAction { delete, none }

String formatSimpleDate(DateTime date) {
  return "${date.day}/${date.month}";
}

String formatDate(DateTime date) {
  final months = [
    "JAN",
    "FEV",
    "MAR",
    "ABR",
    "MAI",
    "JUN",
    "JUL",
    "AGO",
    "SET",
    "OUT",
    "NOV",
    "DEZ",
  ];
  return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}
