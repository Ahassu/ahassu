import 'package:cloud_firestore/cloud_firestore.dart';

import 'topic.dart';

enum CertStatus { notStarted, scheduled, passed }

CertStatus certStatusFromString(String? value) {
  return CertStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => CertStatus.notStarted,
  );
}

class LearningPath {
  final String id;
  final int order;
  final String title;
  final String? examCode;
  final CertStatus certStatus;
  final DateTime? examDate;
  final List<Topic> topics;

  const LearningPath({
    required this.id,
    required this.order,
    required this.title,
    this.examCode,
    this.certStatus = CertStatus.notStarted,
    this.examDate,
    this.topics = const [],
  });

  int get doneCount => topics.where((t) => t.done).length;
  int get totalCount => topics.length;
  bool get isCompleted => totalCount > 0 && doneCount == totalCount;
  bool get isInProgress => doneCount > 0 && !isCompleted;

  String get statusLabel {
    if (isCompleted) return 'Completed';
    if (isInProgress) return 'In Progress';
    return 'Not Started';
  }

  LearningPath copyWith({
    CertStatus? certStatus,
    DateTime? examDate,
    List<Topic>? topics,
  }) {
    return LearningPath(
      id: id,
      order: order,
      title: title,
      examCode: examCode,
      certStatus: certStatus ?? this.certStatus,
      examDate: examDate ?? this.examDate,
      topics: topics ?? this.topics,
    );
  }

  factory LearningPath.fromFirestore(String id, Map<String, dynamic> map) {
    final rawExamDate = map['examDate'];
    final rawTopics = (map['topics'] as List<dynamic>? ?? []);
    return LearningPath(
      id: id,
      order: map['order'] as int? ?? 0,
      title: map['title'] as String? ?? '',
      examCode: map['examCode'] as String?,
      certStatus: certStatusFromString(map['certStatus'] as String?),
      examDate: rawExamDate is Timestamp ? rawExamDate.toDate() : null,
      topics: rawTopics
          .map((t) => Topic.fromMap(Map<String, dynamic>.from(t as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'title': title,
      'examCode': examCode,
      'certStatus': certStatus.name,
      'examDate': examDate != null ? Timestamp.fromDate(examDate!) : null,
      'topics': topics.map((t) => t.toMap()).toList(),
    };
  }
}
