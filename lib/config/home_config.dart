import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../provider/encrypt_provider.dart';

import '../screens/login_screen.dart';

import '../widgets/bottom_nav_bar.dart';

class HomeConfig extends StatelessWidget {
  const HomeConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final encryptProvider =
        Provider.of<EncryptProvider>(context, listen: false);

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: encryptProvider.fetchAndSetKey(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator()));
                  }
                  return const BottomNavBar();
                });
          } else {
            return const LoginScreen();
          }
        });
  }
}
