# AI Agent Instructions for Priority Manager Flutter App

## Project Overview
Priority Manager is a cross-platform Flutter app for managing personal and professional tasks with priority levels. Built with responsive design using flutter_screenutil. **Primary focus: Android development and deployment.**

## Architecture Patterns

### Core App Structure
- **Root Widget**: `lib/main.dart` - Always wrap `MaterialApp` with `ScreenUtilInit(designSize: Size(375, 812))`
- **State Management**: Use `StatefulWidget` + `setState()` for local state; avoid complex state management libraries initially
- **Responsive Design**: Use `.w`, `.h`, `.r` extensions from flutter_screenutil for all sizing

### Key Dependencies & Usage
```dart
// ALWAYS use this pattern for responsive containers
Container(
  width: 100.w,    // 100 * screen width ratio
  height: 50.h,    // 50 * screen height ratio
  padding: EdgeInsets.all(16.r), // 16 * min(width,height) ratio
)

// ScreenUtilInit wrapper (from lib/main.dart)
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => MaterialApp(...),
)
```

### Firebase Integration (Offline-First)
- **Backend**: Firebase (Firestore for data sync, Firebase Auth optional)
- **Offline Strategy**: App works fully offline with Hive local storage; syncs to Firebase when internet available
- **Sync Behavior**: Automatic sync on app launch/connectivity; manual sync option in settings
- **Dependencies**: Add to `pubspec.yaml`:
  ```yaml
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0  # Optional for user accounts
  connectivity_plus: ^5.0.2  # For network detection
  ```
- **Initialization**: Initialize Firebase in `lib/main.dart` after Hive setup
- **Repository Pattern**: Update repositories to handle both local (Hive) and remote (Firestore) data with sync logic

## Development Workflows

### Essential Commands (Android Focus)
```bash
# Android development (PRIMARY PLATFORM)
flutter run -d android          # Run on Android emulator/device
flutter build apk --release     # Build release APK for Android
flutter build appbundle --release  # Build Android App Bundle (AAB)
flutter install                 # Install app on connected Android device

# Multi-platform development
flutter run -d chrome           # Web browser
flutter run -d linux            # Linux desktop

# Code quality (run these frequently)
flutter analyze                 # Static analysis
flutter format .                # Code formatting
flutter fix --apply             # Auto-fix issues

# Testing
flutter test --coverage         # Run tests with coverage
```

### Android-Specific Development
```bash
# Device management
flutter devices                  # List connected devices
adb devices                      # List Android devices via ADB
flutter run -d emulator-5554     # Run on specific emulator

# Build variants
flutter build apk --debug        # Debug APK
flutter build apk --profile      # Profile APK for performance testing
flutter build apk --release      # Release APK for production

# Android Studio integration
flutter build apk --release && flutter install  # Build and install in one command
```

### Platform-Specific Builds
```bash
# Android (PRIMARY - namespace: com.work_manager.app.work_manager)
flutter build apk --release                    # Release APK
flutter build appbundle --release              # Play Store AAB
flutter build apk --debug                      # Debug APK for testing

# Web (standard PWA setup)
flutter build web

# Desktop platforms
flutter build linux
flutter build windows
flutter build macos
```

## Coding Conventions

### Widget Patterns
- Use `StatelessWidget` by default; only `StatefulWidget` when internal state changes
- Keep business logic inside widget classes (not separate files initially)
- Follow Dart naming: `camelCase` for methods, `PascalCase` for classes/widgets

### File Organization

#### Core Structure
```
lib/
├── main.dart                    # App entry point with ScreenUtilInit
├── core/                        # Shared utilities, constants, themes
└── features/                    # Feature-based organization
    └── [feature_name]/
        ├── data/
        │   ├── models/          # Data models for this feature
        │   │   └── [model].dart
        │   ├── repositories/    # Data access layer
        │   └── services/        # Business logic services
        └── presentation/
            ├── widgets/         # Feature-specific UI components
            │   └── [widget].dart
            ├── screens/         # Screen/page widgets
            │   └── [screen].dart
            └── [feature]_page.dart  # Main page for this feature
```

#### Feature Examples
```
lib/features/
├── task_management/
│   ├── data/
│   │   ├── models/
│   │   │   ├── task.dart
│   │   │   └── priority.dart
│   │   └── repositories/
│   │       └── task_repository.dart
│   └── presentation/
│       ├── widgets/
│       │   ├── task_card.dart
│       │   └── priority_badge.dart
│       ├── screens/
│       │   └── task_list_screen.dart
│       └── task_management_page.dart
├── categories/
│   ├── data/
│   │   ├── models/
│   │   │   └── category.dart
│   │   └── repositories/
│   │       └── category_repository.dart
│   └── presentation/
│       ├── widgets/
│       │   └── category_chip.dart
│       ├── screens/
│       │   └── category_selection_screen.dart
│       └── categories_page.dart
└── settings/
    ├── data/
    │   ├── models/
    │   │   └── user_preferences.dart
    │   └── services/
    │       └── preferences_service.dart
    └── presentation/
        ├── widgets/
        │   └── settings_tile.dart
        ├── screens/
        │   └── settings_screen.dart
        └── settings_page.dart
```

#### Organization Rules
- **Feature-first**: Group code by business features, not technical layers
- **Data Layer**: Contains models, repositories, and services for data management
- **Presentation Layer**: Contains widgets and screens for UI components
- **Shared Code**: Place in `lib/core/` for utilities used across features
- **Models**: Keep simple data classes in `data/models/` folder
- **Widgets**: Feature-specific widgets in `presentation/widgets/`
- **Screens**: Page-level widgets in `presentation/screens/`

### Testing Pattern (from test/widget_test.dart)
```dart
testWidgets('Feature test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('Expected Text'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('Updated Text'), findsOneWidget);
});
```

## Platform Configuration

### Android (PRIMARY PLATFORM - android/app/build.gradle.kts)
- **Namespace**: `com.work_manager.app.work_manager`
- **JVM Target**: Java 11
- **Min SDK**: Flutter default (API 21+)
- **Target SDK**: Latest stable Android API
- **Build Types**: debug, profile, release
- **Signing**: Configure signing config for release builds
- **Permissions**: Internet, network state, storage (for Hive)

### Android Build Configuration
```kotlin
// android/app/build.gradle.kts key settings
android {
    namespace = "com.work_manager.app.work_manager"
    compileSdk = 34  // Latest stable
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    
    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}
```

### Web (web/)
- Standard Flutter web with PWA manifest
- Icons in `web/icons/` directory

### Firebase Android Configuration
- **google-services.json**: Place in `android/app/` directory
- **App ID**: `1:469519052412:android:e4e9dd95054bbc0bf723f9`
- **Project ID**: `work-priority-manager`
- **API Key**: Configured in `lib/firebase_options.dart`

## Common Patterns & Gotchas

### Responsive Design Rules
- Always use `.w`, `.h`, `.r` extensions instead of fixed pixels
- Design size is 375x812 (iPhone X dimensions)
- Test on multiple screen sizes using device preview

### State Management
```dart
// Correct pattern for state updates
void _updateState() {
  setState(() {
    _counter++;  // Update synchronously inside setState
  });
}
```

### Build Issues
- Run `flutter clean` if platform-specific build issues occur
- Use `flutter doctor` to diagnose environment problems
- Ensure Android Studio/VS Code has Flutter extensions
- For Android build issues, check `android/app/build.gradle.kts` configuration
- Verify Firebase configuration in `lib/firebase_options.dart`

## Android Development Best Practices

### Performance Optimization
- Use `flutter build apk --profile` for performance testing
- Monitor app size with `flutter build apk --analyze-size`
- Optimize images and assets for Android deployment
- Test on various Android devices and API levels

### Testing on Android
```bash
# Test on physical Android device
flutter run -d android

# Test on Android emulator
flutter emulators --launch <emulator_name>
flutter run -d <emulator_id>

# Build and install release APK
flutter build apk --release
flutter install
```

### Android Deployment Checklist
- [ ] Update version code and name in `android/app/build.gradle.kts`
- [ ] Configure signing configuration for release builds
- [ ] Test app on multiple Android devices
- [ ] Verify Firebase configuration works in production
- [ ] Check app permissions and manifest
- [ ] Optimize app size and performance

## Key Reference Files
- `lib/main.dart` - ScreenUtilInit setup and app structure
- `pubspec.yaml` - Dependencies (flutter_screenutil, cupertino_icons, firebase_core, cloud_firestore, connectivity_plus)
- `analysis_options.yaml` - Linting rules (flutter_lints)
- `android/app/build.gradle.kts` - Android configuration
- `test/widget_test.dart` - Testing patterns

## Development Priorities
1. **✅ COMPLETED**: Implement task CRUD operations with priority levels
2. **✅ COMPLETED**: Add local storage for task persistence (Hive)
3. **✅ COMPLETED**: Create responsive task list and detail views
4. **✅ COMPLETED**: Add categories (Personal vs Professional)
5. **✅ COMPLETED**: Implement Firebase offline-first sync (automatic + manual)
6. **🔄 IN PROGRESS**: Implement due dates and notifications
7. **📱 ANDROID FOCUS**: Optimize Android performance and build process
8. **🚀 DEPLOYMENT**: Prepare for Android Play Store release
9. **🔧 TESTING**: Add comprehensive unit and integration tests
10. **📊 MONITORING**: Implement crash reporting and analytics</content>
<parameter name="filePath">/home/habib/dev/APPS/work_manager/.github/copilot-instructions.md