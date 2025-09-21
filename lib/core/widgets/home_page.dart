import 'package:flutter/material.dart';
import '../../features/task_management/presentation/screens/task_list_screen.dart';
import '../../features/categories/presentation/categories_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/task_management/presentation/screens/create_task_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    TaskListScreen(key: TaskListScreen.globalKey),
    CategoriesPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority Manager'),
        elevation: 0,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTaskScreen(),
                  ),
                );

                // Refresh the task list if a task was created
                if (result != null) {
                  TaskListScreen.globalKey.currentState?.refreshTasks();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}