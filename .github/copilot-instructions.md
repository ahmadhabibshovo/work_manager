# AI Agent Instructions for Priority Manager Flutter App

## Project Overview
Priority Manager is a cross-platform Flutter app for managing personal and professional tasks with priority levels. Built with responsive design using flutter_screenutil.

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

## Development Workflows

### Essential Commands
```bash
# Multi-platform development
flutter run -d android    # Android emulator/device
flutter run -d chrome     # Web browser
flutter run -d linux      # Linux desktop

# Code quality (run these frequently)
flutter analyze           # Static analysis
flutter format .          # Code formatting
flutter fix --apply       # Auto-fix issues

# Testing
flutter test --coverage   # Run tests with coverage
```

### Platform-Specific Builds
```bash
# Android (namespace: com.work_manager.app.work_manager)
flutter build apk --release

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

### Android (android/app/build.gradle.kts)
- Namespace: `com.work_manager.app.work_manager`
- JVM Target: Java 11
- Min SDK: Flutter default (API 21+)

### Web (web/)
- Standard Flutter web with PWA manifest
- Icons in `web/icons/` directory

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

## Key Reference Files
- `lib/main.dart` - ScreenUtilInit setup and app structure
- `pubspec.yaml` - Dependencies (flutter_screenutil, cupertino_icons)
- `analysis_options.yaml` - Linting rules (flutter_lints)
- `android/app/build.gradle.kts` - Android configuration
- `test/widget_test.dart` - Testing patterns

## Development Priorities
1. Implement task CRUD operations with priority levels
2. Add local storage for task persistence
3. Create responsive task list and detail views
4. Add categories (Personal vs Professional)
5. Implement due dates and notifications</content>
<parameter name="filePath">/home/habib/dev/APPS/work_manager/.github/copilot-instructions.md