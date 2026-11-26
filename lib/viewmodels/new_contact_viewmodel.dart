import 'package:flutter/foundation.dart';
import 'package:myledger/models/contact_model.dart';

class NewContactViewModel extends ChangeNotifier {
  String _name = '';

  String get name => _name;
  bool get canSubmit => _name.trim().isNotEmpty;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  ContactObject? createContact() {
    if (!canSubmit) return null;
    return ContactObject(name: _name.trim());
  }
}
