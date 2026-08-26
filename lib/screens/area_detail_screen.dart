import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_area.dart';
import '../providers/providers.dart';
import '../theme.dart';
import 'card_editor_screen.dart';
import 'plan_screen.dart' show WeightBadge;

/// One area's subtopics. Each expands into its question cards: the question,
/// the breakdown, the sentence to say out loud, and the memory hook.
///
/// The area is read from the provider rather than passed in, so ticking a
/// subtopic updates in place instead of leaving this screen holding a stale
/// copy of the area it was pushed with.
class AreaDetailScreen extends ConsumerStatefulWidget {
  final String areaId;

  /// Opened from "next up" — expands straight to the subtopic in question.
  final String? focusSubtopicId;

  const AreaDetailScreen({
    super.key,
    required this.areaId,
    this.focusSubtopicId,
  });

  @override
  ConsumerState<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends ConsumerState<AreaDetailScreen> {
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _expandedId = widget.focusSubtopicId;
  }

  @override
  Widget build(BuildContext context) {
    final areas = ref.watch(studyAreasProvider).value ?? [];
    final area = areas.where((a) => a.id == widget.areaId).firstOrNull;

    if (area == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(area.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Row(
            children: [
              WeightBadge(weight: area.weight),
              const SizedBox(width: 10),
              Text(
                '${area.doneCount} of ${area.totalCount} ready · ${area.cardCount} questions',
                style: const TextStyle(fontSize: 12.5, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            area.focus,
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          for (final sub in area.subtopics) ...[
            _SubtopicTile(
              area: area,
              subtopic: sub,
              expanded: _expandedId == sub.id,
              onToggle: () => setState(
                () => _expandedId = _expandedId == sub.id ? null : sub.id,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SubtopicTile extends ConsumerWidget {
  final StudyArea area;
  final StudySubtopic subtopic;
  final bool expanded;
  final VoidCallback onToggle;

  const _SubtopicTile({
    required this.area,
    required this.subtopic,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: subtopic.done,
                    onChanged: (v) => ref
                        .read(firestoreServiceProvider)
                        .setSubtopicDone(area, subtopic.id, v ?? false),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtopic.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: subtopic.done
                                ? Colors.black45
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtopic.summary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final card in subtopic.visibleCards)
                    _CardBlock(area: area, subtopic: subtopic, card: card),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardEditorScreen(
                            area: area,
                            subtopicId: subtopic.id,
                            subtopicTitle: subtopic.title,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: kPrimaryPurple,
                      ),
                      label: const Text(
                        'Add your own question',
                        style: TextStyle(color: kPrimaryPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A question and its answer, told apart by colour alone — no labels, by
/// request. The semantics labels are for screen readers, which cannot see the
/// colour difference the design leans on.
class _CardBlock extends ConsumerWidget {
  final StudyArea area;
  final StudySubtopic subtopic;
  final StudyCard card;

  const _CardBlock({
    required this.area,
    required this.subtopic,
    required this.card,
  });

  void _edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardEditorScreen(
          area: area,
          subtopicId: subtopic.id,
          subtopicTitle: subtopic.title,
          existing: card,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final service = ref.read(firestoreServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    await service.deleteCard(area, subtopic.id, card);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Question deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          // A card the user wrote is gone for good; a seeded one is only
          // tombstoned, so undo can bring it back.
          onPressed: () => card.isCustom
              ? service.addCard(
                  area,
                  subtopic.id,
                  question: card.question,
                  answer: card.answer,
                )
              : service.restoreCard(area, subtopic.id, card),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Semantics(
              label: 'Question',
              child: _Block(
                background: kQuestionBg,
                ink: kQuestionInk,
                text: card.question,
                weight: FontWeight.w700,
                trailingGutter: true,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: kQuestionInk,
                ),
                tooltip: 'Edit or delete',
                onSelected: (v) =>
                    v == 'edit' ? _edit(context) : _delete(context, ref),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Answer',
          child: _Block(
            background: kBestBg,
            ink: kBestInk,
            text: card.answer,
            selectable: true,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final Color background;
  final Color ink;
  final String text;
  final FontWeight weight;

  /// The answer is selectable so it can be copied out to rehearse from.
  final bool selectable;

  /// Leaves room on the right for the overflow menu that sits over the block,
  /// so a long question does not run underneath it.
  final bool trailingGutter;

  const _Block({
    required this.background,
    required this.ink,
    required this.text,
    this.weight = FontWeight.w400,
    this.selectable = false,
    this.trailingGutter = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: ink,
      fontWeight: weight,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, 13, trailingGutter ? 40 : 14, 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: selectable
          ? SelectableText(text, style: style)
          : Text(text, style: style),
    );
  }
}
