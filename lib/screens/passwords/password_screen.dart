import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/password_provider.dart';

import '../../widgets/passwords/password_widget.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passProvider = Provider.of<PasswordProvider>(context, listen: false);
    final encryptProvider =
        Provider.of<EncryptProvider>(context, listen: false);
    return FutureBuilder(
        future: passProvider.fetchAndSetPasswords(encryptProvider),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          return Consumer<PasswordProvider>(
            builder: (context, passwordProvider, _) => Scaffold(
              floatingActionButton: passwordProvider.list.isEmpty
                  ? null
                  : passwordProvider.isLoading
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: () => {},
                          child: const Icon(Icons.add),
                        ),
              body: passwordProvider.list.isEmpty
                  ? Center(
                      child: passwordProvider.isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("No Passwords to Display"),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add new Password"),
                                ),
                              ],
                            ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return PasswordWidget(
                            passwordObj: passwordProvider.list[index]);
                      },
                      itemCount: passwordProvider.list.length,
                    ),
            ),
          );
        });
  }
}
