import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
/// breakdown table and the hint line. Version 5 gave cards stable ids so the
/// user can edit and delete them without a later sync undoing the change.
const _seedVersion = 5;

/// Collections the certification tracker used. They are deleted once, on the
/// upgrade to version 3, so the old curriculum does not linger in Firestore
/// behind an app that no longer reads it.
const _retiredCollections = [
  'learningPaths',
  'roadmaps',
  'quizQuestions',
  'studySessions',
  'goal',
];

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  CollectionReference<Map<String, dynamic>> get _areas =>
      _db.collection('studyAreas');

  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('notes');

  DocumentReference<Map<String, dynamic>> get _seedMetaDoc =>
      _db.collection('meta').doc('seed');

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
      for (final doc in existing.docs)
        doc.id: StudyArea.fromFirestore(doc.id, doc.data()),
    };

    final seed = buildStudyPlan();
    final seedIds = seed.map((a) => a.id).toSet();
    final batch = _db.batch();

    for (final area in seed) {
      batch.set(
        _areas.doc(area.id),
        mergeUserState(area, prior[area.id]).toMap(),
      );
    }
    for (final doc in existing.docs) {
      if (!seedIds.contains(doc.id)) batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Content comes from the seed, but anything the user did to it wins.
  ///
  /// Three things are carried across a sync: the tick on a subtopic, any card
  /// the user rewrote (`edited`), and any card they deleted (`deleted`, kept
  /// as a tombstone so the seed cannot resurrect it). Cards the user added
  /// themselves have ids the seed does not know about, so they are appended
  /// rather than matched. Everything else is replaced by the seed, which is
  /// what lets new content reach a device that already seeded.
  @visibleForTesting
  static StudyArea mergeUserState(StudyArea seed, StudyArea? prior) {
    if (prior == null) return seed;
    final priorSubs = {for (final s in prior.subtopics) s.id: s};

    return seed.copyWith(
      subtopics: seed.subtopics.map((seedSub) {
        final old = priorSubs[seedSub.id];
        if (old == null) return seedSub;

        final oldCards = {for (final c in old.cards) c.id: c};
        final seedIds = seedSub.cards.map((c) => c.id).toSet();

        final merged = <StudyCard>[
          for (final card in seedSub.cards)
            if (oldCards[card.id] case final kept?
                when kept.edited || kept.deleted)
              kept
            else
              card,
          // Cards the user wrote themselves, which the seed knows nothing of.
          for (final card in old.cards)
            if (!seedIds.contains(card.id)) card,
        ];

        return seedSub.copyWith(
          done: old.done,
          completedAt: old.completedAt,
          clearCompletedAt: !old.done,
          cards: merged,
        );
      }).toList(),
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
    return _areas
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => StudyArea.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  /// Ticks or unticks one subtopic. Rewrites the area's subtopic array
  /// because Firestore cannot update a single element of an array in place.
  Future<void> setSubtopicDone(
    StudyArea area,
    String subtopicId,
    bool done,
  ) async {
    final updated = area.subtopics
        .map(
          (s) => s.id == subtopicId
              ? s.copyWith(
                  done: done,
                  completedAt: done ? DateTime.now() : null,
                  clearCompletedAt: !done,
                )
              : s,
        )
        .toList();
    await _areas.doc(area.id).update({
      'subtopics': updated.map((s) => s.toMap()).toList(),
    });
  }

  /// Saves one card's text. A seeded card is marked `edited` on the way in,
  /// which is what stops the next seed sync overwriting the user's wording.
  Future<void> saveCard(
    StudyArea area,
    String subtopicId,
    StudyCard card, {
    required String question,
    required String answer,
  }) async {
    await _writeCards(area, subtopicId, (cards) {
      return cards
          .map(
            (c) => c.id == card.id
                ? c.copyWith(question: question, answer: answer, edited: true)
                : c,
          )
          .toList();
    });
  }

  Future<void> addCard(
    StudyArea area,
    String subtopicId, {
    required String question,
    required String answer,
  }) async {
    final card = StudyCard(
      id: 'card_${const Uuid().v4()}',
      question: question,
      answer: answer,
      edited: true,
    );
    await _writeCards(area, subtopicId, (cards) => [...cards, card]);
  }

  /// A card the user wrote is removed outright. A seeded one is tombstoned,
  /// because deleting it for real would only bring it back on the next sync.
  Future<void> deleteCard(
    StudyArea area,
    String subtopicId,
    StudyCard card,
  ) async {
    await _writeCards(area, subtopicId, (cards) {
      if (card.isCustom) return cards.where((c) => c.id != card.id).toList();
      return cards
          .map((c) => c.id == card.id ? c.copyWith(deleted: true) : c)
          .toList();
    });
  }

  /// Undo for a tombstoned card, so a mis-tap is recoverable.
  Future<void> restoreCard(
    StudyArea area,
    String subtopicId,
    StudyCard card,
  ) async {
    await _writeCards(area, subtopicId, (cards) {
      return cards
          .map((c) => c.id == card.id ? c.copyWith(deleted: false) : c)
          .toList();
    });
  }

  /// Rewrites one subtopic's card array. Firestore cannot update a single
  /// element of a nested array, so the whole subtopics field goes back.
  Future<void> _writeCards(
    StudyArea area,
    String subtopicId,
    List<StudyCard> Function(List<StudyCard>) update,
  ) async {
    final updated = area.subtopics
        .map((s) => s.id == subtopicId ? s.copyWith(cards: update(s.cards)) : s)
        .toList();
    await _areas.doc(area.id).update({
      'subtopics': updated.map((s) => s.toMap()).toList(),
    });
  }

  // ---- Notes ----

  Stream<List<Note>> watchNotes() {
    return _notes
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Note.fromFirestore(d.id, d.data())).toList(),
        );
  }

  Future<void> upsertNote(Note note) async {
    await _notes.doc(note.id).set(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await _notes.doc(id).delete();
  }
}
