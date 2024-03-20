import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'encrypt_provider.dart';

class Note {
  final String noteId;
  final DateTime dateTime;
  final String title;
  final String body;

  Note(
      {required this.noteId,
      required this.dateTime,
      required this.title,
      required this.body});
}

class NoteProvider with ChangeNotifier {
  bool _isDataLoaded = false;
  bool isLoading = false;
  List<Note> _list = [];

  List<Note> get list => [..._list];

  Future<void> addNote() async {
    isLoading = true;
    notifyListeners();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/notes");
    final creationTime = DateTime.now();
    DatabaseReference noteRef = ref.push();
    String noteId = noteRef.key!;
    await noteRef.set(
        {"dateTime": creationTime.toIso8601String(), "title": "", "body": ""});
    _list
        .add(Note(noteId: noteId, dateTime: creationTime, title: "", body: ""));
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    _list.removeWhere((element) => element.noteId == noteId);
    notifyListeners();
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/notes/$noteId");
    await ref.remove();
  }

  Future<void> updateNote(String updatedText, String noteId, bool isTitle,
      EncryptProvider encryptProvider) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/notes/$noteId");
    int index = _list.indexWhere((element) => element.noteId == noteId);
    final noteObj = _list[index];
    final newNoteObj = Note(
      noteId: noteObj.noteId,
      dateTime: noteObj.dateTime,
      title: isTitle ? updatedText : noteObj.title,
      body: !isTitle ? updatedText : noteObj.body,
    );
    _list[index] = newNoteObj;
    notifyListeners();
    String newText = await encryptProvider.encrypt(updatedText);
    await ref.update({isTitle ? "title" : "body": newText});
  }

  Future<void> fetchAndSetNotes(EncryptProvider encryptProvider) async {
    if (_isDataLoaded) return;
    _list.clear();
    final List<Note> notes = [];
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("${FirebaseAuth.instance.currentUser!.uid}/notes");
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> notesMap = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in notesMap.entries) {
        var key = entry.key;
        var value = entry.value;
        final decryptedTitle = value['title'].isEmpty
            ? ""
            : await encryptProvider.decrypt(value['title']);
        final decryptedBody = value['body'].isEmpty
            ? ""
            : await encryptProvider.decrypt(value['body']);
        notes.add(Note(
          noteId: key,
          dateTime: DateTime.parse(value['dateTime']),
          title: decryptedTitle,
          body: decryptedBody,
        ));
      }
    }
    _list = notes;
    _isDataLoaded = true;
  }

  void signOut() {
    _list.clear();
    _isDataLoaded = false;
  }
}
