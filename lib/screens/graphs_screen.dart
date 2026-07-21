import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/learning_path.dart';
import '../providers/providers.dart';
import '../theme.dart';

class GraphsScreen extends ConsumerWidget {
  const GraphsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(studySessionsProvider);
    final pathsAsync = ref.watch(learningPathsProvider);

    final today = DateTime.now();
    final last7 = List.generate(7, (i) => DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i)));
    final sessions = sessionsAsync.value ?? [];
    final minutesByDay = {
      for (final d in last7)
        d: sessions
            .where((s) => s.date.year == d.year && s.date.month == d.month && s.date.day == d.day)
            .fold<int>(0, (acc, s) => acc + s.minutes)
    };
    final maxMinutes = (minutesByDay.values.isEmpty ? 0 : minutesByDay.values.reduce((a, b) => a > b ? a : b)).toDouble();

    final paths = pathsAsync.value ?? [];
    final completed = paths.where((p) => p.isCompleted).length;
    final inProgress = paths.where((p) => p.isInProgress).length;
    final notStarted = paths.length - completed - inProgress;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          const Text('Graphs', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Visualize your study time and curriculum progress.', style: TextStyle(color: Colors.black54)),
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
          const Text('Curriculum Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: paths.isEmpty
                  ? const Text('No learning paths yet.', style: TextStyle(color: Colors.black45))
                  : Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 28,
                              sections: [
                                if (completed > 0)
                                  PieChartSectionData(value: completed.toDouble(), color: kGreen, showTitle: false),
                                if (inProgress > 0)
                                  PieChartSectionData(value: inProgress.toDouble(), color: kBlue, showTitle: false),
                                if (notStarted > 0)
                                  PieChartSectionData(value: notStarted.toDouble(), color: Colors.black12, showTitle: false),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _legendRow(kGreen, 'Completed', completed),
                              const SizedBox(height: 8),
                              _legendRow(kBlue, 'In Progress', inProgress),
                              const SizedBox(height: 8),
                              _legendRow(Colors.black26, 'Not Started', notStarted),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Path Completion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final LearningPath path in paths)
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
    );
  }

  Widget _legendRow(Color color, String label, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
