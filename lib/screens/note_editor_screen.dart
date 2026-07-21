import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';
import '../providers/providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? existing;
  final String? prefillPathId;
  final String? prefillPathTitle;

  const NoteEditorScreen({super.key, this.existing, this.prefillPathId, this.prefillPathTitle});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _body = TextEditingController(text: widget.existing?.body ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty && _body.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final now = DateTime.now();
    final note = Note(
      id: widget.existing?.id ?? 'note_${const Uuid().v4()}',
      title: _title.text.trim().isEmpty ? 'Untitled note' : _title.text.trim(),
      body: _body.text.trim(),
      learningPathId: widget.existing?.learningPathId ?? widget.prefillPathId,
      learningPathTitle: widget.existing?.learningPathTitle ?? widget.prefillPathTitle,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(firestoreServiceProvider).upsertNote(note);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pathTitle = widget.existing?.learningPathTitle ?? widget.prefillPathTitle;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pathTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Chip(label: Text(pathTitle)),
              ),
            TextField(
              controller: _title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(hintText: 'Write what you studied...', border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
