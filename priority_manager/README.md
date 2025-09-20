# Priority Manager

Priority Manager is a cross-platform Flutter application designed to help users manage their personal and professional tasks with varying priority levels. The app utilizes the Hive database for data persistence, ensuring that tasks are stored efficiently and can be retrieved quickly.

## Features

- **Task Management**: Create, read, update, and delete tasks with different priority levels.
- **Category Management**: Organize tasks into categories for better management.
- **User Preferences**: Customize app settings according to user preferences.
- **Responsive Design**: The app is built with a responsive design to ensure a seamless experience across different devices.

## Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- An IDE such as Android Studio or Visual Studio Code.
- Hive package for local storage.

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd priority_manager
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the application:
   ```
   flutter run
   ```

### Directory Structure

The project is organized into several directories for better maintainability:

```
lib/
├── core/                        # Shared utilities, constants, themes
├── features/                    # Feature-based organization
│   ├── task_management/         # Task management feature
│   ├── categories/              # Category management feature
│   └── settings/                # User settings feature
└── main.dart                    # App entry point
```

## Usage

- Launch the app and navigate through the task management, category selection, and settings screens.
- Add tasks with different priorities and categorize them as needed.
- Modify user preferences to customize the app experience.

## Testing

To run widget tests, use the following command:
```
flutter test
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.