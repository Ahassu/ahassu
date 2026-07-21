import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/learning_path.dart';
import '../models/topic.dart';
import '../providers/providers.dart';

Future<void> showRenamePathDialog(BuildContext context, WidgetRef ref, LearningPath path) async {
  final titleController = TextEditingController(text: path.title);
  final examController = TextEditingController(text: path.examCode ?? '');
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Learning Path'),
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
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ),
  );
  if (result == true && titleController.text.trim().isNotEmpty) {
    await ref.read(firestoreServiceProvider).updateLearningPath(
          path.id,
          title: titleController.text.trim(),
          examCode: examController.text.trim().isEmpty ? null : examController.text.trim(),
        );
  }
}

/// Returns true if the path was deleted.
Future<bool> confirmDeleteLearningPath(BuildContext context, WidgetRef ref, LearningPath path) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Learning Path?'),
      content: Text('This removes "${path.title}" and all ${path.totalCount} of its topics. This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(firestoreServiceProvider).deleteLearningPath(path.id);
    return true;
  }
  return false;
}

Future<void> showAddTaskDialog(BuildContext context, WidgetRef ref, String pathId) async {
  final controller = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Task'),
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

Future<void> showRenameTaskDialog(BuildContext context, WidgetRef ref, String pathId, Topic topic) async {
  final controller = TextEditingController(text: topic.title);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Task'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Title')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ),
  );
  if (result == true && controller.text.trim().isNotEmpty) {
    await ref.read(firestoreServiceProvider).updateTopicTitle(pathId, topic.id, controller.text.trim());
  }
}

Future<void> confirmDeleteTask(BuildContext context, WidgetRef ref, String pathId, Topic topic) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Task?'),
      content: Text('Remove "${topic.title}" from this learning path?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(firestoreServiceProvider).deleteTopic(pathId, topic.id);
  }
}
