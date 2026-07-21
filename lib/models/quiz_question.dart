import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String learningPathId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final DateTime createdAt;

  const QuizQuestion({
    required this.id,
    required this.learningPathId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.createdAt,
  });

  factory QuizQuestion.fromFirestore(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    return QuizQuestion(
      id: id,
      learningPathId: map['learningPathId'] as String? ?? '',
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? const []),
      correctIndex: map['correctIndex'] as int? ?? 0,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'learningPathId': learningPathId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
