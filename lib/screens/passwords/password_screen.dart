import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/password_provider.dart';

import '../../widgets/passwords/add_password_modal.dart';
import '../../widgets/passwords/password_widget.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  Future<void> addHandler(
      BuildContext context,
      PasswordProvider passwordProvider,
      EncryptProvider encryptProvider) async {
    await showDialog(
        context: context,
        builder: (context) => PasswordAddModal(
            passwordProvider: passwordProvider,
            encryptProvider: encryptProvider));
  }

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
                          onPressed: () => addHandler(
                              context, passwordProvider, encryptProvider),
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
                                  onPressed: () => addHandler(context,
                                      passwordProvider, encryptProvider),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add new Password"),
                                ),
                              ],
                            ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) => Dismissible(
                        key: Key(passwordProvider.list[index].id),
                        confirmDismiss: (_) => _confirmDismissDelete(context),
                        direction: DismissDirection.horizontal,
                        onDismissed: (_) => passwordProvider
                            .deletePassword(passwordProvider.list[index].id),
                        child: PasswordWidget(
                          passwordObj: passwordProvider.list[index],
                          passwordProvider: passProvider,
                          encryptProvider: encryptProvider,
                        ),
                      ),
                      itemCount: passwordProvider.list.length,
                    ),
            ),
          );
        });
  }

  Future<bool> _confirmDismissDelete(BuildContext context) async {
    late bool returnValue;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog.adaptive(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete the note?"),
              actions: [
                TextButton(
                  onPressed: () {
                    returnValue = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Yes, delete"),
                ),
                TextButton(
                    onPressed: () {
                      returnValue = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text("No")),
              ],
            ));
    return returnValue;
  }
}
