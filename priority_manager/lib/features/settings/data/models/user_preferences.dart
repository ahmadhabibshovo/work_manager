import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 2)
class UserPreferences extends HiveObject {
  @HiveField(0)
  bool darkMode;

  @HiveField(1)
  bool notificationsEnabled;

  UserPreferences({
    this.darkMode = false,
    this.notificationsEnabled = true,
  });
}