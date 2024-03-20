import 'package:flutter/material.dart';

import '../screens/documents_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/passwords/password_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    NotesScreen(),
    PasswordScreen(),
    DocumentsScreen()
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: "Notes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.password),
            label: "Passwords",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: "Documents",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
