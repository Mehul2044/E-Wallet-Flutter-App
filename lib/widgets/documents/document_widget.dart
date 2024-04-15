import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../provider/document_provider.dart';

enum Options { download, delete }

class DocumentWidget extends StatefulWidget {
  final Document documentObj;

  const DocumentWidget({super.key, required this.documentObj});

  @override
  State<DocumentWidget> createState() => _DocumentWidgetState();
}

class _DocumentWidgetState extends State<DocumentWidget> {
  bool _isLoading = false;

  IconData _getIconForFileExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
      case 'mkv':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _saveFile(String downloadUrl, String name) {
    Fluttertoast.showToast(
      msg: "Download Started!",
    );
    FileDownloader.downloadFile(
        url: downloadUrl,
        name: name,
        onDownloadError: (String error) => Fluttertoast.showToast(msg: error),
        onDownloadCompleted: (String error) =>
            Fluttertoast.showToast(msg: "Download Completed"));
  }

  void _openFile(String downloadUrl, String fileName) async {
    setState(() => _isLoading = true);
    final response = await http.get(Uri.parse(downloadUrl));
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/$fileName';
    final file = File(tempPath);
    await file.writeAsBytes(response.bodyBytes);
    await OpenFile.open(file.path);
    setState(() => _isLoading = false);
  }

  String _formatDateTime(DateTime dateTime) {
    String formattedDate = DateFormat('d MMMM, y').format(dateTime);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return "Uploaded on $formattedDate at $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);

    String fileName = widget.documentObj.fileName;
    String extension = fileName.split('.').last;
    IconData iconData = _getIconForFileExtension(extension);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        onTap: _isLoading
            ? null
            : () {
                Fluttertoast.showToast(msg: "Opening...");
                _openFile(widget.documentObj.downloadUrl,
                    widget.documentObj.fileName);
              },
        title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading:
            _isLoading ? const CircularProgressIndicator() : Icon(iconData),
        subtitle: Text(
          _formatDateTime(widget.documentObj.dateTime),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: PopupMenuButton(
          onSelected: (Options selectedValue) async {
            if (selectedValue == Options.download) {
              _saveFile(
                  widget.documentObj.downloadUrl, widget.documentObj.fileName);
            } else if (selectedValue == Options.delete) {
              await documentProvider.deleteFile(fileName);
            }
          },
          itemBuilder: (_) => [
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
            const PopupMenuItem(
              value: Options.delete,
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 10),
                  Text("Delete"),
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
