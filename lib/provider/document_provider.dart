import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Document {
  final File file;
  final DateTime dateTime;

  Document({required this.file, required this.dateTime});
}

class DocumentProvider with ChangeNotifier {
  bool isLoading = false;
  bool _isDataFetched = false;

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
          final docRef = storageRef.child(file.path.split('/').last);
          await docRef.putFile(file);
          _list.add(Document(file: file, dateTime: DateTime.now()));
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text("Error Occurred: ${e.toString()}")));
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAndSetDocuments() async {
    if (_isDataFetched) return;
    _list.clear();
    final storageRef =
        FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid);
    ListResult result = await storageRef.listAll();
    for (var item in result.items) {
      final metadata = await item.getMetadata();
      final uploadTime = metadata.timeCreated ?? DateTime.now();
      final downloadUrl = await item.getDownloadURL();
      final File file = await _downloadFile(downloadUrl, metadata.name);
      _list.add(Document(file: file, dateTime: uploadTime));
    }
    _isDataFetched = true;
  }

  Future<File> _downloadFile(String downloadUrl, String fileName) async {
    final url = Uri.parse(downloadUrl);
    final response = await http.get(url);
    final directory = await getTemporaryDirectory();
    final filePath = "${directory.path}/$fileName";
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void signOut() {
    _list.clear();
    _isDataFetched = false;
  }
}
