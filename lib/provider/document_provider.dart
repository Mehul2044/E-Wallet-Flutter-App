import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class Document {
  final String fileName;
  final DateTime dateTime;
  final String downloadUrl;

  Document(
      {required this.downloadUrl,
      required this.fileName,
      required this.dateTime});
}

class DocumentProvider with ChangeNotifier {
  bool isLoading = false;
  bool isDataFetched = false;

  final List<Document> _list = [];

  List<Document> get list => [..._list];

  Future<void> addFiles(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, allowCompression: false);
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        final storageRef = FirebaseStorage.instance
            .ref(FirebaseAuth.instance.currentUser!.uid);
        for (var file in files) {
          String fileName = file.path.split('/').last;
          if (_list.any((element) => element.fileName == fileName)) {
            scaffoldMessenger.showSnackBar(SnackBar(
                content: Text(
                    "File with name $fileName already exists. This file will not be uploaded.")));
            continue;
          }
          final docRef = storageRef.child(fileName);
          await docRef.putFile(file);
          String downloadUrl = await docRef.getDownloadURL();
          _list.add(Document(
              fileName: fileName,
              dateTime: DateTime.now(),
              downloadUrl: downloadUrl));
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Error Occurred: ${e.toString()}")));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteFile(String fileName) async {
    _list.removeWhere((element) => element.fileName == fileName);
    notifyListeners();
    final storageRef = FirebaseStorage.instance
        .ref(FirebaseAuth.instance.currentUser!.uid)
        .child(fileName);
    await storageRef.delete();
  }

  Future<void> fetchAndSetDocuments() async {
    if (isDataFetched) return;
    _list.clear();
    final storageRef =
        FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid);
    ListResult result = await storageRef.listAll();
    for (var item in result.items) {
      final metadata = await item.getMetadata();
      final uploadTime = metadata.timeCreated ?? DateTime.now();
      final downloadUrl = await item.getDownloadURL();
      final fileName = metadata.name;
      _list.add(Document(
          downloadUrl: downloadUrl, fileName: fileName, dateTime: uploadTime));
    }
    isDataFetched = true;
  }

  void signOut() {
    _list.clear();
    isDataFetched = false;
  }
}
