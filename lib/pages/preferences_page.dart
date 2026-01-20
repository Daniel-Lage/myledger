import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:myledger/notifiers/preferences_notifier.dart';
import 'package:myledger/services/database_service.dart';
import 'package:provider/provider.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  PreferenceNotifier? _preferences;
  final PreferencePageActions _actions = PreferencePageActions();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _preferences = Provider.of<PreferenceNotifier>(context, listen: false);
      });
    });
  }

  Future<void> _enableLocalContacts() async {
    _actions.updatedIsUsingLocalContacts = true;
    if (await FlutterContacts.requestPermission()) {
      for (var localContact in (await FlutterContacts.getContacts())) {
        await DatabaseService.instance.addContact(
          ContactObject(name: localContact.displayName),
        );
      }
    }
  }

  Future<void> _disableLocalContacts() async {
    _actions.updatedIsUsingLocalContacts = true;
    if (await FlutterContacts.requestPermission()) {
      for (var localContact in (await FlutterContacts.getContacts())) {
        await DatabaseService.instance.removeContact(localContact.displayName);
      }
    }
  }

  Future<void> _eraseData() async {
    _actions.dataErased = true;
    await DatabaseService.instance.resetDatabase();
  }

  Future<void> _eraseDataDialogBuilder(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Apagar dados?"),
          content: Text("Dados excluidos não poderão ser reconstituidos."),
          actions: [
            IconButton(
              onPressed: () {
                _eraseData();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.remove),
              style: IconButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      );

  Widget loading() => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      title: Text(
        'Preferências',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    ),
    body: ListView(
      children: <Widget>[
        Preference(
          title: "Usar modo noturno",
          enabled: false,
          onDisable: null,
          onEnable: null,
        ),
        Preference(
          unavailable: Platform.isWindows,
          title: "Usar contatos locais",
          enabled: false,
          onDisable: null,
          onEnable: null,
        ),
        Action(icon: Icons.star, title: "Apagar dados", onClick: null),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => _preferences == null
      ? loading()
      : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            title: Text(
              'Preferências',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            leading: BackButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(PreferencesResults(actions: _actions));
              },
            ),
          ),
          body: ListView(
            children: <Widget>[
              Preference(
                title: "Usar modo noturno",
                enabled: _preferences!.isDarkTheme,
                onDisable: () {
                  _preferences!.isDarkTheme = false;
                },
                onEnable: () {
                  _preferences!.isDarkTheme = true;
                },
              ),
              Preference(
                unavailable: Platform.isWindows,
                title: "Usar contatos locais",
                enabled: _preferences!.isUsingLocalContacts,
                onDisable: () {
                  _preferences!.isUsingLocalContacts = false;
                  _disableLocalContacts();
                },
                onEnable: () {
                  _preferences!.isUsingLocalContacts = true;
                  _enableLocalContacts();
                },
              ),
              Action(
                icon: Icons.delete,
                title: "Apagar dados",
                onClick: () => _eraseDataDialogBuilder(context),
              ),
            ],
          ),
        );
}

class Preference extends StatelessWidget {
  final String title;
  final bool enabled;
  final bool unavailable;
  final void Function()? onEnable;
  final void Function()? onDisable;

  const Preference({
    super.key,
    required this.title,
    this.unavailable = false,
    required this.enabled,
    required this.onDisable,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) => unavailable
      ? Container()
      : Padding(
          padding: EdgeInsetsGeometry.directional(start: 65, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: enabled ? onDisable : onEnable,
                icon: enabled
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
              ),
              Text(title),
            ],
          ),
        );
}

class Action extends StatelessWidget {
  final String title;
  final bool unavailable;
  final IconData icon;
  final void Function()? onClick;

  const Action({
    super.key,
    required this.title,
    this.unavailable = false,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) => unavailable
      ? Container()
      : Padding(
          padding: EdgeInsetsGeometry.directional(start: 65, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: onClick, icon: Icon(icon)),
              Text(title),
            ],
          ),
        );
}
