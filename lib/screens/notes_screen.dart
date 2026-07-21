import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../theme.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  final String? filterPathId;
  final String? filterPathTitle;

  const NotesScreen({super.key, this.filterPathId, this.filterPathTitle});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final isFiltered = widget.filterPathId != null;

    return Scaffold(
      appBar: isFiltered
          ? AppBar(title: Text('Notes · ${widget.filterPathTitle}'))
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isFiltered) ...[
                const Text('Notes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    var filtered = notes;
                    if (isFiltered) {
                      filtered = filtered.where((n) => n.learningPathId == widget.filterPathId).toList();
                    }
                    if (_query.isNotEmpty) {
                      filtered = filtered
                          .where((n) => n.title.toLowerCase().contains(_query) || n.body.toLowerCase().contains(_query))
                          .toList();
                    }
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No notes yet. Tap + to add one.', style: TextStyle(color: Colors.black45)));
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final note = filtered[i];
                        return Card(
                          child: ListTile(
                            title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (note.body.isNotEmpty)
                                  Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(DateFormat.yMMMd().add_jm().format(note.updatedAt),
                                    style: const TextStyle(fontSize: 11, color: Colors.black38)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.black38),
                              onPressed: () => ref.read(firestoreServiceProvider).deleteNote(note.id),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NoteEditorScreen(existing: note)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        backgroundColor: kPrimaryPurple,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(
              prefillPathId: widget.filterPathId,
              prefillPathTitle: widget.filterPathTitle,
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
