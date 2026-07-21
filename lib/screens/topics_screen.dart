import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';
import '../utils/path_dialogs.dart';
import 'note_editor_screen.dart';
import 'path_detail_screen.dart';
import 'quiz_screen.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  Future<void> _addLearningPath(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final examController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Learning Path'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: examController, decoration: const InputDecoration(labelText: 'Exam code (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (result == true && titleController.text.trim().isNotEmpty) {
      await ref.read(firestoreServiceProvider).addLearningPath(
            titleController.text.trim(),
            examCode: examController.text.trim().isEmpty ? null : examController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsAsync = ref.watch(learningPathsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Topics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _addLearningPath(context, ref),
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: kPrimaryPurple),
                  label: const Text('Add Path', style: TextStyle(color: kPrimaryPurple)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Your full Azure MLOps curriculum, fundamentals to expert.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Expanded(
              child: pathsAsync.when(
                data: (paths) => ListView.separated(
                  itemCount: paths.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final path = paths[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        title: Text('${path.order}. ${path.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${path.doneCount}/${path.totalCount} studied'
                          '${path.examCode != null ? ' · ${path.examCode}' : ''}'
                          '${path.certStatus.name == 'passed' ? ' · Certified ✓' : ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 18, color: kPrimaryPurple),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PathDetailScreen(pathId: path.id)),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: Colors.black45),
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  await showRenamePathDialog(context, ref, path);
                                } else if (action == 'delete') {
                                  await confirmDeleteLearningPath(context, ref, path);
                                }
                              },
                              itemBuilder: (ctx) => const [
                                PopupMenuItem(value: 'edit', child: Text('Rename')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          for (final topic in path.topics)
                            CheckboxListTile(
                              value: topic.done,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                topic.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: topic.done ? TextDecoration.lineThrough : null,
                                  color: topic.done ? Colors.black45 : Colors.black87,
                                ),
                              ),
                              secondary: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18, color: Colors.black38),
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    showRenameTaskDialog(context, ref, path.id, topic);
                                  } else if (action == 'delete') {
                                    confirmDeleteTask(context, ref, path.id, topic);
                                  }
                                },
                                itemBuilder: (ctx) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                              onChanged: (v) => ref
                                  .read(firestoreServiceProvider)
                                  .toggleTopic(path.id, topic.id, v ?? false),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                TextButton.icon(
                                  onPressed: () => showAddTaskDialog(context, ref, path.id),
                                  icon: const Icon(Icons.add_task, size: 16),
                                  label: const Text('Add Task'),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoteEditorScreen(prefillPathId: path.id, prefillPathTitle: path.title),
                                    ),
                                  ),
                                  icon: const Icon(Icons.note_add_outlined, size: 16),
                                  label: const Text('Add Note'),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(pathId: path.id, pathTitle: path.title),
                                    ),
                                  ),
                                  icon: const Icon(Icons.quiz_outlined, size: 16),
                                  label: const Text('Quiz'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
