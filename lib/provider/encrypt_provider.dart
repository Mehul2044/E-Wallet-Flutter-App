import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptProvider with ChangeNotifier {
  late String _secretKey;

  Future<String> encrypt(String text) async {
    String encryptedText =
        await FlutterAesEcbPkcs5.encryptString(text, _secretKey) as String;
    return encryptedText;
  }

  Future<String> decrypt(String text) async {
    String decryptedText =
        await FlutterAesEcbPkcs5.decryptString(text, _secretKey) as String;
    return decryptedText;
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
        String generatedKey = await _generateRandomKey();
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

  Future<String> _generateRandomKey() async {
    String key = await FlutterAesEcbPkcs5.generateDesKey(128) as String;
    return key;
  }
}
