/// One interview question inside a subtopic: the question as an interviewer
/// asks it, and the answer to say back.
class StudyCard {
  final String question;

  /// The spoken answer. First person, role-specific, ready to rehearse out
  /// loud — this is the whole point of the card, and it is deliberately
  /// written the way someone talks rather than the way a doc reads.
  final String answer;

  const StudyCard({required this.question, required this.answer});

  factory StudyCard.fromMap(Map<String, dynamic> map) {
    return StudyCard(
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'question': question, 'answer': answer};
}

/// The study plan is a flat list of areas, each holding the subtopics that
/// have to be interview-ready. Progress lives on the subtopic, so an area's
/// readiness is derived rather than stored — nothing to keep in sync.
class StudySubtopic {
  /// Stable and unique across the whole plan, so progress survives reordering
  /// or rewording of a subtopic in the seed.
  final String id;
  final String title;

  /// What this subtopic is, in one line, for the collapsed list row.
  final String summary;

  /// The question cards. Usually one; more where an interviewer is likely to
  /// come at the same subtopic from two directions.
  final List<StudyCard> cards;
  final bool done;
  final DateTime? completedAt;

  const StudySubtopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.cards,
    this.done = false,
    this.completedAt,
  });

  StudySubtopic copyWith({
    bool? done,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return StudySubtopic(
      id: id,
      title: title,
      summary: summary,
      cards: cards,
      done: done ?? this.done,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  factory StudySubtopic.fromMap(Map<String, dynamic> map) {
    final completedAt = map['completedAt'];
    final raw = map['cards'] as List<dynamic>? ?? const [];
    return StudySubtopic(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      cards: raw
          .map((e) => StudyCard.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      done: map['done'] as bool? ?? false,
      completedAt: completedAt is String
          ? DateTime.tryParse(completedAt)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'summary': summary,
    'cards': cards.map((c) => c.toMap()).toList(),
    'done': done,
    'completedAt': completedAt?.toIso8601String(),
  };
}

/// How hard the job description leans on an area. Drives ordering and the
/// badge on each card, so prep time follows the posting rather than habit.
enum AreaWeight { critical, high, support }

extension AreaWeightLabel on AreaWeight {
  String get label => switch (this) {
    AreaWeight.critical => 'Critical',
    AreaWeight.high => 'High',
    AreaWeight.support => 'Support',
  };
}

class StudyArea {
  final String id;
  final String title;

  /// One line on why the posting cares about this area.
  final String focus;
  final AreaWeight weight;
  final int order;
  final List<StudySubtopic> subtopics;

  const StudyArea({
    required this.id,
    required this.title,
    required this.focus,
    required this.weight,
    required this.order,
    this.subtopics = const [],
  });

  int get doneCount => subtopics.where((s) => s.done).length;
  int get totalCount => subtopics.length;
  int get cardCount => subtopics.fold<int>(0, (a, s) => a + s.cards.length);
  double get fraction => totalCount == 0 ? 0 : doneCount / totalCount;
  int get percent => (fraction * 100).round();

  StudyArea copyWith({List<StudySubtopic>? subtopics}) => StudyArea(
    id: id,
    title: title,
    focus: focus,
    weight: weight,
    order: order,
    subtopics: subtopics ?? this.subtopics,
  );

  factory StudyArea.fromFirestore(String id, Map<String, dynamic> map) {
    final raw = map['subtopics'] as List<dynamic>? ?? const [];
    return StudyArea(
      id: id,
      title: map['title'] as String? ?? '',
      focus: map['focus'] as String? ?? '',
      weight: AreaWeight.values.firstWhere(
        (w) => w.name == map['weight'],
        orElse: () => AreaWeight.high,
      ),
      order: map['order'] as int? ?? 0,
      subtopics: raw
          .map(
            (e) => StudySubtopic.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'focus': focus,
    'weight': weight.name,
    'order': order,
    'subtopics': subtopics.map((s) => s.toMap()).toList(),
  };
}
