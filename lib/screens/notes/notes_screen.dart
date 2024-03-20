import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/note_provider.dart';

import '../notes/notes_detail_screen.dart';

import '../../widgets/notes/note_widget.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final encryptProvider =
        Provider.of<EncryptProvider>(context, listen: false);

    return FutureBuilder(
      future: noteProvider.fetchAndSetNotes(encryptProvider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return Consumer<NoteProvider>(
          builder: (context, provider, _) => Scaffold(
            floatingActionButton: provider.list.isEmpty
                ? null
                : provider.isLoading
                    ? const CircularProgressIndicator()
                    : FloatingActionButton(
                        onPressed: () => provider.addNote(),
                        child: const Icon(Icons.add),
                      ),
            body: provider.list.isEmpty
                ? Center(
                    child: provider.isLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("No Notes to Display"),
                              TextButton.icon(
                                onPressed: () => provider.addNote(),
                                icon: const Icon(Icons.add),
                                label: const Text("Add a Note"),
                              ),
                            ],
                          ),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) => Dismissible(
                          key: Key(provider.list[index].noteId),
                          confirmDismiss: (_) => _confirmDismissDelete(context),
                          direction: DismissDirection.horizontal,
                          onDismissed: (_) =>
                              provider.deleteNote(provider.list[index].noteId),
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const NotesDetailScreen(),
                              settings: RouteSettings(
                                  arguments: provider.list[index]),
                            )),
                            child: NoteWidget(noteObj: provider.list[index]),
                          ),
                        ),
                    itemCount: provider.list.length),
          ),
        );
      },
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
