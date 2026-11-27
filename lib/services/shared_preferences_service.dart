import 'package:myledger/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _isDarkThemeKey = 'isDarkTheme';
  static const String _isUsingLocalContactsKey = 'isUsingLocalContacts';

  Future<Result<bool>> getIsDarkTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkTheme = prefs.getBool(_isDarkThemeKey) ?? false;
      return Result.ok(isDarkTheme);
    } catch (e) {
      return Result.error(Exception('Failed to get isDarkTheme: $e'));
    }
  }

  Future<Result<void>> setIsDarkTheme(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDarkThemeKey, value);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to set isDarkTheme: $e'));
    }
  }

  Future<Result<bool>> getIsUsingLocalContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isUsingLocalContacts =
          prefs.getBool(_isUsingLocalContactsKey) ?? false;
      return Result.ok(isUsingLocalContacts);
    } catch (e) {
      return Result.error(Exception('Failed to get isUsingLocalContacts: $e'));
    }
  }

  Future<Result<void>> setIsUsingLocalContacts(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isUsingLocalContactsKey, value);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to set isUsingLocalContacts: $e'));
    }
  }
}
