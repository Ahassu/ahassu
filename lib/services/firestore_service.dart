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

  /// Seeds the curriculum + default goal the first time the app is run.
  Future<void> seedIfEmpty() async {
    final existing = await _paths.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final path in buildSeedLearningPaths()) {
      batch.set(_paths.doc(path.id), path.toMap());
    }
    batch.set(_goalDoc, Goal(
      title: 'Become Azure MLOps Expert',
      targetDate: DateTime.now().add(const Duration(days: 365)),
    ).toMap());
    await batch.commit();
  }

  /// Seeds the certification roadmaps the first time the app is run.
  /// Kept separate from [seedIfEmpty] so it can backfill for accounts that
  /// already seeded learningPaths before roadmaps existed.
  Future<void> seedRoadmapsIfEmpty() async {
    final existing = await _roadmaps.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final plan in buildSeedRoadmaps()) {
      batch.set(_roadmaps.doc(plan.id), plan.toMap());
    }
    await batch.commit();
  }

  /// Seeds one reference note per learning path linking its full study
  /// guide. Uses fixed ids and checks a single marker doc rather than
  /// "collection empty", since the notes collection may already contain
  /// notes a user wrote themselves.
  Future<void> seedGuideNotesIfMissing() async {
    final marker = await _notes.doc('note_guide_path_01').get();
    if (marker.exists) return;

    final batch = _db.batch();
    for (final note in buildSeedGuideNotes()) {
      batch.set(_notes.doc(note.id), note.toMap());
    }
    await batch.commit();
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
        : Goal(title: 'Become Azure MLOps Expert', targetDate: DateTime.now().add(const Duration(days: 365))));
  }

  Future<void> updateGoal(Goal goal) async {
    await _goalDoc.set(goal.toMap());
  }
}
