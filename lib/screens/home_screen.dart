import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/goal_card.dart';
import '../widgets/path_tile.dart';
import '../widgets/stat_chip.dart';
import 'notes_screen.dart';
import 'path_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: examController,
              decoration: const InputDecoration(labelText: 'Exam code (optional)'),
            ),
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
    final goalAsync = ref.watch(goalProvider);
    final pathsAsync = ref.watch(learningPathsProvider);
    final progress = ref.watch(overallProgressProvider);
    final streak = ref.watch(studyStreakProvider);
    final todayTopics = ref.watch(todayCompletedTopicsProvider);
    final totalMinutes = ref.watch(totalMinutesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Hi Raja 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Stay consistent, achieve your MLOps goal.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          goalAsync.when(
            data: (goal) => GoalCard(
              title: goal.title,
              targetDate: goal.targetDate,
              doneTopics: progress.doneTopics,
              totalTopics: progress.totalTopics,
              fraction: progress.fraction,
              percent: progress.percent,
            ),
            loading: () => const Card(child: SizedBox(height: 140, child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Error loading goal: $e'))),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Study Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _addLearningPath(context, ref),
                icon: const Icon(Icons.add_circle_outline, size: 18, color: kPrimaryPurple),
                label: const Text('Add Topic', style: TextStyle(color: kPrimaryPurple)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          pathsAsync.when(
            data: (paths) => Column(
              children: [
                for (final path in paths)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PathTile(
                      path: path,
                      index: path.order,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PathDetailScreen(pathId: path.id)),
                      ),
                      onNotesTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotesScreen(filterPathId: path.id, filterPathTitle: path.title)),
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatChip(
                    icon: Icons.local_fire_department,
                    iconColor: Colors.redAccent,
                    label: 'Study Streak',
                    value: '$streak days',
                  ),
                  StatChip(
                    icon: Icons.menu_book,
                    iconColor: Colors.orange,
                    label: "Today's Goal",
                    value: '$todayTopics / ${goalAsync.value?.dailyTopicGoal ?? 3} topics',
                  ),
                  StatChip(
                    icon: Icons.access_time_filled,
                    iconColor: kBlue,
                    label: 'Study Time',
                    value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
