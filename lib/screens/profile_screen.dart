import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../provider/note_provider.dart';
import '../provider/password_provider.dart';
import '../provider/sign_in_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    final passwordProvider =
        Provider.of<PasswordProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: height * 0.01, bottom: height * 0.02),
            child: CircleAvatar(
              minRadius: height * 0.05,
              backgroundColor: Colors.purple,
              child: Text(
                FirebaseAuth.instance.currentUser!.displayName!.substring(0, 1),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Text(
            FirebaseAuth.instance.currentUser!.displayName!,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          SizedBox(height: height * 0.04),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Email:"),
                    Text(FirebaseAuth.instance.currentUser!.email!),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("User ID:"),
                    Text(FirebaseAuth.instance.currentUser!.uid),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
          Container(
            height: height * 0.1,
            margin: EdgeInsets.only(bottom: height * 0.07),
            padding: const EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(
                    text: "* By using our app, you agree to our\n  "),
                TextSpan(
                  text: "Terms & Conditions",
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: "."),
              ]),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              signInProvider.signOut(noteProvider, passwordProvider);
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }
}
