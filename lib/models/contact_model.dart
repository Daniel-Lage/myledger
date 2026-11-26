class ContactObject {
  static String tableName = "contacts";
  static String nameColumnName = "name";
  static String balanceColumnName = "balance";

  final String name;
  int balance;
  final DateTime? createdAt;

  ContactObject({required this.name, this.balance = 0, this.createdAt});

  Map<String, Object?> toMap() => {
    nameColumnName: name,
    balanceColumnName: balance,
  };

  factory ContactObject.fromMap(Map<String, Object?> map) {
    return ContactObject(
      name: map[nameColumnName] as String,
      balance: map[balanceColumnName] as int,
    );
  }
}

class ContactCompareFunction {
  static name(ContactObject contact) => contact.name;
  static balance(ContactObject contact) => contact.balance;
}

enum ContactCompareKey { name, balance }

enum ContactViewAction { none, update, delete }

class ContactArguments {
  final ContactObject contact;

  ContactArguments({required this.contact});
}

class ContactResult {
  final ContactObject contact;
  final ContactViewAction action;

  ContactResult({required this.contact, required this.action});
}

class NewContactResult {
  final ContactObject? contact;

  NewContactResult({required this.contact});
}
