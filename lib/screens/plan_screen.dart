import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_area.dart';
import '../providers/providers.dart';
import '../theme.dart';
import 'area_detail_screen.dart';

/// The study plan: every area the posting asks for, ordered by how hard it
/// leans on each. Opens on what to study next so the app never asks the user
/// to make a decision before they have started.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(studyAreasProvider);
    final readiness = ref.watch(readinessProvider);
    final critical = ref.watch(criticalReadinessProvider);
    final nextUp = ref.watch(nextUpProvider);

    return SafeArea(
      child: areasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Could not load the plan.\n$e'))),
        data: (areas) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            const Text('Interview Prep',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text('Platform Engineer · Scotiabank GBM · Dallas',
                style: TextStyle(fontSize: 13.5, color: Colors.black54)),
            const SizedBox(height: 18),
            _ReadinessCard(overall: readiness, critical: critical),
            if (nextUp != null) ...[
              const SizedBox(height: 12),
              _NextUpCard(area: nextUp.$1, subtopic: nextUp.$2),
            ],
            const SizedBox(height: 22),
            const Text('Topics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final area in areas) ...[
              _AreaTile(area: area),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  final Readiness overall;
  final Readiness critical;

  const _ReadinessCard({required this.overall, required this.critical});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${overall.percent}%',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1)),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${overall.done} of ${overall.total} topics ready',
                      style: const TextStyle(color: Colors.black54)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: overall.fraction, minHeight: 8),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.priority_high_rounded, size: 16, color: kCritical),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Critical areas: ${critical.done} of ${critical.total} — these are what the posting leans on hardest.',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextUpCard extends StatelessWidget {
  final StudyArea area;
  final StudySubtopic subtopic;

  const _NextUpCard({required this.area, required this.subtopic});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kLightPurple,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AreaDetailScreen(areaId: area.id, focusSubtopicId: subtopic.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NEXT UP',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: kPrimaryPurple)),
                    const SizedBox(height: 6),
                    Text(subtopic.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(area.title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: kPrimaryPurple),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaTile extends StatelessWidget {
  final StudyArea area;

  const _AreaTile({required this.area});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AreaDetailScreen(areaId: area.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(area.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  WeightBadge(weight: area.weight),
                ],
              ),
              const SizedBox(height: 6),
              Text(area.focus,
                  style: const TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.35)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(value: area.fraction, minHeight: 6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${area.doneCount}/${area.totalCount}',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeightBadge extends StatelessWidget {
  final AreaWeight weight;

  const WeightBadge({super.key, required this.weight});

  @override
  Widget build(BuildContext context) {
    final color = switch (weight) {
      AreaWeight.critical => kCritical,
      AreaWeight.high => kHigh,
      AreaWeight.support => kSupport,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(weight.label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
    );
  }
}
