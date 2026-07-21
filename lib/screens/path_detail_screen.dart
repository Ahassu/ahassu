import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/learning_path.dart';
import '../providers/providers.dart';
import '../theme.dart';
import 'notes_screen.dart';

class PathDetailScreen extends ConsumerWidget {
  final String pathId;

  const PathDetailScreen({super.key, required this.pathId});

  Future<void> _addSubtopic(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subtopic'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      await ref.read(firestoreServiceProvider).addTopic(pathId, controller.text.trim());
    }
  }

  Future<void> _editCertStatus(BuildContext context, WidgetRef ref, LearningPath path) async {
    var status = path.certStatus;
    var examDate = path.examDate;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Certification Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final s in CertStatus.values)
                RadioListTile<CertStatus>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(switch (s) {
                    CertStatus.notStarted => 'Not Started',
                    CertStatus.scheduled => 'Scheduled',
                    CertStatus.passed => 'Passed',
                  }),
                  value: s,
                  groupValue: status,
                  onChanged: (v) => setState(() => status = v!),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(examDate == null ? 'Set exam date' : DateFormat.yMMMd().format(examDate!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: examDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (picked != null) setState(() => examDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result == true) {
      await ref.read(firestoreServiceProvider).updateCertStatus(pathId, certStatus: status, examDate: examDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsAsync = ref.watch(learningPathsProvider);
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: pathsAsync.when(
        data: (paths) {
          final path = paths.firstWhere((p) => p.id == pathId, orElse: () => paths.first);
          final notes = notesAsync.value?.where((n) => n.learningPathId == pathId).toList() ?? [];

          Color certColor = switch (path.certStatus) {
            CertStatus.passed => kGreen,
            CertStatus.scheduled => kBlue,
            CertStatus.notStarted => Colors.black45,
          };
          String certLabel = switch (path.certStatus) {
            CertStatus.passed => 'Certified ✓',
            CertStatus.scheduled => 'Exam Scheduled',
            CertStatus.notStarted => 'Not Certified',
          };

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: kBackground,
                  pinned: true,
                  title: Text(path.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (path.examCode != null)
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.workspace_premium, color: certColor),
                            title: Text('${path.examCode} Certification'),
                            subtitle: Text(certLabel +
                                (path.examDate != null ? ' · ${DateFormat.yMMMd().format(path.examDate!)}' : '')),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _editCertStatus(context, ref, path),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Topics (${path.doneCount}/${path.totalCount})',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () => _addSubtopic(context, ref),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      Card(
                        child: Column(
                          children: [
                            for (final topic in path.topics)
                              CheckboxListTile(
                                value: topic.done,
                                title: Text(
                                  topic.title,
                                  style: TextStyle(
                                    decoration: topic.done ? TextDecoration.lineThrough : null,
                                    color: topic.done ? Colors.black45 : Colors.black87,
                                  ),
                                ),
                                onChanged: (v) => ref
                                    .read(firestoreServiceProvider)
                                    .toggleTopic(pathId, topic.id, v ?? false),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotesScreen(filterPathId: path.id, filterPathTitle: path.title),
                              ),
                            ),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('View all'),
                          ),
                        ],
                      ),
                      if (notes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('No notes yet for this topic.', style: TextStyle(color: Colors.black45)),
                        )
                      else
                        for (final note in notes.take(3))
                          Card(
                            margin: const EdgeInsets.only(top: 8),
                            child: ListTile(
                              title: Text(note.title),
                              subtitle: Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
