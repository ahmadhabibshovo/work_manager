# Priority Manager

A comprehensive Flutter application designed to help you manage and prioritize your daily tasks, both personal and professional. Whether it's buying groceries at home or handling multiple office projects, Priority Manager helps you stay organized and get things done efficiently.

## 🚀 Features

- **Task Management**: Create, edit, and organize tasks with ease
- **Priority Levels**: Set high, medium, and low priority levels for tasks
- **Categories**: Organize tasks into personal and professional categories
- **Due Dates**: Set deadlines and reminders for important tasks
- **Progress Tracking**: Mark tasks as completed and track your productivity
- **Responsive Design**: Works seamlessly across all platforms (Android, iOS, Web, Desktop)
- **Cross-Platform**: Available on Android, iOS, Linux, macOS, and Windows

## 📱 Screenshots

*Screenshots will be added once the app is fully developed*

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Stateful Widgets (with potential for future expansion)
- **UI Framework**: Material Design
- **Responsive Design**: flutter_screenutil
- **Platform Support**: Multi-platform (Android, iOS, Web, Linux, macOS, Windows)

## 📋 Prerequisites

Before running this project, make sure you have the following installed:

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code with Flutter extensions
- For mobile development: Android SDK or Xcode (for iOS)

## 🚀 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/work_manager.git
   cd work_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android

   # For iOS (macOS only)
   flutter run -d ios

   # For Web
   flutter run -d chrome

   # For Desktop
   flutter run -d linux    # Linux
   flutter run -d macos    # macOS
   flutter run -d windows  # Windows
   ```

## 📖 Usage

### For Personal Tasks
- Add daily chores like "Buy rice", "Clean house", "Pay bills"
- Set priorities based on urgency
- Track completion and build productive habits

### For Professional Tasks
- Manage multiple projects and deadlines
- Organize tasks by project or department
- Set reminders for important meetings and deliverables

### Key Workflows
1. **Add Task**: Tap the "+" button to create a new task
2. **Set Priority**: Choose from High, Medium, or Low priority
3. **Add Details**: Include due dates, notes, and categories
4. **Track Progress**: Mark tasks as completed when done
5. **Review**: Check your productivity and plan for upcoming tasks

## 🏗️ Development

### Available Commands

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Fix auto-fixable issues
flutter fix --apply

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build release versions
flutter build apk       # Android APK
flutter build ios       # iOS
flutter build web       # Web
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── widgets/                  # Reusable UI components
├── screens/                  # App screens/pages
├── models/                   # Data models
└── utils/                    # Utility functions

android/                      # Android-specific files
ios/                          # iOS-specific files
web/                          # Web-specific files
linux/                        # Linux-specific files
macos/                        # macOS-specific files
windows/                      # Windows-specific files
```

## 🧪 Testing

The project includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter best practices
- Use meaningful commit messages
- Write tests for new features
- Ensure code passes `flutter analyze`
- Follow the existing code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋 Support

If you have any questions or need help:

- Open an issue on GitHub
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Join our community discussions

## 🗺️ Roadmap

- [ ] Task categories and tags
- [ ] Reminder notifications
- [ ] Data persistence with local storage
- [ ] Cloud synchronization
- [ ] Advanced analytics and insights
- [ ] Collaboration features
- [ ] Integration with calendar apps

---

**Made with ❤️ using Flutter**
