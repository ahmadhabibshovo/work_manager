import 'package:flutter/material.dart';
import '../../features/task_management/presentation/task_management_page.dart';
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

  static const List<Widget> _pages = <Widget>[
    TaskManagementPage(),
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

                // Handle the result if needed (e.g., refresh the task list)
                if (result != null) {
                  // Task was created successfully
                  // You could refresh the task list here if needed
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}