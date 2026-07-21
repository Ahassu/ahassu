import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/stat_chip.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsAsync = ref.watch(learningPathsProvider);
    final sessionsAsync = ref.watch(studySessionsProvider);
    final streak = ref.watch(studyStreakProvider);
    final totalMinutes = ref.watch(totalMinutesProvider);
    final overall = ref.watch(overallProgressProvider);

    final today = DateTime.now();
    final last7 = List.generate(7, (i) => DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i)));
    final sessions = sessionsAsync.value ?? [];
    final minutesByDay = {
      for (final d in last7)
        d: sessions
            .where((s) => s.date.year == d.year && s.date.month == d.month && s.date.day == d.day)
            .fold<int>(0, (sum, s) => sum + s.minutes)
    };
    final maxMinutes = (minutesByDay.values.isEmpty ? 0 : minutesByDay.values.reduce((a, b) => a > b ? a : b)).toDouble();

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
                  StatChip(icon: Icons.local_fire_department, iconColor: Colors.redAccent, label: 'Streak', value: '$streak days'),
                  StatChip(icon: Icons.access_time_filled, iconColor: kBlue, label: 'Total Time', value: '${(totalMinutes / 60).toStringAsFixed(1)}h'),
                  StatChip(icon: Icons.emoji_events, iconColor: Colors.amber.shade700, label: 'Overall', value: '${overall.percent}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('This Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
              child: SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    maxY: maxMinutes <= 0 ? 30 : maxMinutes * 1.2,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= last7.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(DateFormat.E().format(last7[idx]), style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < last7.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: (minutesByDay[last7[i]] ?? 0).toDouble(),
                            color: kPrimaryPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
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
