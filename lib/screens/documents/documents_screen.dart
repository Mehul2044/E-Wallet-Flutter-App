import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../provider/document_provider.dart';

import '../../widgets/documents/document_widget.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  Future<void> _addFilesHandler(
      DocumentProvider documentProvider, BuildContext context) async {
    await documentProvider.addFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);

    return FutureBuilder(
      future: documentProvider.isDataFetched
          ? null
          : documentProvider.fetchAndSetDocuments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          return Consumer<DocumentProvider>(
            builder: (context, provider, _) => Scaffold(
              floatingActionButton: documentProvider.list.isEmpty
                  ? null
                  : provider.isLoading
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: () =>
                              _addFilesHandler(documentProvider, context),
                          child: const Icon(Icons.add),
                        ),
              body: documentProvider.list.isEmpty
                  ? Center(
                      child: documentProvider.isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("No Documents to Display"),
                                TextButton.icon(
                                  onPressed: () => _addFilesHandler(
                                      documentProvider, context),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add new Document"),
                                ),
                              ],
                            ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) => Dismissible(
                        key: Key(provider.list[index].fileName),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (_) => _confirmDismissDelete(context),
                        onDismissed: (_) =>
                            provider.deleteFile(provider.list[index].fileName),
                        child:
                            DocumentWidget(documentObj: provider.list[index]),
                      ),
                      itemCount: provider.list.length,
                    ),
            ),
          );
        }
      },
    );
  }

  Future<bool> _confirmDismissDelete(BuildContext context) async {
    late bool returnValue;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog.adaptive(
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
