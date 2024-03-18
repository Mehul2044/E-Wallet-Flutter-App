import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' hide Key;

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptProvider with ChangeNotifier {
  late String _secretKey;
  final _iv = IV.fromLength(16);

  String encrypt(String text) {
    final key = Key.fromUtf8(_secretKey);
    final encryptText = Encrypter(AES(key));
    final encrypted = encryptText.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String text) {
    final key = Key.fromUtf8(_secretKey);
    final encryptText = Encrypter(AES(key));
    final decrypted = encryptText.decrypt(Encrypted.fromBase64(text), iv: _iv);
    return decrypted;
  }

  Future<void> fetchAndSetKey() async {
    const storage = FlutterSecureStorage();
    String? key = await storage.read(key: "secretKey");
    if (key != null) {
      _secretKey = key;
    } else {
      String? keyFromDatabase = await _getKeyFromDatabase();
      if (keyFromDatabase != null) {
        await storage.write(key: "secretKey", value: keyFromDatabase);
        _secretKey = keyFromDatabase;
      } else {
        String generatedKey = _generateRandomKey();
        await _storeKeyInDatabase(generatedKey);
        await storage.write(key: "secretKey", value: generatedKey);
        _secretKey = generatedKey;
      }
    }
  }

  Future<String?> _getKeyFromDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/secretKey");
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return snapshot.value.toString();
    } else {
      return null;
    }
  }

  Future<void> _storeKeyInDatabase(String secretKey) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref(FirebaseAuth.instance.currentUser!.uid);
    await ref.set({"secretKey": secretKey});
  }

  String _generateRandomKey() {
    final random = Random.secure();
    final List<int> bytes = List.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).substring(0, 32);
  }
}
