import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../data/curriculum_seed.dart';
import '../models/goal.dart';
import '../models/learning_path.dart';
import '../models/note.dart';
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

  Future<void> addTopic(String pathId, String title) async {
    final doc = await _paths.doc(pathId).get();
    if (!doc.exists) return;
    final path = LearningPath.fromFirestore(doc.id, doc.data()!);
    final updated = [...path.topics, Topic(id: 'topic_${_uuid.v4()}', title: title)];
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
