class ContactObject {
  final String name;
  int balance;
  final DateTime? createdAt;

  ContactObject({required this.name, this.balance = 0, this.createdAt});

  Map<String, Object> toMap() => {'name': name, "balance": balance};
}

class ContactCompareFunction {
  static name(ContactObject contact) => contact.name;
  static balance(ContactObject contact) => contact.balance;
}

enum ContactCompareKey { name, balance }

enum ContactPageAction { none, update, delete }

class ContactArguments {
  final ContactObject contact;

  ContactArguments({required this.contact});
}

class ContactResult {
  final ContactObject contact;
  final ContactPageAction action;

  ContactResult({required this.contact, required this.action});
}

class NewContactResult {
  final ContactObject? contact;

  NewContactResult({required this.contact});
}
