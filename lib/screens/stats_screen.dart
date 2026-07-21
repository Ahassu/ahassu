import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/stat_chip.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsAsync = ref.watch(learningPathsProvider);
    final certStats = ref.watch(certificationStatsProvider);
    final totalMinutes = ref.watch(totalMinutesProvider);
    final overall = ref.watch(overallProgressProvider);
    final todayTopics = ref.watch(todayCompletedTopicsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text('Stats', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatChip(icon: Icons.workspace_premium, iconColor: Colors.redAccent, label: 'Certifications', value: '${certStats.passed}/${certStats.total}'),
                  StatChip(icon: Icons.access_time_filled, iconColor: kBlue, label: 'Total Time', value: '${(totalMinutes / 60).toStringAsFixed(1)}h'),
                  StatChip(icon: Icons.emoji_events, iconColor: Colors.amber.shade700, label: 'Overall', value: '${overall.percent}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.today, color: kPrimaryPurple),
              title: Text('$todayTopics topics completed today'),
              subtitle: const Text('See the Graphs tab for charts and trends'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Progress by Learning Path', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          pathsAsync.when(
            data: (paths) => Column(
              children: [
                for (final path in paths)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(path.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                              Text('${path.doneCount}/${path.totalCount}', style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: path.totalCount == 0 ? 0 : path.doneCount / path.totalCount,
                              minHeight: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
