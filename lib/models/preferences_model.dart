class Preferences {
  bool isDarkTheme = false;
  bool isUsingLocalContacts = false;
}

class PreferenceViewActions {
  bool updatedIsUsingLocalContacts = false;
  bool dataErased = false;
}

class PreferencesResult {
  final PreferenceViewActions actions;

  PreferencesResult({required this.actions});
}
