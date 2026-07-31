import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../data/curriculum_seed.dart';
import '../data/notes_seed.dart';
import '../data/roadmap_seed.dart';
import '../models/goal.dart';
import '../models/learning_path.dart';
import '../models/note.dart';
import '../models/quiz_question.dart';
import '../models/roadmap.dart';
import '../models/study_session.dart';
import '../models/topic.dart';

const _uuid = Uuid();

/// Bumped whenever the seed content changes in a way that has to reach a
/// device that already seeded. Version 1 was the Azure MLOps curriculum;
/// version 2 is the Azure Platform Engineer curriculum.
const _seedVersion = 2;

/// Numbered path ids from the v1 MLOps curriculum, mapped to the path they
/// became in v2. Progress on a path not listed here belonged to a path that
/// no longer exists in the curriculum.
const _legacyPathMigration = <String, String>{
  'path_04': 'path_databricks', // Databricks & SQL
  'path_07': 'path_docker', // Docker & Containerization
  'path_08': 'path_cka', // Kubernetes
  'path_10': 'path_az400', // CI/CD & DevOps
  'path_13': 'path_interview', // Interview Preparation
};

/// v1 seed paths were `path_01`…`path_13`. Paths added from inside the app
/// use `path_<uuid>` and must never match this.
final _legacySeedPathId = RegExp(r'^path_\d+$');

const _defaultGoalTitle = 'Become an Azure Platform Engineer';

/// Goal titles written by earlier versions, safe to replace. A title the
/// user set themselves is left alone.
const _replaceableGoalTitles = <String>{
  'Become Azure MLOps Expert',
  'Become MLOps Expert',
};

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  CollectionReference<Map<String, dynamic>> get _paths =>
      _db.collection('learningPaths');
  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('notes');
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('studySessions');
  CollectionReference<Map<String, dynamic>> get _quizQuestions =>
      _db.collection('quizQuestions');
  CollectionReference<Map<String, dynamic>> get _roadmaps =>
      _db.collection('roadmaps');
  DocumentReference<Map<String, dynamic>> get _goalDoc =>
      _db.collection('goal').doc('main');

  DocumentReference<Map<String, dynamic>> get _seedMetaDoc =>
      _db.collection('meta').doc('seed');

  /// Brings an existing install up to the current [_seedVersion], and seeds
  /// from scratch on a fresh one — the empty case is just the version-0 case.
  ///
  /// Progress is preserved wherever it still has somewhere to live: cert
  /// status, exam dates, completed topics, and completed roadmap stops all
  /// carry across, including over the v1 numbered path ids. Progress on a
  /// path that no longer exists in the curriculum goes away with it.
  Future<void> syncSeedData() async {
    final meta = await _seedMetaDoc.get();
    final version = meta.data()?['version'] as int? ?? 0;
    if (version >= _seedVersion) return;

    await _syncCurriculum();
    await _syncRoadmaps();
    await _retireStaleGuideNotes();
    await _retargetDefaultGoal();

    await _seedMetaDoc.set({
      'version': _seedVersion,
      'syncedAt': Timestamp.now(),
    });
  }

  Future<void> _syncCurriculum() async {
    final existing = await _paths.get();
    final byId = {
      for (final d in existing.docs) d.id: LearningPath.fromFirestore(d.id, d.data()),
    };

    final batch = _db.batch();
    for (final path in buildSeedLearningPaths()) {
      final prior = byId[path.id] ?? _priorForPath(path.id, byId);
      batch.set(_paths.doc(path.id), _withPreservedTopics(path, prior).toMap());
    }
    // v1 seed docs are replaced by their semantic-id versions above; paths
    // added from inside the app have uuid ids and are left untouched.
    for (final doc in existing.docs) {
      if (_legacySeedPathId.hasMatch(doc.id)) {
        batch.delete(_paths.doc(doc.id));
      }
    }
    await batch.commit();
  }

  LearningPath? _priorForPath(String newId, Map<String, LearningPath> byId) {
    for (final entry in _legacyPathMigration.entries) {
      if (entry.value == newId) return byId[entry.key];
    }
    return null;
  }

  /// Matches topics by title rather than id, so a topic that survived a
  /// rewrite keeps its tick and a reworded one starts clean.
  LearningPath _withPreservedTopics(LearningPath seed, LearningPath? prior) {
    if (prior == null) return seed;
    final completedAtByTitle = {
      for (final t in prior.topics)
        if (t.done) t.title: t.completedAt ?? DateTime.now(),
    };
    return seed.copyWith(
      certStatus: prior.certStatus,
      examDate: prior.examDate,
      topics: seed.topics.map((t) {
        final completedAt = completedAtByTitle[t.title];
        if (completedAt == null) return t;
        return t.copyWith(done: true, completedAt: completedAt);
      }).toList(),
    );
  }

  Future<void> _syncRoadmaps() async {
    final existing = await _roadmaps.get();
    final byId = {
      for (final d in existing.docs) d.id: RoadmapPlan.fromFirestore(d.id, d.data()),
    };
    final seed = buildSeedRoadmaps();
    final seedIds = seed.map((p) => p.id).toSet();

    final batch = _db.batch();
    for (final plan in seed) {
      batch.set(_roadmaps.doc(plan.id), _withPreservedStops(plan, byId[plan.id]).toMap());
    }
    for (final doc in existing.docs) {
      if (!seedIds.contains(doc.id)) {
        batch.delete(_roadmaps.doc(doc.id));
      }
    }
    await batch.commit();
  }

  /// A stop keeps its tick only if both its id and its title are unchanged —
  /// stop ids are positional, so the title guards against a rewritten week
  /// inheriting the previous one's progress.
  RoadmapPlan _withPreservedStops(RoadmapPlan seed, RoadmapPlan? prior) {
    if (prior == null) return seed;
    final priorById = {for (final s in prior.stops) s.id: s};
    return RoadmapPlan(
      id: seed.id,
      order: seed.order,
      pathTitle: seed.pathTitle,
      examCode: seed.examCode,
      summary: seed.summary,
      stops: seed.stops.map((s) {
        final was = priorById[s.id];
        if (was == null || !was.done || was.title != s.title) return s;
        return s.copyWith(done: true, completedAt: was.completedAt ?? DateTime.now());
      }).toList(),
    );
  }

  /// Removes guide notes belonging to paths the curriculum no longer has.
  /// Only fixed seed ids are deleted — hand-written notes use uuid ids.
  Future<void> _retireStaleGuideNotes() async {
    final live = buildSeedGuideNotes().map((n) => n.id).toSet();
    final batch = _db.batch();
    for (final id in retiredGuideNoteIds) {
      if (!live.contains(id)) batch.delete(_notes.doc(id));
    }
    await batch.commit();
  }

  /// Repoints the goal at the new track, unless the user retitled it.
  /// Creates it on a fresh install, where there is no goal doc yet.
  Future<void> _retargetDefaultGoal() async {
    final doc = await _goalDoc.get();
    if (!doc.exists) {
      await _goalDoc.set(
        Goal(
          title: _defaultGoalTitle,
          targetDate: DateTime.now().add(const Duration(days: 365)),
        ).toMap(),
      );
      return;
    }
    final goal = Goal.fromFirestore(doc.data()!);
    if (!_replaceableGoalTitles.contains(goal.title)) return;
    await _goalDoc.set(
      Goal(
        title: _defaultGoalTitle,
        targetDate: goal.targetDate,
        dailyTopicGoal: goal.dailyTopicGoal,
      ).toMap(),
    );
  }

  /// Upserts one reference note per learning path with its full study
  /// guide content. Uses fixed ids, so this always overwrites just those
  /// specific notes (picking up content updates) without touching the
  /// notes collection otherwise — anything a user wrote themselves is
  /// untouched, since their notes have different (uuid) ids.
  Future<void> seedGuideNotesIfMissing() async {
    final batch = _db.batch();
    for (final note in buildSeedGuideNotes()) {
      batch.set(_notes.doc(note.id), note.toMap());
    }
    await batch.commit();
  }

  /// Upserts the standalone Interview Prep note by its fixed id — same
  /// always-upsert pattern as [seedGuideNotesIfMissing], so content edits
  /// here always land without ever duplicating the note.
  Future<void> seedInterviewPrepNoteIfMissing() async {
    final note = buildInterviewPrepPlatformNote();
    await _notes.doc(note.id).set(note.toMap());
  }

  // ---- Learning paths ----

  Stream<List<LearningPath>> watchLearningPaths() {
    return _paths.orderBy('order').snapshots().map((snap) => snap.docs
        .map((d) => LearningPath.fromFirestore(d.id, d.data()))
        .toList());
  }

  Future<void> addLearningPath(String title, {String? examCode}) async {
    final existing = await _paths.orderBy('order', descending: true).limit(1).get();
    final nextOrder = existing.docs.isEmpty
        ? 1
        : (existing.docs.first.data()['order'] as int? ?? 0) + 1;
    final path = LearningPath(
      id: 'path_${_uuid.v4()}',
      order: nextOrder,
      title: title,
      examCode: examCode,
    );
    await _paths.doc(path.id).set(path.toMap());
  }

  Future<void> updateLearningPath(String pathId, {required String title, String? examCode}) async {
    await _paths.doc(pathId).update({'title': title, 'examCode': examCode});
  }

  Future<void> deleteLearningPath(String pathId) async {
    await _paths.doc(pathId).delete();
  }

  Future<void> addTopic(String pathId, String title) async {
    final doc = await _paths.doc(pathId).get();
    if (!doc.exists) return;
    final path = LearningPath.fromFirestore(doc.id, doc.data()!);
    final updated = [...path.topics, Topic(id: 'topic_${_uuid.v4()}', title: title)];
    await _paths.doc(pathId).update({'topics': updated.map((t) => t.toMap()).toList()});
  }

  Future<void> updateTopicTitle(String pathId, String topicId, String title) async {
    final doc = await _paths.doc(pathId).get();
    if (!doc.exists) return;
    final path = LearningPath.fromFirestore(doc.id, doc.data()!);
    final updated = path.topics.map((t) => t.id == topicId ? Topic(id: t.id, title: title, done: t.done, completedAt: t.completedAt) : t).toList();
    await _paths.doc(pathId).update({'topics': updated.map((t) => t.toMap()).toList()});
  }

  Future<void> deleteTopic(String pathId, String topicId) async {
    final doc = await _paths.doc(pathId).get();
    if (!doc.exists) return;
    final path = LearningPath.fromFirestore(doc.id, doc.data()!);
    final updated = path.topics.where((t) => t.id != topicId).toList();
    await _paths.doc(pathId).update({'topics': updated.map((t) => t.toMap()).toList()});
  }

  Future<void> toggleTopic(String pathId, String topicId, bool done) async {
    final doc = await _paths.doc(pathId).get();
    if (!doc.exists) return;
    final path = LearningPath.fromFirestore(doc.id, doc.data()!);
    final updated = path.topics.map((t) {
      if (t.id != topicId) return t;
      return t.copyWith(done: done, completedAt: done ? DateTime.now() : null);
    }).toList();
    await _paths.doc(pathId).update({'topics': updated.map((t) => t.toMap()).toList()});
  }

  Future<void> updateCertStatus(
    String pathId, {
    required CertStatus certStatus,
    DateTime? examDate,
  }) async {
    await _paths.doc(pathId).update({
      'certStatus': certStatus.name,
      'examDate': examDate != null ? Timestamp.fromDate(examDate) : null,
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

  // ---- Study sessions ----

  Stream<List<StudySession>> watchStudySessions() {
    return _sessions.orderBy('date', descending: true).snapshots().map((snap) =>
        snap.docs.map((d) => StudySession.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> logStudySession({
    required int minutes,
    String? learningPathId,
    String? learningPathTitle,
  }) async {
    final id = 'session_${_uuid.v4()}';
    final session = StudySession(
      id: id,
      date: DateTime.now(),
      minutes: minutes,
      learningPathId: learningPathId,
      learningPathTitle: learningPathTitle,
    );
    await _sessions.doc(id).set(session.toMap());
  }

  // ---- Quiz ----

  Stream<List<QuizQuestion>> watchQuizQuestions() {
    return _quizQuestions.orderBy('createdAt').snapshots().map((snap) =>
        snap.docs.map((d) => QuizQuestion.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> addQuizQuestion({
    required String learningPathId,
    required String question,
    required List<String> options,
    required int correctIndex,
  }) async {
    final id = 'quiz_${_uuid.v4()}';
    final q = QuizQuestion(
      id: id,
      learningPathId: learningPathId,
      question: question,
      options: options,
      correctIndex: correctIndex,
      createdAt: DateTime.now(),
    );
    await _quizQuestions.doc(id).set(q.toMap());
  }

  Future<void> deleteQuizQuestion(String id) async {
    await _quizQuestions.doc(id).delete();
  }

  // ---- Roadmaps ----

  Stream<List<RoadmapPlan>> watchRoadmaps() {
    return _roadmaps.orderBy('order').snapshots().map((snap) => snap.docs
        .map((d) => RoadmapPlan.fromFirestore(d.id, d.data()))
        .toList());
  }

  Future<void> toggleRoadmapStop(String roadmapId, String stopId, bool done) async {
    final doc = await _roadmaps.doc(roadmapId).get();
    if (!doc.exists) return;
    final plan = RoadmapPlan.fromFirestore(doc.id, doc.data()!);
    final updated = plan.stops.map((s) {
      if (s.id != stopId) return s;
      return s.copyWith(done: done, completedAt: done ? DateTime.now() : null);
    }).toList();
    await _roadmaps.doc(roadmapId).update({'stops': updated.map((s) => s.toMap()).toList()});
  }

  // ---- Goal ----

  Stream<Goal> watchGoal() {
    return _goalDoc.snapshots().map((doc) => doc.exists
        ? Goal.fromFirestore(doc.data()!)
        : Goal(title: _defaultGoalTitle, targetDate: DateTime.now().add(const Duration(days: 365))));
  }

  Future<void> updateGoal(Goal goal) async {
    await _goalDoc.set(goal.toMap());
  }
}
