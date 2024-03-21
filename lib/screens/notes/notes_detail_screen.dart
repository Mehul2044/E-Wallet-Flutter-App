import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/note_provider.dart';

import '../../widgets/notes/input_area_widget.dart';

class NotesDetailScreen extends StatelessWidget {
  const NotesDetailScreen({super.key});

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('d MMMM, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return "Created on $formattedDate at $formattedTime";
  }

  Future<bool> _confirmDeleteHandler(BuildContext context) async {
    late bool returnValue;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Confirm Delete"),
              content: const Text("Are you sure you want to delete the note?"),
              actions: [
                TextButton(
                  onPressed: () {
                    returnValue = true;
                    Navigator.of(context).pop();
                  },
                  child: const Text("Yes, delete"),
                ),
                TextButton(
                    onPressed: () {
                      returnValue = false;
                      Navigator.of(context).pop();
                    },
                    child: const Text("No")),
              ],
            ));
    return returnValue;
  }

  String? availableText(Note obj) {
    String? text;
    if ((obj.body.isEmpty) && (obj.title.isEmpty)) {
      return text;
    } else if (obj.body.isEmpty) {
      text = obj.title;
    } else if (obj.title.isEmpty) {
      text = obj.body;
    } else {
      text = "${obj.title}\n\n${obj.body}";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final Note obj = ModalRoute.of(context)!.settings.arguments as Note;
    return Scaffold(
      appBar: AppBar(),
      bottomSheet: BottomAppBar(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                if (await _confirmDeleteHandler(context)) {
                  navigator.pop();
                  noteProvider.deleteNote(obj.noteId);
                }
              },
              icon: const Icon(Icons.delete, size: 25),
              tooltip: "Delete",
            ),
            const SizedBox(width: 30),
            IconButton(
              onPressed: () async {
                String? textToCopy = availableText(obj);
                if (textToCopy == null) {
                  Fluttertoast.showToast(msg: "Empty Note. Nothing to copy!");
                  return;
                }
                await Clipboard.setData(ClipboardData(text: textToCopy));
                Fluttertoast.showToast(msg: "Note copied to Clipboard");
              },
              icon: const Icon(Icons.copy, size: 25),
              tooltip: "Copy",
            ),
            IconButton(
              onPressed: () {
                String? textToShare = availableText(obj);
                if (textToShare == null) {
                  Fluttertoast.showToast(msg: "Empty Note. Nothing to share!");
                }
                Share.share(textToShare!,
                    subject:
                        "Note from ${FirebaseAuth.instance.currentUser!.displayName}");
              },
              icon: const Icon(Icons.share),
              tooltip: "Share",
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputArea(
                isTitle: true,
                noteObj: obj,
                initialText: obj.title,
                updateFunction: noteProvider.updateNote,
              ),
              Text(
                _formatDateTime(obj.dateTime),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 20),
              const Divider(),
              InputArea(
                isTitle: false,
                noteObj: obj,
                initialText: obj.body,
                updateFunction: noteProvider.updateNote,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
