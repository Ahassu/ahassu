import 'package:ahassu/data/study_plan_seed.dart';
import 'package:ahassu/models/study_area.dart';
import 'package:flutter_test/flutter_test.dart';

/// The plan is hand-written content, so these guard the things that are easy
/// to get wrong by hand and invisible until the app is open: a duplicated id
/// silently collapses two subtopics' progress into one, and an empty question
/// or answer renders as a blank coloured block.
void main() {
  final plan = buildStudyPlan();

  test('the plan opens on introducing yourself', () {
    expect(plan.first.id, 'intro');
    expect(plan.first.subtopics.first.id, 'intro.tell-me');
  });

  test('subtopic ids are unique across the whole plan', () {
    final ids = [for (final a in plan) for (final s in a.subtopics) s.id];
    expect(ids.length, ids.toSet().length);
  });

  test('area ids are unique and order is sequential', () {
    expect(plan.map((a) => a.id).toSet().length, plan.length);
    for (var i = 0; i < plan.length; i++) {
      expect(plan[i].order, i);
    }
  });

  test('every subtopic has at least one fully written card', () {
    for (final area in plan) {
      expect(area.subtopics, isNotEmpty, reason: '${area.id} has no subtopics');
      for (final sub in area.subtopics) {
        expect(sub.title, isNotEmpty);
        expect(sub.summary, isNotEmpty);
        expect(sub.cards, isNotEmpty, reason: '${sub.id} has no cards');
        for (final card in sub.cards) {
          expect(card.question, isNotEmpty, reason: '${sub.id} question');
          expect(card.answer, isNotEmpty, reason: '${sub.id} answer');
        }
      }
    }
  });

  test('nothing starts ticked', () {
    for (final area in plan) {
      expect(area.doneCount, 0);
    }
  });

  test('the critical areas the posting leans on are all present', () {
    final critical =
        plan.where((a) => a.weight == AreaWeight.critical).map((a) => a.id).toSet();
    expect(
      critical,
      containsAll(<String>['intro', 'azure-network', 'databricks', 'terraform', 'cicd']),
    );
  });
}
