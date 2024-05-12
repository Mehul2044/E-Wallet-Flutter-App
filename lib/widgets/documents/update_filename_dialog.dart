import 'package:flutter/material.dart';

import '../../provider/document_provider.dart';

class UpdateFilenameDialog extends StatefulWidget {
  final DocumentProvider provider;
  final String documentId;

  const UpdateFilenameDialog(
      {super.key, required this.provider, required this.documentId});

  @override
  State<UpdateFilenameDialog> createState() => _UpdateFilenameDialogState();
}

class _UpdateFilenameDialogState extends State<UpdateFilenameDialog> {
  final _formKey = GlobalKey<FormState>();
  late String fileName;

  bool _isLoading = false;

  Future<void> _submitHandler() async {
    final navigator = Navigator.of(context);
    bool? isValidate = _formKey.currentState?.validate();
    if (isValidate == null || !isValidate) return;
    _formKey.currentState?.save();
    setState(() => _isLoading = true);
    await widget.provider.renameFile(widget.documentId, fileName);
    navigator.pop();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : AlertDialog(
            title: const Text("Update Filename"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Enter New Filename",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a valid value!";
                  }
                  return null;
                },
                onSaved: (value) => fileName = value!,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: _submitHandler,
                child: const Text("Update"),
              ),
            ],
          );
  }
}
