import 'package:hive/hive.dart';
import '../models/user_preferences.dart';

abstract class PreferencesService {
  Future<UserPreferences> getPreferences();
  Future<void> updatePreferences(UserPreferences preferences);
}

class PreferencesServiceImpl implements PreferencesService {
  final Box<UserPreferences> _settingsBox = Hive.box<UserPreferences>('settingsBox');

  @override
  Future<UserPreferences> getPreferences() async {
    return _settingsBox.get('preferences') ?? UserPreferences();
  }

  @override
  Future<void> updatePreferences(UserPreferences preferences) async {
    await _settingsBox.put('preferences', preferences);
  }
}