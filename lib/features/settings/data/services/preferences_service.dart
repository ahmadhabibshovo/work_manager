import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

abstract class PreferencesService {
  Future<UserPreferences> getUserPreferences();
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<void> resetToDefaults();
}

class PreferencesServiceImpl implements PreferencesService {
  static const String _preferencesKey = 'user_preferences';
  final SharedPreferences _prefs;

  PreferencesServiceImpl(this._prefs);

  @override
  Future<UserPreferences> getUserPreferences() async {
    final preferencesJson = _prefs.getString(_preferencesKey);
    if (preferencesJson == null) {
      return const UserPreferences();
    }

    try {
      final json = jsonDecode(preferencesJson);
      return UserPreferences.fromJson(json);
    } catch (e) {
      // If there's an error parsing, return defaults
      return const UserPreferences();
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final preferencesJson = jsonEncode(preferences.toJson());
    await _prefs.setString(_preferencesKey, preferencesJson);
  }

  @override
  Future<void> resetToDefaults() async {
    await _prefs.remove(_preferencesKey);
  }
}