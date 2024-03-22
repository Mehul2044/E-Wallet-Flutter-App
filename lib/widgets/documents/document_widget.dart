import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<bool> _saveFile(File file, String fileName) async {
    final permission =
        await Permission.storage.request().isGranted;
    if (permission) {
      String newPath = '';
      Directory storageDir = (await getExternalStorageDirectory())!;
      List<String> folders = storageDir.path.split("/");
      for (int x = 1; x < folders.length; x++) {
        String folder = folders[x];
        if (folder != 'Android') {
          newPath += '/$folder';
        } else {
          break;
        }
      }
      newPath = "$newPath/Documents";
      await Directory(newPath).create();
      await file.copy("$newPath/$fileName");
      return true;
    } else {
      return false;
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
        subtitle: Text(
          _formatDateTime(documentObj.dateTime),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: PopupMenuButton(
          onSelected: (Options selectedValue) async {
            if (selectedValue == Options.download) {
              final result = await _saveFile(documentObj.file, fileName);
              if (result) {
                Fluttertoast.showToast(msg: "File was saved in Documents.");
              } else {
                Fluttertoast.showToast(msg: "Permission Denied for saving File. Grant permission in the App Settings.");
              }
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
