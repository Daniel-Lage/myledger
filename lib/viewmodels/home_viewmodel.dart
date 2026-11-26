import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/repositories/contact_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ContactRepository _contactRepository;

  HomeViewModel({required ContactRepository contactRepository})
    : _contactRepository = contactRepository {
    load();
  }

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
      _contacts = await _contactRepository.list();
    } catch (error) {
      errorMessage = 'Não foi possível carregar os contatos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContact(ContactObject contact) async {
    await _contactRepository.create(contact);
    _contacts = [..._contacts, contact];
    notifyListeners();
  }

  Future<void> updateContact(ContactObject contact) async {
    await _contactRepository.update(contact);
    final index = _contacts.indexWhere((item) => item.name == contact.name);
    if (index != -1) {
      _contacts[index] = contact;
      notifyListeners();
    }
  }

  Future<void> deleteContact(ContactObject contact) async {
    await _contactRepository.delete(contact.name);
    _contacts.removeWhere((item) => item.name == contact.name);
    notifyListeners();
  }

  Future<void> handleContactResult(ContactResult result) async {
    switch (result.action) {
      case ContactViewAction.update:
        await updateContact(result.contact);
      case ContactViewAction.delete:
        await deleteContact(result.contact);
      case ContactViewAction.none:
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
