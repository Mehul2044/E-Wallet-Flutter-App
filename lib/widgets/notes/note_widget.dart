import 'package:flutter/material.dart';

import '../../provider/note_provider.dart';

class NoteWidget extends StatelessWidget {
  final Note noteObj;

  const NoteWidget({super.key, required this.noteObj});

  @override
  Widget build(BuildContext context) {
    final hasTitle = noteObj.title.isNotEmpty;
    final hasBody = noteObj.body.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: !hasTitle && !hasBody
          ? Center(
              heightFactor: 1,
              child: Text(
                "EMPTY NOTE\nTap to Edit or Swipe to Discard",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  Column(
                    children: [
                      Text(
                        noteObj.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (hasBody) const SizedBox(height: 20),
                    ],
                  ),
                if (hasBody)
                  Text(
                    noteObj.body,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 6,
                  ),
              ],
            ),
    );
  }
}
