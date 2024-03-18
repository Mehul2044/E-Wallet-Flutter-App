import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';
import '../provider/theme_provider.dart';

import 'profile_screen.dart';

import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context);

    if (signInProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Wallet"),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, value, _) => Row(
              children: [
                Text(value.isDark ? "Dark Mode" : "Light Mode"),
                const SizedBox(width: 10),
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
      body: const BottomNavBar(),
    );
  }
}
