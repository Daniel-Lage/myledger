import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_project/models/contact_model.dart';
import 'package:flutter_project/notifiers/preferences_notifier.dart';
import 'package:flutter_project/services/database_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double mul = 3;
  final Map<String, bool> updatedSettings = {
    "isDarkTheme": false,
    "isUsingLocalContacts": false,
  };

  Future<void> _enableLocalContacts() async {
    if (await FlutterContacts.requestPermission()) {
      for (var localContact in (await FlutterContacts.getContacts())) {
        await DatabaseService.instance.addContact(
          ContactObject(name: localContact.displayName),
        );
      }
    }
  }

  Future<void> _disableLocalContacts() async {
    if (await FlutterContacts.requestPermission()) {
      for (var localContact in (await FlutterContacts.getContacts())) {
        await DatabaseService.instance.removeContact(localContact.displayName);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      title: Text(
        'Preferências',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      leading: BackButton(
        onPressed: () {
          Navigator.pop(context, {"settings": updatedSettings});
        },
      ),
    ),
    body: ListView(
      children: <Widget>[
        Preference(
          title: "Usar modo noturno",
          enabled: Provider.of<PreferenceNotifier>(context).isDarkTheme,
          onDisable: () {
            Provider.of<PreferenceNotifier>(
              context,
              listen: false,
            ).isDarkTheme = false;
            updatedSettings["isDarkTheme"] =
                updatedSettings["isDarkTheme"] != true;
          },
          onEnable: () {
            Provider.of<PreferenceNotifier>(
              context,
              listen: false,
            ).isDarkTheme = true;
            updatedSettings["isDarkTheme"] =
                updatedSettings["isDarkTheme"] != true;
          },
        ),
        Preference(
          unavailable: Platform.isWindows,
          title: "Usar contatos locais",
          enabled: Provider.of<PreferenceNotifier>(
            context,
          ).isUsingLocalContacts,
          onDisable: () {
            Provider.of<PreferenceNotifier>(
              context,
              listen: false,
            ).isUsingLocalContacts = false;
            _disableLocalContacts();
            updatedSettings["isUsingLocalContacts"] =
                updatedSettings["isUsingLocalContacts"] != true;
          },
          onEnable: () {
            Provider.of<PreferenceNotifier>(
              context,
              listen: false,
            ).isUsingLocalContacts = true;
            _enableLocalContacts();
            updatedSettings["isUsingLocalContacts"] =
                updatedSettings["isUsingLocalContacts"] != true;
          },
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
