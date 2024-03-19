import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../provider/note_provider.dart';
import '../provider/encrypt_provider.dart';

import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class HomeConfig extends StatelessWidget {
  const HomeConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final encryptProvider =
        Provider.of<EncryptProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    Future<void> loadData() async {
      await encryptProvider.fetchAndSetKey();
      await noteProvider.fetchAndSetNotes(encryptProvider);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: loadData(),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator()));
                  }
                  return const MainScreen();
                });
          } else {
            return const LoginScreen();
          }
        });
  }
}
