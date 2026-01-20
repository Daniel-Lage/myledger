import 'package:flutter/material.dart';
import 'package:myledger/models/preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceNotifier with ChangeNotifier {
  static final PreferenceNotifier instance = PreferenceNotifier();

  final Preferences _preferences = Preferences();

  PreferenceNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    await SharedPreferences.getInstance().then((prefs) {
      _preferences.isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _preferences.isUsingLocalContacts =
          prefs.getBool('isUsingLocalContacts') ?? false;
    });
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isDarkTheme', _preferences.isDarkTheme);
      prefs.setBool('isUsingLocalContacts', _preferences.isUsingLocalContacts);
    });
  }

  get isDarkTheme => _preferences.isDarkTheme;

  set isDarkTheme(bool newValue) {
    if (newValue == _preferences.isDarkTheme) return;
    _preferences.isDarkTheme = newValue;
    _savePrefs();
    notifyListeners();
  }

  get isUsingLocalContacts => _preferences.isUsingLocalContacts;

  set isUsingLocalContacts(bool newValue) {
    if (newValue == _preferences.isUsingLocalContacts) return;
    _preferences.isUsingLocalContacts = newValue;
    _savePrefs();
    notifyListeners();
  }
}
