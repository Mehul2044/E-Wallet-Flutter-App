import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/password_provider.dart';

import '../../widgets/passwords/update_password_modal.dart';

enum Options { copy, edit }

class PasswordWidget extends StatelessWidget {
  final Password passwordObj;
  final PasswordProvider passwordProvider;
  final EncryptProvider encryptProvider;

  const PasswordWidget(
      {super.key,
      required this.passwordObj,
      required this.passwordProvider,
      required this.encryptProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        onTap: () => showAdaptiveDialog(
          context: context,
          builder: (_) => AlertDialog.adaptive(
            content: Text(
                "User ID:\n${passwordObj.userId}\n\nPassword:\n${passwordObj.password}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Okay"),
              )
            ],
          ),
        ),
        leading: Text(
          passwordObj.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        title: Text(
          passwordObj.userId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          passwordObj.password,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          onSelected: (Options selectedValue) async {
            if (selectedValue == Options.edit) {
              showModalBottomSheet(
                  context: context,
                  builder: (_) => UpdatePasswordModal(
                      passwordProvider: passwordProvider,
                      encryptProvider: encryptProvider,
                      passwordId: passwordObj.id,
                      initialValue: passwordObj.password));
            } else if (selectedValue == Options.copy) {
              await Clipboard.setData(
                  ClipboardData(text: passwordObj.password));
              Fluttertoast.showToast(msg: "Password copied to Clipboard");
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: Options.copy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 10),
                  Text("Copy"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: Options.edit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 10),
                  Text("Edit"),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
