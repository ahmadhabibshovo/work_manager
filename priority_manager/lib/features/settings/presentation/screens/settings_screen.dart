import 'package:flutter/material.dart';
import '../../data/models/user_preferences.dart';
import '../../data/services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _service = PreferencesServiceImpl();
  UserPreferences _preferences = UserPreferences();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await _service.getPreferences();
    setState(() {
      _preferences = prefs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _preferences.darkMode,
            onChanged: (value) {
              setState(() {
                _preferences.darkMode = value;
              });
              _service.updatePreferences(_preferences);
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _preferences.notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _preferences.notificationsEnabled = value;
              });
              _service.updatePreferences(_preferences);
            },
          ),
        ],
      ),
    );
  }
}