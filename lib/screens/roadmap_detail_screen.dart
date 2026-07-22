import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/roadmap.dart';
import '../providers/providers.dart';
import '../theme.dart';

class RoadmapDetailScreen extends ConsumerWidget {
  final String roadmapId;

  const RoadmapDetailScreen({super.key, required this.roadmapId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roadmapsAsync = ref.watch(roadmapsProvider);

    return Scaffold(
      body: roadmapsAsync.when(
        data: (plans) {
          final plan = plans.firstWhere((p) => p.id == roadmapId, orElse: () => plans.first);

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: kBackground,
                  pinned: true,
                  title: Text(plan.pathTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kLightPurple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              plan.examCode,
                              style: const TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${plan.doneCount} of ${plan.totalCount} stops complete',
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < plan.stops.length; i++)
                        _StopCard(
                          roadmapId: plan.id,
                          stop: plan.stops[i],
                          isLast: i == plan.stops.length - 1,
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StopCard extends ConsumerWidget {
  final String roadmapId;
  final RoadmapStop stop;
  final bool isLast;

  const _StopCard({required this.roadmapId, required this.stop, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markerColor = stop.done ? kGreen : (stop.milestone ? kPrimaryPurple : kBlue);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stop.done ? kGreen : Colors.white,
                  border: Border.all(color: markerColor, width: 2),
                ),
                alignment: Alignment.center,
                child: stop.done
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Icon(
                        stop.milestone ? Icons.flag_rounded : Icons.circle,
                        color: markerColor,
                        size: stop.milestone ? 18 : 10,
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.black12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${stop.weekLabel} · ${stop.eyebrow}'.toUpperCase(),
                              style: const TextStyle(
                                color: kPrimaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: stop.done,
                            onChanged: (v) => ref
                                .read(firestoreServiceProvider)
                                .toggleRoadmapStop(roadmapId, stop.id, v ?? false),
                          ),
                        ],
                      ),
                      Text(
                        stop.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          decoration: stop.done ? TextDecoration.lineThrough : null,
                          color: stop.done ? Colors.black45 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(stop.goal, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
                      if (stop.tasks.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        for (final task in stop.tasks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, right: 8),
                                  child: Icon(Icons.circle, size: 5, color: kPrimaryPurple),
                                ),
                                Expanded(child: Text(task, style: const TextStyle(fontSize: 14.5, height: 1.4))),
                              ],
                            ),
                          ),
                      ],
                      if (stop.lab != null) ...[
                        const SizedBox(height: 8),
                        _CalloutBox(label: 'Lab', color: kBlue, text: stop.lab!),
                      ],
                      if (stop.checkpoint != null) ...[
                        const SizedBox(height: 8),
                        _CalloutBox(
                          label: stop.milestone ? 'Ready when' : 'Checkpoint',
                          color: Colors.orange.shade800,
                          text: stop.checkpoint!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalloutBox extends StatelessWidget {
  final String label;
  final Color color;
  final String text;

  const _CalloutBox({required this.label, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10.5, letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }
}
