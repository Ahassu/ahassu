import 'package:ahassu/main.dart';
import 'package:ahassu/models/note.dart';
import 'package:ahassu/models/study_area.dart';
import 'package:ahassu/providers/providers.dart';
import 'package:ahassu/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for [FirestoreService] so nothing in the widget tree reaches
/// `FirebaseFirestore.instance`, which throws in a test process where no
/// Firebase app has been initialized.
///
/// Overriding the service rather than each stream provider means the derived
/// providers (`readinessProvider`, `nextUpProvider`, …) keep their real logic
/// and are exercised by the test.
///
/// Write methods (`setSubtopicDone`, `upsertNote`) are left to `noSuchMethod`.
/// This smoke test never invokes them, and forwarding means the fake does not
/// need updating every time the service grows a method — if a future test does
/// call one, it fails loudly with NoSuchMethodError rather than silently
/// no-opping.
class _FakeFirestoreService implements FirestoreService {
  final List<StudyArea> areas;

  _FakeFirestoreService({this.areas = const []});

  @override
  Future<void> syncSeedData() async {}

  @override
  Stream<List<StudyArea>> watchStudyAreas() => Stream.value(areas);

  @override
  Stream<List<Note>> watchNotes() => Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AhassuApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreServiceProvider.overrideWithValue(_FakeFirestoreService()),
        ],
        child: const AhassuApp(),
      ),
    );

    // Two pumps: the first builds the tree, the second lets the seeded streams
    // deliver their first event so screens leave their loading state.
    await tester.pump();
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('plan screen shows readiness and the next unfinished subtopic',
      (WidgetTester tester) async {
    final area = StudyArea(
      id: 'intro',
      title: 'Introduce Yourself',
      focus: 'The first five minutes.',
      weight: AreaWeight.critical,
      order: 0,
      subtopics: const [
        StudySubtopic(
          id: 'intro.tell-me',
          title: 'Tell me about yourself',
          summary: 'The opening question.',
          cards: [],
          done: true,
        ),
        StudySubtopic(
          id: 'intro.gap',
          title: 'The career break',
          summary: 'Twenty seconds, then stop.',
          cards: [],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firestoreServiceProvider
              .overrideWithValue(_FakeFirestoreService(areas: [area])),
        ],
        child: const AhassuApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    // One of two subtopics ticked.
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1 of 2 topics ready'), findsOneWidget);

    // "Next up" skips the finished subtopic and offers the unfinished one.
    expect(find.text('NEXT UP'), findsOneWidget);
    expect(find.text('The career break'), findsOneWidget);
  });
}
