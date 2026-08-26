import 'package:ahassu/models/study_area.dart';
import 'package:ahassu/services/firestore_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// The merge decides what happens to the user's work every time the seed
/// content is updated. Getting it wrong silently destroys answers they
/// rewrote themselves, which is the worst failure this app has available.

StudyArea _area(List<StudyCard> cards, {bool done = false}) => StudyArea(
      id: 'containers',
      title: 'Docker and Kubernetes',
      focus: 'focus',
      weight: AreaWeight.high,
      order: 0,
      subtopics: [
        StudySubtopic(
          id: 'containers.docker',
          title: 'Docker images',
          summary: 'summary',
          cards: cards,
          done: done,
        ),
      ],
    );

void main() {
  const seedCard = StudyCard(
    id: 'containers.docker#0',
    question: 'What is an image?',
    answer: 'Seed answer, version two.',
  );

  test('a card the user rewrote is not overwritten by new seed content', () {
    final prior = _area(const [
      StudyCard(
        id: 'containers.docker#0',
        question: 'What is an image?',
        answer: 'My own words.',
        edited: true,
      )
    ]);

    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), prior);

    expect(merged.subtopics.single.cards.single.answer, 'My own words.');
  });

  test('a card the user has not touched picks up the new seed content', () {
    final prior = _area(const [
      StudyCard(
        id: 'containers.docker#0',
        question: 'What is an image?',
        answer: 'Seed answer, version one.',
      )
    ]);

    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), prior);

    expect(merged.subtopics.single.cards.single.answer, 'Seed answer, version two.');
  });

  test('a deleted seed card stays deleted and stays hidden', () {
    final prior = _area(const [
      StudyCard(
        id: 'containers.docker#0',
        question: 'What is an image?',
        answer: 'Seed answer, version one.',
        deleted: true,
      )
    ]);

    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), prior);
    final sub = merged.subtopics.single;

    expect(sub.cards.single.deleted, isTrue, reason: 'tombstone must survive');
    expect(sub.visibleCards, isEmpty, reason: 'and must not come back on screen');
  });

  test('a card the user wrote themselves is carried across', () {
    final prior = _area(const [
      seedCard,
      StudyCard(
        id: 'card_abc',
        question: 'My own question?',
        answer: 'My own answer.',
        edited: true,
      ),
    ]);

    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), prior);

    expect(merged.subtopics.single.cards.map((c) => c.id),
        containsAll(<String>['containers.docker#0', 'card_abc']));
  });

  test('new seed cards arrive alongside the user cards', () {
    const seedTwo = StudyCard(
      id: 'containers.docker#1',
      question: 'How do you keep it small?',
      answer: 'Multi-stage build.',
    );
    final prior = _area(const [seedCard]);

    final merged =
        FirestoreService.mergeUserState(_area(const [seedCard, seedTwo]), prior);

    expect(merged.subtopics.single.visibleCards.length, 2);
  });

  test('the tick on a subtopic survives', () {
    final prior = _area(const [seedCard], done: true);

    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), prior);

    expect(merged.subtopics.single.done, isTrue);
  });

  test('a first-time sync just takes the seed', () {
    final merged = FirestoreService.mergeUserState(_area(const [seedCard]), null);

    expect(merged.subtopics.single.cards.single.answer, 'Seed answer, version two.');
  });
}
