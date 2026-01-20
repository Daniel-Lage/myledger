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
  ContactCompareKey _compareKey = ContactCompareKey.debt;
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
    NewContactResults args =
        await Navigator.of(context).pushNamed("/new_contact")
            as NewContactResults;
    setState(() {
      _contactList.add(args.contact);
    });
  }

  Future<void> _goToContact(ContactObject contact) async {
    ContactResults args =
        await Navigator.of(context).pushNamed(
              '/contact',
              arguments: ContactArguments(contact: contact),
            )
            as ContactResults;

    switch (args.action) {
      case ContactPageAction.update:
        final updatedContact = args.contact;

        final index = _contactList.indexWhere(
          (contact) => contact.name == updatedContact.name,
        );

        setState(() {
          _contactList[index] = updatedContact;
        });
        break;
      case ContactPageAction.delete:
        final updatedContact = args.contact;

        final index = _contactList.indexWhere(
          (contact) => contact.name == updatedContact.name,
        );

        setState(() {
          _contactList.removeAt(index);
        });
        break;
      case ContactPageAction.none:
        break;
    }
  }

  Future<void> _goToPrefs() async {
    PreferencesResults args =
        await Navigator.of(context).pushNamed("/preferences")
            as PreferencesResults;

    if (args.actions.updatedIsUsingLocalContacts == true ||
        args.actions.dataErased == true) {
      loadState();
    }
  }

  List<ContactObject> _getSortedContacts() {
    switch (_compareKey) {
      case ContactCompareKey.debt:
        _contactList.sort((a, b) => b.debt.abs().compareTo(a.debt.abs()));
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
          size: 35,
        ),
        title: Text(
          'Início',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),

            padding: EdgeInsetsGeometry.directional(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                    ),
                            ),
                          ),
                          Icon(
                            _listIsReversed
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: _compareKey == ContactCompareKey.name
                                ? Theme.of(context).colorScheme.onSecondary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() {
                              if (_compareKey == ContactCompareKey.debt) {
                                _listIsReversed = !_listIsReversed;
                              } else {
                                _compareKey = ContactCompareKey.debt;
                                _listIsReversed = false;
                              }
                            }),
                            child: Text(
                              "Dívida",
                              style: _compareKey == ContactCompareKey.debt
                                  ? TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                    ),
                            ),
                          ),

                          Icon(
                            _listIsReversed
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: _compareKey == ContactCompareKey.debt
                                ? Theme.of(context).colorScheme.onSecondary
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ],
                  ),
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
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: _goToNewContact,
        icon: Icon(Icons.add),
        iconSize: 40,
        color: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsetsGeometry.all(10),
      ),
    );
  }
}
