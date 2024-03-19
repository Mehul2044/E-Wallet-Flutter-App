import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../provider/note_provider.dart';

import '../notes/notes_detail_screen.dart';

import '../../widgets/notes/note_widget.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      floatingActionButton: noteProvider.list.isEmpty
          ? null
          : noteProvider.isLoading
              ? const CircularProgressIndicator()
              : FloatingActionButton(
                  onPressed: () => noteProvider.addNote(),
                  child: const Icon(Icons.add),
                ),
      body: noteProvider.list.isEmpty
          ? Center(
              child: noteProvider.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No Notes to Display"),
                        TextButton.icon(
                          onPressed: () => noteProvider.addNote(),
                          icon: const Icon(Icons.add),
                          label: const Text("Add a Note"),
                        ),
                      ],
                    ),
            )
          : ListView.builder(
              itemBuilder: (context, index) => Dismissible(
                    key: Key(noteProvider.list[index].noteId),
                    confirmDismiss: (_) => _confirmDismissDelete(context),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) => noteProvider
                        .deleteNote(noteProvider.list[index].noteId),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const NotesDetailScreen(),
                        settings:
                            RouteSettings(arguments: noteProvider.list[index]),
                      )),
                      child: NoteWidget(noteObj: noteProvider.list[index]),
                    ),
                  ),
              itemCount: noteProvider.list.length),
    );
  }

  Future<bool> _confirmDismissDelete(BuildContext context) async {
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
}
