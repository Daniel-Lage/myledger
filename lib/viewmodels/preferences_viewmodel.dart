import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:myledger/models/contact_model.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:myledger/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesViewModel extends ChangeNotifier {
  PreferencesViewModel({DatabaseService? database})
    : _database = database ?? DatabaseService.instance {
    _load();
  }

  final DatabaseService _database;
  bool _isDarkTheme = false;
  bool _isUsingLocalContacts = false;
  final PreferencePageActions _actions = PreferencePageActions();

  bool get isDarkTheme => _isDarkTheme;
  bool get isUsingLocalContacts => _isUsingLocalContacts;
  PreferencePageActions get actions => _actions;

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _isDarkTheme = preferences.getBool('isDarkTheme') ?? false;
    _isUsingLocalContacts =
        preferences.getBool('isUsingLocalContacts') ?? false;
    notifyListeners();
  }

  Future<void> setDarkTheme(bool value) async {
    if (_isDarkTheme == value) return;
    _isDarkTheme = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isDarkTheme', value);
    notifyListeners();
  }

  Future<void> setUsingLocalContacts(bool value) async {
    if (_isUsingLocalContacts == value) return;
    _isUsingLocalContacts = value;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isUsingLocalContacts', value);

    _actions.updatedIsUsingLocalContacts = true;

    if (!Platform.isWindows && await FlutterContacts.requestPermission()) {
      if (value) {
        for (final contact in await FlutterContacts.getContacts()) {
          await _database.addContact(
            ContactObject(name: contact.displayName),
          );
        }
      } else {
        for (final contact in await FlutterContacts.getContacts()) {
          await _database.deleteContact(contact.displayName);
        }
      }
    }

    notifyListeners();
  }

  Future<void> eraseData() async {
    await _database.resetDatabase();
    _actions.dataErased = true;
    notifyListeners();
  }
}
