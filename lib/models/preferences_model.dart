class Preferences {
  bool isDarkTheme = false;
  bool isUsingLocalContacts = false;
}

class PreferencePageActions {
  bool updatedIsUsingLocalContacts = false;
  bool dataErased = false;
}

class PreferencesResults {
  final PreferencePageActions actions;

  PreferencesResults({required this.actions});
}
