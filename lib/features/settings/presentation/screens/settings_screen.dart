import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/user_preferences.dart';
import '../../../../core/services/service_locator.dart';
import '../../../categories/data/models/category.dart';
import '../widgets/settings_tile.dart';
import '../../../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserPreferences _preferences = const UserPreferences();
  bool _isLoading = true;
  List<Category> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final repository = await ServiceLocator.getCategoryRepository();
      final categories = await repository.getAllCategories();
      if (mounted) {
        setState(() {
          _availableCategories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final service = await ServiceLocator.getPreferencesService();
      final preferences = await service.getUserPreferences();
      if (mounted) {
        setState(() {
          _preferences = preferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: Text(
              'Reset',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: 'APPEARANCE',
            children: [
              SettingsTile(
                title: 'Theme',
                subtitle: _preferences.themeMode.displayName,
                leading: Icon(
                  _preferences.themeMode == AppThemeMode.dark
                      ? Icons.dark_mode
                      : _preferences.themeMode == AppThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  size: 20.sp,
                ),
                onTap: _showThemeDialog,
              ),
              SettingsTile(
                title: 'Language',
                subtitle: _preferences.language.displayName,
                leading: Icon(
                  Icons.language,
                  size: 20.sp,
                ),
                onTap: _showLanguageDialog,
              ),
            ],
          ),

          SettingsSection(
            title: 'NOTIFICATIONS',
            children: [
              SettingsSwitchTile(
                title: 'Enable Notifications',
                subtitle: 'Receive reminders for tasks',
                leading: Icon(
                  Icons.notifications,
                  size: 20.sp,
                ),
                value: _preferences.enableNotifications,
                onChanged: (value) => _updatePreferences(
                  _preferences.copyWith(enableNotifications: value),
                ),
              ),
              if (_preferences.enableNotifications) ...[
                SettingsSwitchTile(
                  title: 'Sound',
                  subtitle: 'Play sound for notifications',
                  leading: Icon(
                    Icons.volume_up,
                    size: 20.sp,
                  ),
                  value: _preferences.enableSound,
                  onChanged: (value) => _updatePreferences(
                    _preferences.copyWith(enableSound: value),
                  ),
                ),
                SettingsSwitchTile(
                  title: 'Vibration',
                  subtitle: 'Vibrate for notifications',
                  leading: Icon(
                    Icons.vibration,
                    size: 20.sp,
                  ),
                  value: _preferences.enableVibration,
                  onChanged: (value) => _updatePreferences(
                    _preferences.copyWith(enableVibration: value),
                  ),
                ),
              ],
            ],
          ),

          SettingsSection(
            title: 'TASKS',
            children: [
              SettingsSwitchTile(
                title: 'Show Completed Tasks',
                subtitle: 'Display completed tasks in the list',
                leading: Icon(
                  Icons.check_circle,
                  size: 20.sp,
                ),
                value: _preferences.showCompletedTasks,
                onChanged: (value) => _updatePreferences(
                  _preferences.copyWith(showCompletedTasks: value),
                ),
              ),
              SettingsTile(
                title: 'Default Priority',
                subtitle: _getPriorityDisplayName(_preferences.defaultTaskPriority),
                leading: Icon(
                  Icons.priority_high,
                  size: 20.sp,
                ),
                onTap: _showPriorityDialog,
              ),
              SettingsTile(
                title: 'Default Category',
                subtitle: _getCategoryDisplayName(_preferences.defaultCategoryId),
                leading: Icon(
                  Icons.category,
                  size: 20.sp,
                ),
                onTap: _showCategoryDialog,
              ),
            ],
          ),

          SettingsSection(
            title: 'DATA MANAGEMENT',
            children: [
              SettingsSwitchTile(
                title: 'Auto-delete Completed Tasks',
                subtitle: 'Automatically delete completed tasks after a period',
                leading: Icon(
                  Icons.auto_delete,
                  size: 20.sp,
                ),
                value: _preferences.autoDeleteCompletedTasks,
                onChanged: (value) => _updatePreferences(
                  _preferences.copyWith(autoDeleteCompletedTasks: value),
                ),
              ),
              if (_preferences.autoDeleteCompletedTasks)
                SettingsTile(
                  title: 'Delete After',
                  subtitle: '${_preferences.autoDeleteAfterDays} days',
                  leading: Icon(
                    Icons.schedule,
                    size: 20.sp,
                  ),
                  onTap: _showDeleteAfterDialog,
                ),
            ],
          ),

          SettingsSection(
            title: 'ABOUT',
            children: [
              SettingsTile(
                title: 'Version',
                subtitle: '1.0.0',
                leading: Icon(
                  Icons.info,
                  size: 20.sp,
                ),
              ),
              SettingsTile(
                title: 'Privacy Policy',
                leading: Icon(
                  Icons.privacy_tip,
                  size: 20.sp,
                ),
                onTap: _showPrivacyPolicy,
              ),
              SettingsTile(
                title: 'Terms of Service',
                leading: Icon(
                  Icons.description,
                  size: 20.sp,
                ),
                onTap: _showTermsOfService,
              ),
            ],
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  void _updatePreferences(UserPreferences newPreferences) async {
    final oldPreferences = _preferences;
    setState(() {
      _preferences = newPreferences;
    });
    
    try {
      final service = await ServiceLocator.getPreferencesService();
      await service.saveUserPreferences(newPreferences);
      
      // Update theme if it changed
      if (oldPreferences.themeMode != newPreferences.themeMode) {
        PriorityManagerApp.appState?.updateThemeMode(newPreferences.themeMode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preferences: $e')),
        );
      }
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((themeMode) {
            return RadioListTile<AppThemeMode>(
              title: Text(themeMode.displayName),
              value: themeMode,
              groupValue: _preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  _updatePreferences(_preferences.copyWith(themeMode: value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: Language.values.map((language) {
              return RadioListTile<Language>(
                title: Text(language.displayName),
                value: language,
                groupValue: _preferences.language,
                onChanged: (value) {
                  if (value != null) {
                    _updatePreferences(_preferences.copyWith(language: value));
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4].map((priority) {
            return RadioListTile<int>(
              title: Text(_getPriorityDisplayName(priority)),
              value: priority,
              groupValue: _preferences.defaultTaskPriority,
              onChanged: (value) {
                if (value != null) {
                  _updatePreferences(_preferences.copyWith(defaultTaskPriority: value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteAfterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete After'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [7, 14, 30, 60, 90].map((days) {
            return RadioListTile<int>(
              title: Text('$days days'),
              value: days,
              groupValue: _preferences.autoDeleteAfterDays,
              onChanged: (value) {
                if (value != null) {
                  _updatePreferences(_preferences.copyWith(autoDeleteAfterDays: value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<String?>(
                title: const Text('None'),
                value: null,
                groupValue: _preferences.defaultCategoryId,
                onChanged: (value) {
                  _updatePreferences(_preferences.copyWith(defaultCategoryId: value));
                  Navigator.of(context).pop();
                },
              ),
              ..._availableCategories.map((category) {
                return RadioListTile<String>(
                  title: Text(category.name),
                  value: category.id,
                  groupValue: _preferences.defaultCategoryId,
                  onChanged: (value) {
                    if (value != null) {
                      _updatePreferences(_preferences.copyWith(defaultCategoryId: value));
                      Navigator.of(context).pop();
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final service = await ServiceLocator.getPreferencesService();
                await service.resetToDefaults();
                await _loadPreferences();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reset preferences: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Navigate to privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy - Coming Soon')),
    );
  }

  void _showTermsOfService() {
    // TODO: Navigate to terms of service screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service - Coming Soon')),
    );
  }

  String _getPriorityDisplayName(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  String _getCategoryDisplayName(String? categoryId) {
    if (categoryId == null) {
      return 'None';
    }
    
    // For now, return a generic name. In a real app, you'd look up the category name
    // from the category repository using the categoryId
    switch (categoryId) {
      case '1':
        return 'Work';
      case '2':
        return 'Personal';
      case '3':
        return 'Health';
      case '4':
        return 'Education';
      default:
        return 'Custom Category';
    }
  }
}