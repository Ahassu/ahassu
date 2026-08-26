import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/study_plan_seed.dart';
import '../models/note.dart';
import '../models/study_area.dart';

/// Bumped whenever the seed content changes in a way that has to reach a
/// device that already seeded.
///
/// Version 1 was the Azure MLOps curriculum, version 2 the Azure Platform
/// Engineer certification track. Version 3 replaced both with the interview
/// study plan for one specific posting — the certification learning paths,
/// roadmaps and quizzes are gone, and their collections are retired below.
/// Version 4 cut each card down to a question and an answer, dropping the
/// breakdown table and the hint line.
const _seedVersion = 4;

/// Collections the certification tracker used. They are deleted once, on the
/// upgrade to version 3, so the old curriculum does not linger in Firestore
/// behind an app that no longer reads it.
const _retiredCollections = ['learningPaths', 'roadmaps', 'quizQuestions', 'studySessions', 'goal'];

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  CollectionReference<Map<String, dynamic>> get _areas => _db.collection('studyAreas');

  CollectionReference<Map<String, dynamic>> get _notes => _db.collection('notes');

  DocumentReference<Map<String, dynamic>> get _seedMetaDoc => _db.collection('meta').doc('seed');

  // ---- Seeding ----

  /// Brings an existing install up to the current [_seedVersion], and seeds a
  /// fresh one. Cheap to call on every launch: it reads one document and
  /// returns immediately when the version already matches.
  Future<void> syncSeedData() async {
    final meta = await _seedMetaDoc.get();
    final version = meta.data()?['version'] as int? ?? 0;
    if (version >= _seedVersion) return;

    await _syncStudyPlan();
    if (version < 3) await _dropRetiredCollections();

    await _seedMetaDoc.set({
      'version': _seedVersion,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Upserts every area in the seed, preserving whatever the user has already
  /// ticked, and deletes areas that are no longer in the plan.
  Future<void> _syncStudyPlan() async {
    final existing = await _areas.get();
    final prior = {
      for (final doc in existing.docs) doc.id: StudyArea.fromFirestore(doc.id, doc.data())
    };

    final seed = buildStudyPlan();
    final seedIds = seed.map((a) => a.id).toSet();
    final batch = _db.batch();

    for (final area in seed) {
      batch.set(_areas.doc(area.id), _withPreservedProgress(area, prior[area.id]).toMap());
    }
    for (final doc in existing.docs) {
      if (!seedIds.contains(doc.id)) batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Content always comes from the seed; only the tick and its timestamp come
  /// from what was already stored. Matching is by subtopic id, so rewording a
  /// title or reordering the list never loses progress.
  StudyArea _withPreservedProgress(StudyArea seed, StudyArea? prior) {
    if (prior == null) return seed;
    final done = {
      for (final s in prior.subtopics)
        if (s.done) s.id: s.completedAt,
    };
    return seed.copyWith(
      subtopics: seed.subtopics
          .map((s) => done.containsKey(s.id)
              ? s.copyWith(done: true, completedAt: done[s.id])
              : s)
          .toList(),
    );
  }

  /// One-time cleanup of the certification tracker's collections. Firestore
  /// has no server-side "drop collection", so this pages through each one.
  /// Failures are swallowed per collection — a leftover document is untidy,
  /// not a reason to block the app from starting.
  Future<void> _dropRetiredCollections() async {
    for (final name in _retiredCollections) {
      try {
        while (true) {
          final page = await _db.collection(name).limit(400).get();
          if (page.docs.isEmpty) break;
          final batch = _db.batch();
          for (final doc in page.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          if (page.docs.length < 400) break;
        }
      } catch (_) {
        // Collection may not exist, or rules may deny it. Neither is fatal.
      }
    }
  }

  // ---- Study plan ----

  Stream<List<StudyArea>> watchStudyAreas() {
    return _areas.orderBy('order').snapshots().map((snap) =>
        snap.docs.map((d) => StudyArea.fromFirestore(d.id, d.data())).toList());
  }

  /// Ticks or unticks one subtopic. Rewrites the area's subtopic array
  /// because Firestore cannot update a single element of an array in place.
  Future<void> setSubtopicDone(StudyArea area, String subtopicId, bool done) async {
    final updated = area.subtopics
        .map((s) => s.id == subtopicId
            ? s.copyWith(
                done: done,
                completedAt: done ? DateTime.now() : null,
                clearCompletedAt: !done,
              )
            : s)
        .toList();
    await _areas.doc(area.id).update({
      'subtopics': updated.map((s) => s.toMap()).toList(),
    });
  }

  // ---- Notes ----

  Stream<List<Note>> watchNotes() {
    return _notes.orderBy('updatedAt', descending: true).snapshots().map(
        (snap) => snap.docs.map((d) => Note.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> upsertNote(Note note) async {
    await _notes.doc(note.id).set(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await _notes.doc(id).delete();
  }
}
