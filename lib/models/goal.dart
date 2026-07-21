import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String title;
  final DateTime targetDate;
  final int dailyTopicGoal;

  const Goal({
    required this.title,
    required this.targetDate,
    this.dailyTopicGoal = 3,
  });

  factory Goal.fromFirestore(Map<String, dynamic> map) {
    final rawTargetDate = map['targetDate'];
    return Goal(
      title: map['title'] as String? ?? 'Become MLOps Expert',
      targetDate: rawTargetDate is Timestamp
          ? rawTargetDate.toDate()
          : DateTime.now().add(const Duration(days: 365)),
      dailyTopicGoal: map['dailyTopicGoal'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetDate': Timestamp.fromDate(targetDate),
      'dailyTopicGoal': dailyTopicGoal,
    };
  }
}
