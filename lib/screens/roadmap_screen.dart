import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';
import 'roadmap_detail_screen.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roadmapsAsync = ref.watch(roadmapsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: kBackground,
            floating: true,
            title: Text('Roadmaps', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            sliver: roadmapsAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No roadmaps yet.', style: TextStyle(color: Colors.black45)),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = plans[index];
                      final fraction = plan.totalCount == 0 ? 0.0 : plan.doneCount / plan.totalCount;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RoadmapDetailScreen(roadmapId: plan.id)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                          style: const TextStyle(
                                            color: kPrimaryPurple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (plan.isCompleted)
                                        const Icon(Icons.check_circle, color: kGreen, size: 20)
                                      else
                                        Text(
                                          '${plan.doneCount}/${plan.totalCount}',
                                          style: const TextStyle(color: Colors.black45, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    plan.pathTitle,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    plan.summary,
                                    style: const TextStyle(color: Colors.black54, fontSize: 13.5, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: fraction,
                                      minHeight: 6,
                                      backgroundColor: kLightPurple,
                                      valueColor: const AlwaysStoppedAnimation(kPrimaryPurple),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: plans.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Error: $e')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
