import 'package:cloud_firestore/cloud_firestore.dart';

class RoadmapStop {
  final String id;
  final int order;
  final String weekLabel;
  final String eyebrow;
  final String title;
  final String goal;
  final List<String> tasks;
  final String? lab;
  final String? checkpoint;
  final bool milestone;
  final bool done;
  final DateTime? completedAt;

  const RoadmapStop({
    required this.id,
    required this.order,
    required this.weekLabel,
    required this.eyebrow,
    required this.title,
    required this.goal,
    this.tasks = const [],
    this.lab,
    this.checkpoint,
    this.milestone = false,
    this.done = false,
    this.completedAt,
  });

  RoadmapStop copyWith({bool? done, DateTime? completedAt}) {
    return RoadmapStop(
      id: id,
      order: order,
      weekLabel: weekLabel,
      eyebrow: eyebrow,
      title: title,
      goal: goal,
      tasks: tasks,
      lab: lab,
      checkpoint: checkpoint,
      milestone: milestone,
      done: done ?? this.done,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory RoadmapStop.fromMap(Map<String, dynamic> map) {
    final rawCompletedAt = map['completedAt'];
    return RoadmapStop(
      id: map['id'] as String,
      order: map['order'] as int? ?? 0,
      weekLabel: map['weekLabel'] as String? ?? '',
      eyebrow: map['eyebrow'] as String? ?? '',
      title: map['title'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      tasks: (map['tasks'] as List<dynamic>? ?? []).map((t) => t as String).toList(),
      lab: map['lab'] as String?,
      checkpoint: map['checkpoint'] as String?,
      milestone: map['milestone'] as bool? ?? false,
      done: map['done'] as bool? ?? false,
      completedAt: rawCompletedAt is Timestamp ? rawCompletedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'weekLabel': weekLabel,
      'eyebrow': eyebrow,
      'title': title,
      'goal': goal,
      'tasks': tasks,
      'lab': lab,
      'checkpoint': checkpoint,
      'milestone': milestone,
      'done': done,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}

class RoadmapPlan {
  final String id;
  final int order;
  final String pathTitle;
  final String examCode;
  final String summary;
  final List<RoadmapStop> stops;

  const RoadmapPlan({
    required this.id,
    required this.order,
    required this.pathTitle,
    required this.examCode,
    required this.summary,
    this.stops = const [],
  });

  int get doneCount => stops.where((s) => s.done).length;
  int get totalCount => stops.length;
  bool get isCompleted => totalCount > 0 && doneCount == totalCount;

  factory RoadmapPlan.fromFirestore(String id, Map<String, dynamic> map) {
    final rawStops = (map['stops'] as List<dynamic>? ?? []);
    return RoadmapPlan(
      id: id,
      order: map['order'] as int? ?? 0,
      pathTitle: map['pathTitle'] as String? ?? '',
      examCode: map['examCode'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      stops: rawStops.map((s) => RoadmapStop.fromMap(Map<String, dynamic>.from(s as Map))).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'pathTitle': pathTitle,
      'examCode': examCode,
      'summary': summary,
      'stops': stops.map((s) => s.toMap()).toList(),
    };
  }
}
