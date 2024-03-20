import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:wallet_app/provider/encrypt_provider.dart';

class Password {
  final String id;
  final String title;
  final String userId;
  final String password;

  Password(
      {required this.id,
      required this.title,
      required this.userId,
      required this.password});
}

class PasswordProvider with ChangeNotifier {
  bool _isDataLoaded = false;
  bool isLoading = false;
  List<Password> _list = [];

  List<Password> get list => [..._list];

  Future<void> addPassword(String title, String userId, String password,
      EncryptProvider encryptProvider) async {
    isLoading = true;
    notifyListeners();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/passwords");
    DatabaseReference passwordRef = ref.push();
    String passwordId = passwordRef.key!;
    String encryptedPassword = await encryptProvider.encrypt(password);
    await passwordRef
        .set({"title": title, "userId": userId, "password": encryptedPassword});
    _list.add(Password(
        id: passwordId, title: title, userId: userId, password: password));
    isLoading = false;
    notifyListeners();
  }

  Future<void> updatePassword(String passwordId, String password,
      EncryptProvider encryptProvider) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/passwords/$passwordId");
    int index = _list.indexWhere((element) => element.id == passwordId);
    final passwordObj = _list[index];
    final newPasswordObj = Password(
        id: passwordId,
        title: passwordObj.title,
        userId: passwordObj.userId,
        password: password);
    _list[index] = newPasswordObj;
    notifyListeners();
    String newPassword = await encryptProvider.encrypt(password);
    await ref.update({"password": newPassword});
  }

  Future<void> deletePassword(String passwordId) async {
    _list.removeWhere((element) => element.id == passwordId);
    notifyListeners();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/passwords/$passwordId");
    await ref.remove();
  }

  Future<void> fetchAndSetPasswords(EncryptProvider encryptProvider) async {
    if (_isDataLoaded) return;
    _list.clear();
    final List<Password> passwordList = [];
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/passwords");
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> passwordMap =
          snapshot.value as Map<dynamic, dynamic>;
      for (var entry in passwordMap.entries) {
        var key = entry.key;
        var value = entry.value;
        final decryptedPassword =
            await encryptProvider.decrypt(value['password']);
        passwordList.add(Password(
          id: key,
          title: value['title'],
          userId: value['userId'],
          password: decryptedPassword,
        ));
      }
    }
    _list = passwordList;
    _isDataLoaded = true;
  }

  void signOut() {
    _list.clear();
    _isDataLoaded = false;
  }
}
