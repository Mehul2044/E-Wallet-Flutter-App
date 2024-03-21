import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';

import '../../provider/document_provider.dart';

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

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('d MMMM, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return "Uploaded on $formattedDate at $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    String fileName = documentObj.file.path.split('/').last;
    String extension = fileName.split('.').last;
    IconData iconData = _getIconForFileExtension(extension);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        onTap: () async {
          await OpenFile.open(documentObj.file.path);
        },
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: Icon(iconData),
        subtitle: Text(_formatDateTime(documentObj.dateTime)),
      ),
    );
  }
}
