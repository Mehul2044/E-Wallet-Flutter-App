import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';
import '../provider/theme_provider.dart';

import '../screens/documents/documents_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/passwords/password_screen.dart';
import '../screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    NotesScreen(),
    PasswordScreen(),
    DocumentsScreen()
  ];

  static const List<String> _titles = ["Notes", "Passwords", "Documents"];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context);

    if (signInProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, value, _) => Row(
              children: [
                Text(
                  value.isDark ? "Dark Mode" : "Light Mode",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 5),
                Switch.adaptive(
                    value: value.isDark,
                    onChanged: (state) =>
                        state ? value.setDarkMode() : value.setLightMode()),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                FirebaseAuth.instance.currentUser!.displayName!.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
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
