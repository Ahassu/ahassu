import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../models/learning_path.dart';
import '../models/note.dart';
import '../models/study_session.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final learningPathsProvider = StreamProvider<List<LearningPath>>((ref) {
  return ref.watch(firestoreServiceProvider).watchLearningPaths();
});

final notesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(firestoreServiceProvider).watchNotes();
});

final studySessionsProvider = StreamProvider<List<StudySession>>((ref) {
  return ref.watch(firestoreServiceProvider).watchStudySessions();
});

final goalProvider = StreamProvider<Goal>((ref) {
  return ref.watch(firestoreServiceProvider).watchGoal();
});

class ProgressStats {
  final int doneTopics;
  final int totalTopics;
  double get fraction => totalTopics == 0 ? 0 : doneTopics / totalTopics;
  int get percent => (fraction * 100).round();

  const ProgressStats({required this.doneTopics, required this.totalTopics});
}

final overallProgressProvider = Provider<ProgressStats>((ref) {
  final paths = ref.watch(learningPathsProvider).value ?? [];
  final done = paths.fold<int>(0, (acc, p) => acc + p.doneCount);
  final total = paths.fold<int>(0, (acc, p) => acc + p.totalCount);
  return ProgressStats(doneTopics: done, totalTopics: total);
});

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

final studyStreakProvider = Provider<int>((ref) {
  final sessions = ref.watch(studySessionsProvider).value ?? [];
  if (sessions.isEmpty) return 0;

  final days = sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet();
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);

  var cursor = todayOnly;
  if (!days.contains(cursor)) {
    // Allow the streak to still show if today hasn't been logged yet,
    // as long as yesterday was studied.
    final yesterday = cursor.subtract(const Duration(days: 1));
    if (!days.contains(yesterday)) return 0;
    cursor = yesterday;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

final todayMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(studySessionsProvider).value ?? [];
  final today = DateTime.now();
  return sessions
      .where((s) => _isSameDay(s.date, today))
      .fold<int>(0, (acc, s) => acc + s.minutes);
});

final totalMinutesProvider = Provider<int>((ref) {
  final sessions = ref.watch(studySessionsProvider).value ?? [];
  return sessions.fold<int>(0, (acc, s) => acc + s.minutes);
});

final todayCompletedTopicsProvider = Provider<int>((ref) {
  final paths = ref.watch(learningPathsProvider).value ?? [];
  final today = DateTime.now();
  var count = 0;
  for (final path in paths) {
    for (final topic in path.topics) {
      if (topic.done && topic.completedAt != null && _isSameDay(topic.completedAt!, today)) {
        count += 1;
      }
    }
  }
  return count;
});
