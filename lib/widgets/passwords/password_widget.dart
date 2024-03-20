import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../provider/password_provider.dart';

class PasswordWidget extends StatelessWidget {
  final Password passwordObj;

  const PasswordWidget({super.key, required this.passwordObj});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        leading: Text(passwordObj.title),
        title: Text(passwordObj.userId),
        subtitle: Text(passwordObj.password),
        trailing: IconButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: passwordObj.password));
            Fluttertoast.showToast(msg: "Password copied to Clipboard");
          },
          icon: const Icon(Icons.copy),
        ),
      ),
    );
  }
}
