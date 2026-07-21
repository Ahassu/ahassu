import 'package:cloud_firestore/cloud_firestore.dart';

class Topic {
  final String id;
  final String title;
  final bool done;
  final DateTime? completedAt;

  const Topic({
    required this.id,
    required this.title,
    this.done = false,
    this.completedAt,
  });

  Topic copyWith({bool? done, DateTime? completedAt}) {
    return Topic(
      id: id,
      title: title,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    final rawCompletedAt = map['completedAt'];
    return Topic(
      id: map['id'] as String,
      title: map['title'] as String,
      done: map['done'] as bool? ?? false,
      completedAt: rawCompletedAt is Timestamp ? rawCompletedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
