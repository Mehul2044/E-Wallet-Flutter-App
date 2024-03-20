import 'package:flutter/material.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/password_provider.dart';

class PasswordAddModal extends StatefulWidget {
  final PasswordProvider passwordProvider;
  final EncryptProvider encryptProvider;

  const PasswordAddModal(
      {super.key,
      required this.passwordProvider,
      required this.encryptProvider});

  @override
  State<PasswordAddModal> createState() => _PasswordAddModalState();
}

class _PasswordAddModalState extends State<PasswordAddModal> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String userId;
  late String password;

  bool _isPasswordObscure = true;

  bool _saveForm() {
    bool? isValidate = _formKey.currentState?.validate();
    if (isValidate == null || !isValidate) return false;
    _formKey.currentState?.save();
    widget.passwordProvider
        .addPassword(title, userId, password, widget.encryptProvider);
    return true;
  }

  String? _validatorFunction(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a heading!";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: const Text("Add New Password"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: "Website/Application Name"),
              validator: _validatorFunction,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: (value) => title = value!,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: "UserID"),
              validator: _validatorFunction,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onSaved: (value) => userId = value!,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: width * 0.5,
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: _validatorFunction,
                    obscureText: _isPasswordObscure,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onSaved: (value) => password = value!,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _isPasswordObscure = !_isPasswordObscure),
                  icon: Icon(_isPasswordObscure
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final value = _saveForm();
            if (value) Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
