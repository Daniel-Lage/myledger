import 'package:intl/intl.dart';

class PaymentObject {
  static String tableName = "payments";
  static String contactNameColumnName = "contactName";
  static String idColumnName = "id";
  static String valueColumnName = "value";
  static String typeColumnName = "type";
  static String createdAtColumnName = "createdAt";
  static String descriptionColumnName = "description";

  static final DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  static final NumberFormat _currencyFormat = NumberFormat.simpleCurrency(
    locale: "pt_BR",
    decimalDigits: 2,
  );

  static String formatCurrency(int n) {
    return _currencyFormat.format(n / 100);
  }

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

  Map<String, Object?> toMap() => {
    contactNameColumnName: contactName,
    valueColumnName: value,
    typeColumnName: type == PaymentType.receiving ? 1 : 0,
    createdAtColumnName: DateTime.now().millisecondsSinceEpoch,
    descriptionColumnName: description ?? "",
  };

  factory PaymentObject.fromMap(Map<String, Object?> map) {
    return PaymentObject(
      id: map[idColumnName] as int,
      contactName: map[contactNameColumnName] as String,
      value: map[valueColumnName] as int,
      type: map[typeColumnName] == 1
          ? PaymentType.receiving
          : PaymentType.sending,
      description: map[descriptionColumnName] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[createdAtColumnName] as int,
      ),
    );
  }
}

enum PaymentType { receiving, sending }

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
