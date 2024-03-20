import 'package:flutter/material.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/password_provider.dart';

class UpdatePasswordModal extends StatefulWidget {
  final PasswordProvider passwordProvider;
  final EncryptProvider encryptProvider;
  final String passwordId;
  final String initialValue;

  const UpdatePasswordModal({
    super.key,
    required this.passwordProvider,
    required this.encryptProvider,
    required this.passwordId,
    required this.initialValue,
  });

  @override
  State<UpdatePasswordModal> createState() => _UpdatePasswordModalState();
}

class _UpdatePasswordModalState extends State<UpdatePasswordModal> {
  final _formKey = GlobalKey<FormState>();
  late String password;

  bool _formSave() {
    bool? isValidate = _formKey.currentState?.validate();
    if (isValidate == null || !isValidate) return false;
    _formKey.currentState?.save();
    widget.passwordProvider
        .updatePassword(widget.passwordId, password, widget.encryptProvider);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Enter New Password",
                hintText: widget.initialValue,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a valid value!";
                }
                return null;
              },
              onSaved: (value) => password = value!,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    bool result = _formSave();
                    if (result) Navigator.of(context).pop();
                  },
                  child: const Text("Update Password"),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
