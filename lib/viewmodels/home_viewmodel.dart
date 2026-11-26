import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/services/database_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _database;

  HomeViewModel({DatabaseService? database})
    : _database = database ?? DatabaseService.instance;

  List<ContactObject> _contacts = [];
  ContactCompareKey _compareKey = ContactCompareKey.balance;
  bool _isReversed = false;
  bool _isLoading = false;
  String? errorMessage;

  List<ContactObject> get contacts => List.unmodifiable(_contacts);
  ContactCompareKey get compareKey => _compareKey;
  bool get isReversed => _isReversed;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _contacts = await _database.getContactsTable();
    } catch (error) {
      errorMessage = 'Não foi possível carregar os contatos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(ContactObject contact) async {
    await _database.addContact(contact);
    _contacts = [..._contacts, contact];
    notifyListeners();
  }

  Future<void> updateContact(ContactObject contact) async {
    await _database.updateContact(contact);
    final index = _contacts.indexWhere((item) => item.name == contact.name);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  Future<void> deleteContact(ContactObject contact) async {
    await _database.deleteContact(contact.name);
    _contacts.removeWhere((item) => item.name == contact.name);
    notifyListeners();
  }

  Future<void> handleContactResult(ContactResult result) async {
    switch (result.action) {
      case ContactPageAction.update:
        await updateContact(result.contact);
      case ContactPageAction.delete:
        await deleteContact(result.contact);
      case ContactPageAction.none:
        break;
    }
  }

  void changeSort(ContactCompareKey key) {
    if (_compareKey == key) {
      _isReversed = !_isReversed;
    } else {
      _compareKey = key;
      _isReversed = false;
    }
    notifyListeners();
  }

  List<ContactObject> getSortedContacts() {
    final sorted = [..._contacts];

    switch (_compareKey) {
      case ContactCompareKey.balance:
        sorted.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
      case ContactCompareKey.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }

    return _isReversed ? sorted.reversed.toList() : sorted;
  }
}
