import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../provider/document_provider.dart';

enum Options { rename, download }

class DocumentWidget extends StatelessWidget {
  final Document documentObj;

  const DocumentWidget({super.key, required this.documentObj});


  IconData _getIconForFileExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _saveFile(String downloadUrl) {}

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('d MMMM, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return "Uploaded on $formattedDate at $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    String fileName = documentObj.fileName;
    String extension = fileName.split('.').last;
    IconData iconData = _getIconForFileExtension(extension);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        onTap: () async {},
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: Icon(iconData),
        subtitle: Text(
          _formatDateTime(documentObj.dateTime),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: PopupMenuButton(
          onSelected: (Options selectedValue) async {
            if (selectedValue == Options.download) {
              _saveFile(documentObj.downloadUrl);
            } else if (selectedValue == Options.rename) {}
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: Options.rename,
              child: Row(
                children: [
                  Icon(Icons.drive_file_rename_outline),
                  SizedBox(width: 10),
                  Text("Rename File"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: Options.download,
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 10),
                  Text("Download"),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
