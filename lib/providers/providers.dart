import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../models/study_area.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final studyAreasProvider = StreamProvider<List<StudyArea>>((ref) {
  return ref.watch(firestoreServiceProvider).watchStudyAreas();
});

final notesProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(firestoreServiceProvider).watchNotes();
});

/// Readiness across the whole plan — the number on the Plan screen header.
class Readiness {
  final int done;
  final int total;

  const Readiness({required this.done, required this.total});

  double get fraction => total == 0 ? 0 : done / total;
  int get percent => (fraction * 100).round();
  int get remaining => total - done;
}

final readinessProvider = Provider<Readiness>((ref) {
  final areas = ref.watch(studyAreasProvider).value ?? [];
  return Readiness(
    done: areas.fold<int>(0, (acc, a) => acc + a.doneCount),
    total: areas.fold<int>(0, (acc, a) => acc + a.totalCount),
  );
});

/// Readiness limited to the areas the posting leans on hardest. Prep time
/// should follow this number rather than the overall one — finishing the
/// support areas while Terraform is untouched is not progress.
final criticalReadinessProvider = Provider<Readiness>((ref) {
  final areas = (ref.watch(studyAreasProvider).value ?? [])
      .where((a) => a.weight == AreaWeight.critical);
  return Readiness(
    done: areas.fold<int>(0, (acc, a) => acc + a.doneCount),
    total: areas.fold<int>(0, (acc, a) => acc + a.totalCount),
  );
});

/// The next unfinished subtopic, weightiest area first — powers "what should
/// I study now" so opening the app never needs a decision.
final nextUpProvider = Provider<(StudyArea, StudySubtopic)?>((ref) {
  final areas = ref.watch(studyAreasProvider).value ?? [];
  for (final area in areas) {
    for (final sub in area.subtopics) {
      if (!sub.done) return (area, sub);
    }
  }
  return null;
});
