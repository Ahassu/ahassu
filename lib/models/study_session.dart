import 'package:cloud_firestore/cloud_firestore.dart';

class StudySession {
  final String id;
  final DateTime date;
  final int minutes;
  final String? learningPathId;
  final String? learningPathTitle;

  const StudySession({
    required this.id,
    required this.date,
    required this.minutes,
    this.learningPathId,
    this.learningPathTitle,
  });

  factory StudySession.fromFirestore(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    return StudySession(
      id: id,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      minutes: map['minutes'] as int? ?? 0,
      learningPathId: map['learningPathId'] as String?,
      learningPathTitle: map['learningPathTitle'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'minutes': minutes,
      'learningPathId': learningPathId,
      'learningPathTitle': learningPathTitle,
    };
  }
}
