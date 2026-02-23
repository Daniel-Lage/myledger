import 'package:flutter/material.dart';
import 'package:myledger/components/contact_component.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:myledger/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ContactObject> _contactList = <ContactObject>[];
  ContactCompareKey _compareKey = ContactCompareKey.balance;
  bool _listIsReversed = false;

  final DatabaseService _databaseService = DatabaseService.instance;

  _HomePageState() {
    loadState();
  }

  Future<void> loadState() async {
    final contactTable = await _databaseService.getContactsTable();

    setState(() {
      _contactList = contactTable;
    });
  }

  Future<void> _goToNewContact() async {
    NewContactResult result =
        await Navigator.of(context).pushNamed("/new_contact")
            as NewContactResult;

    if (result.contact == null) return; // null if contact creation is cancelled

    final newContact = result.contact!;

    _databaseService.addContact(newContact);

    setState(() {
      _contactList.add(newContact);
    });
  }

  Future<void> _goToContact(ContactObject contact) async {
    ContactResult result =
        await Navigator.of(context).pushNamed(
              '/contact',
              arguments: ContactArguments(contact: contact),
            )
            as ContactResult;

    switch (result.action) {
      case ContactPageAction.update:
        final updatedContact = result.contact;

        final index = _contactList.indexWhere(
          (contact) => contact.name == updatedContact.name,
        );

        setState(() {
          _contactList[index] = updatedContact;
        });
        break;
      case ContactPageAction.delete:
        final deletedContact = result.contact;

        final index = _contactList.indexWhere(
          (contact) => contact.name == deletedContact.name,
        );

        _databaseService.deleteContact(deletedContact.name);

        setState(() {
          _contactList.removeAt(index);
        });
        break;
      case ContactPageAction.none:
        break;
    }
  }

  Future<void> _goToPrefs() async {
    PreferencesResult result =
        await Navigator.of(context).pushNamed("/preferences")
            as PreferencesResult;

    if (result.actions.updatedIsUsingLocalContacts == true ||
        result.actions.dataErased == true) {
      loadState();
    }
  }

  List<ContactObject> _getSortedContacts() {
    switch (_compareKey) {
      case ContactCompareKey.balance:
        _contactList.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
        break;
      case ContactCompareKey.name:
        _contactList.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return _listIsReversed ? _contactList.reversed.toList() : _contactList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorScheme.of(context).primary,
        iconTheme: IconThemeData(
          color: ColorScheme.of(context).onPrimary,
          size: 35,
        ),
        title: Text(
          'Início',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ColorScheme.of(context).onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: _goToPrefs,
          icon: Icon(Icons.settings),
          padding: EdgeInsetsGeometry.all(5),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(color: ColorScheme.of(context).secondary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        if (_compareKey == ContactCompareKey.name) {
                          _listIsReversed = !_listIsReversed;
                        } else {
                          _compareKey = ContactCompareKey.name;
                          _listIsReversed = false;
                        }
                      }),
                      child: Text(
                        "Nome",
                        style: _compareKey == ContactCompareKey.name
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ColorScheme.of(context).onPrimary,
                              )
                            : TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: ColorScheme.of(context).onSecondary,
                              ),
                      ),
                    ),
                    Icon(
                      _listIsReversed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: _compareKey == ContactCompareKey.name
                          ? ColorScheme.of(context).onSecondary
                          : Colors.transparent,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => setState(() {
                        if (_compareKey == ContactCompareKey.balance) {
                          _listIsReversed = !_listIsReversed;
                        } else {
                          _compareKey = ContactCompareKey.balance;
                          _listIsReversed = false;
                        }
                      }),
                      child: Text(
                        "Saldo",
                        style: _compareKey == ContactCompareKey.balance
                            ? TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: ColorScheme.of(context).onPrimary,
                              )
                            : TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: ColorScheme.of(context).onSecondary,
                              ),
                      ),
                    ),
                    Icon(
                      _listIsReversed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: _compareKey == ContactCompareKey.balance
                          ? ColorScheme.of(context).onSecondary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ..._getSortedContacts().map(
            (contact) => ContactComponent(
              contact: contact,
              goTo: () => _goToContact(contact),
            ),
          ),
        ],
      ),
      floatingActionButton: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: ColorScheme.of(context).primary,
        ),
        onPressed: _goToNewContact,
        icon: Icon(Icons.add),
        iconSize: 40,
        color: ColorScheme.of(context).onPrimary,
        padding: EdgeInsetsGeometry.all(10),
      ),
    );
  }
}
