class ContactObject {
  final String name;
  int debt;
  ContactObject({required this.name, this.debt = 0});

  Map<String, Object> toMap() => {'name': name, "debt": debt};
}

class ContactCompareFunction {
  static name(ContactObject contact) => contact.name;
  static debt(ContactObject contact) => contact.debt;
}

enum ContactCompareKey { name, debt }

enum ContactPageAction { none, update, delete }

class ContactArguments {
  final ContactObject contact;

  ContactArguments({required this.contact});
}

class ContactResults {
  final ContactObject contact;
  final ContactPageAction action;

  ContactResults({required this.contact, required this.action});
}

class NewContactResults {
  final ContactObject contact;

  NewContactResults({required this.contact});
}
