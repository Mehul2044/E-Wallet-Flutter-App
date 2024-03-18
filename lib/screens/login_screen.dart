import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';

import '../config/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context);
    return Scaffold(
      body: signInProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(Constants.appLogo),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () => signInProvider.signIn(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(Constants.googleLogo),
                        const Text("Sign In with Google"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
