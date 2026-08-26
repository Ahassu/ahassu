import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_area.dart';
import '../providers/providers.dart';
import '../theme.dart';
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

  const AreaDetailScreen({super.key, required this.areaId, this.focusSubtopicId});

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
              Text('${area.doneCount} of ${area.totalCount} ready · ${area.cardCount} questions',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          Text(area.focus,
              style: const TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 18),
          for (final sub in area.subtopics) ...[
            _SubtopicTile(
              area: area,
              subtopic: sub,
              expanded: _expandedId == sub.id,
              onToggle: () => setState(() => _expandedId = _expandedId == sub.id ? null : sub.id),
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
                            color: subtopic.done ? Colors.black45 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(subtopic.summary,
                            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.3)),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: Colors.black38),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (final card in subtopic.cards) _CardBlock(card: card),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final StudyCard card;

  const _CardBlock({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kQuestionBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15.5, height: 1.4, fontWeight: FontWeight.w700, color: kQuestionInk),
              children: [
                const TextSpan(text: 'Q: '),
                TextSpan(text: card.question),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _BlockLabel('Answer'),
        const SizedBox(height: 8),
        _PointsTable(points: card.points),
        const SizedBox(height: 18),
        _TintedBlock(
          background: kBestBg,
          label: 'Best Answer to Give:',
          labelColor: kBestInk,
          body: card.bestAnswer,
          italic: true,
        ),
        const SizedBox(height: 12),
        _TintedBlock(
          background: kHintBg,
          label: 'Hint to Remember:',
          labelColor: kHintInk,
          body: card.hint,
          italic: true,
          inline: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _BlockLabel extends StatelessWidget {
  final String text;

  const _BlockLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87));
  }
}

/// The breakdown, as a two-column table. Scrolls horizontally on narrow
/// screens rather than squeezing the left column into one character per line.
class _PointsTable extends StatelessWidget {
  final List<(String, String)> points;

  const _PointsTable({required this.points});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final narrow = width < 340;
        final table = SizedBox(
          width: narrow ? 340 : width,
          child: Table(
            border: TableBorder.all(color: Colors.black12, width: 1),
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
            children: [
              for (var i = 0; i < points.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.white : const Color(0xFFF6F7FA),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      child: Text(points[i].$1,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.35)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                      child: Text(points[i].$2,
                          style: const TextStyle(fontSize: 13.5, height: 1.35, color: Colors.black87)),
                    ),
                  ],
                ),
            ],
          ),
        );
        return narrow
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: table)
            : table;
      },
    );
  }
}

class _TintedBlock extends StatelessWidget {
  final Color background;
  final String label;
  final Color labelColor;
  final String body;
  final bool italic;

  /// Runs the label and body together on one flowing paragraph, the way the
  /// hint line reads, instead of stacking them.
  final bool inline;

  const _TintedBlock({
    required this.background,
    required this.label,
    required this.labelColor,
    required this.body,
    this.italic = false,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = TextStyle(
      fontSize: 14.5,
      height: 1.5,
      color: labelColor,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
    final labelStyle = TextStyle(
      fontSize: 14.5,
      height: 1.5,
      fontWeight: FontWeight.w700,
      color: labelColor,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: inline
          ? RichText(
              text: TextSpan(
                style: labelStyle,
                children: [
                  TextSpan(text: '$label '),
                  TextSpan(text: body, style: bodyStyle),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 6),
                SelectableText(body, style: bodyStyle),
              ],
            ),
    );
  }
}
