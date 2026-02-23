class Preferences {
  bool isDarkTheme = false;
  bool isUsingLocalContacts = false;
}

class PreferencePageActions {
  bool updatedIsUsingLocalContacts = false;
  bool dataErased = false;
}

class PreferencesResult {
  final PreferencePageActions actions;

  PreferencesResult({required this.actions});
}
