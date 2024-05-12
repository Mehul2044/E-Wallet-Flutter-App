import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class Document {
  final String id;
  final String fileName;
  final DateTime dateTime;
  final String downloadUrl;

  Document(
      {required this.downloadUrl,
      required this.fileName,
      required this.dateTime,
      required this.id});
}

class DocumentProvider with ChangeNotifier {
  bool isLoading = false;
  bool isDataFetched = false;

  final List<Document> _list = [];

  List<Document> get list => [..._list];

  Future<void> uploadFile(File file) async {
    final storageRef =
        FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid);
    DatabaseReference databaseRef = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/documents");
    final creationTime = DateTime.now();
    DatabaseReference databaseDocumentRef = databaseRef.push();
    String documentId = databaseDocumentRef.key!;
    final fileName = file.path.split('/').last;
    final storageFileRef = storageRef.child(documentId);
    await storageFileRef.putFile(file);
    String downloadUrl = await storageFileRef.getDownloadURL();
    await databaseDocumentRef.set({
      "fileName": fileName,
      "dateTime": creationTime.toIso8601String(),
      "downloadUrl": downloadUrl
    });
    _list.add(Document(
        downloadUrl: downloadUrl,
        fileName: fileName,
        dateTime: creationTime,
        id: documentId));
  }

  Future<void> addFromLocal(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: true, allowCompression: false);
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        int index = 0;
        for (File file in files) {
          Fluttertoast.showToast(
              msg: "Uploading File ${index + 1}/${files.length}...");
          await uploadFile(file);
          index++;
        }
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text("An Error occurred!"),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> scanDocument(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      DocumentScannerOptions documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.pdf,
        mode: ScannerMode.filter,
        pageLimit: 100,
        isGalleryImport: true,
      );
      final documentScanner = DocumentScanner(options: documentOptions);
      DocumentScanningResult result = await documentScanner.scanDocument();
      final pdf = result.pdf;
      if (pdf != null) {
        await uploadFile(File(pdf.uri));
      } else {
        throw Exception();
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text("Error: File not Found. Please retry!!"),
      ));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> renameFile(String documentId, String fileName) async {
    int index = _list.indexWhere((element) => element.id == documentId);
    final document = _list[index];
    DatabaseReference databaseRef = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/documents");
    String extension = document.fileName.split(".").last;
    String newName = "$fileName.$extension";
    await databaseRef.child(documentId).update({"fileName": newName});
    _list[index] = Document(
        id: documentId,
        dateTime: document.dateTime,
        fileName: newName,
        downloadUrl: document.downloadUrl);
    notifyListeners();
  }

  Future<void> deleteFile(String documentId) async {
    print(documentId);
    _list.removeWhere((element) => element.id == documentId);
    notifyListeners();
    final storageRef =
        FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid);
    final storageFileRef = storageRef.child(documentId);
    await storageFileRef.delete();
    DatabaseReference databaseRef = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/documents");
    await databaseRef.child(documentId).remove();
  }

  Future<void> fetchAndSetDocuments() async {
    _list.clear();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/documents");
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> documentsMap =
          snapshot.value as Map<dynamic, dynamic>;
      for (var entry in documentsMap.entries) {
        var key = entry.key;
        var value = entry.value;
        _list.add(Document(
            id: key,
            dateTime: DateTime.parse(value['dateTime']),
            fileName: value['fileName'],
            downloadUrl: value['downloadUrl']));
      }
    }
    isDataFetched = true;
  }

  void signOut() {
    _list.clear();
    isDataFetched = false;
  }
}
