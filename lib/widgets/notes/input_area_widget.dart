import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/encrypt_provider.dart';
import '../../provider/note_provider.dart';

class InputArea extends StatefulWidget {
  final bool isTitle;
  final Note noteObj;
  final String initialText;
  final Function updateFunction;

  const InputArea({
    super.key,
    required this.initialText,
    required this.noteObj,
    required this.isTitle,
    required this.updateFunction,
  });

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    textEditingController.text = widget.initialText;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditingController.dispose();
    super.dispose();
  }

  void _updateNote(String? value) {
    widget.updateFunction(value ?? "", widget.noteObj.noteId, widget.isTitle,
        Provider.of<EncryptProvider>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: widget.isTitle ? "Add Title" : "Add Body",
      ),
      maxLines: widget.isTitle ? 2 : null,
      style: widget.isTitle
          ? Theme.of(context).textTheme.titleLarge
          : Theme.of(context).textTheme.bodyMedium,
      onChanged: _updateNote,
    );
  }
}
