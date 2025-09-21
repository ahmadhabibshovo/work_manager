enum AppThemeMode {
  system,
  light,
  dark;

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

enum Language {
  english,
  spanish,
  french,
  german,
  italian,
  portuguese;

  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.spanish:
        return 'Español';
      case Language.french:
        return 'Français';
      case Language.german:
        return 'Deutsch';
      case Language.italian:
        return 'Italiano';
      case Language.portuguese:
        return 'Português';
    }
  }

  String get code {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.spanish:
        return 'es';
      case Language.french:
        return 'fr';
      case Language.german:
        return 'de';
      case Language.italian:
        return 'it';
      case Language.portuguese:
        return 'pt';
    }
  }
}

class UserPreferences {
  final AppThemeMode themeMode;
  final Language language;
  final bool enableNotifications;
  final bool enableSound;
  final bool enableVibration;
  final bool showCompletedTasks;
  final int defaultTaskPriority;
  final String? defaultCategoryId;
  final bool autoDeleteCompletedTasks;
  final int autoDeleteAfterDays;

  const UserPreferences({
    this.themeMode = AppThemeMode.system,
    this.language = Language.english,
    this.enableNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.showCompletedTasks = true,
    this.defaultTaskPriority = 2, // Medium priority
    this.defaultCategoryId,
    this.autoDeleteCompletedTasks = false,
    this.autoDeleteAfterDays = 30,
  });

  UserPreferences copyWith({
    AppThemeMode? themeMode,
    Language? language,
    bool? enableNotifications,
    bool? enableSound,
    bool? enableVibration,
    bool? showCompletedTasks,
    int? defaultTaskPriority,
    String? defaultCategoryId,
    bool? autoDeleteCompletedTasks,
    int? autoDeleteAfterDays,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      defaultTaskPriority: defaultTaskPriority ?? this.defaultTaskPriority,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      autoDeleteCompletedTasks: autoDeleteCompletedTasks ?? this.autoDeleteCompletedTasks,
      autoDeleteAfterDays: autoDeleteAfterDays ?? this.autoDeleteAfterDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'language': language.name,
      'enableNotifications': enableNotifications,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'showCompletedTasks': showCompletedTasks,
      'defaultTaskPriority': defaultTaskPriority,
      'defaultCategoryId': defaultCategoryId,
      'autoDeleteCompletedTasks': autoDeleteCompletedTasks,
      'autoDeleteAfterDays': autoDeleteAfterDays,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: AppThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      language: Language.values.firstWhere(
        (lang) => lang.name == json['language'],
        orElse: () => Language.english,
      ),
      enableNotifications: json['enableNotifications'] ?? true,
      enableSound: json['enableSound'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      showCompletedTasks: json['showCompletedTasks'] ?? true,
      defaultTaskPriority: json['defaultTaskPriority'] ?? 2,
      defaultCategoryId: json['defaultCategoryId'],
      autoDeleteCompletedTasks: json['autoDeleteCompletedTasks'] ?? false,
      autoDeleteAfterDays: json['autoDeleteAfterDays'] ?? 30,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(themeMode: $themeMode, language: $language, enableNotifications: $enableNotifications)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreferences &&
        other.themeMode == themeMode &&
        other.language == language &&
        other.enableNotifications == enableNotifications &&
        other.enableSound == enableSound &&
        other.enableVibration == enableVibration &&
        other.showCompletedTasks == showCompletedTasks &&
        other.defaultTaskPriority == defaultTaskPriority &&
        other.defaultCategoryId == defaultCategoryId &&
        other.autoDeleteCompletedTasks == autoDeleteCompletedTasks &&
        other.autoDeleteAfterDays == autoDeleteAfterDays;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        language.hashCode ^
        enableNotifications.hashCode ^
        enableSound.hashCode ^
        enableVibration.hashCode ^
        showCompletedTasks.hashCode ^
        defaultTaskPriority.hashCode ^
        defaultCategoryId.hashCode ^
        autoDeleteCompletedTasks.hashCode ^
        autoDeleteAfterDays.hashCode;
  }
}