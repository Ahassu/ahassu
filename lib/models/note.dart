import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final String? learningPathId;
  final String? learningPathTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.learningPathId,
    this.learningPathTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromFirestore(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final updatedAt = map['updatedAt'];
    return Note(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      learningPathId: map['learningPathId'] as String?,
      learningPathTitle: map['learningPathTitle'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'learningPathId': learningPathId,
      'learningPathTitle': learningPathTitle,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
