import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final DateTime targetDate;
  final int doneTopics;
  final int totalTopics;
  final double fraction;
  final int percent;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.title,
    required this.targetDate,
    required this.doneTopics,
    required this.totalTopics,
    required this.fraction,
    required this.percent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: kLightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.track_changes, color: kPrimaryPurple, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Goal', style: TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          const TextSpan(text: 'Target Date: '),
                          TextSpan(
                            text: DateFormat.yMMMd().format(targetDate),
                            style: const TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$doneTopics of $totalTopics topics completed',
                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: fraction,
                        strokeWidth: 6,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$percent%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Done', style: TextStyle(fontSize: 10, color: kPrimaryPurple)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
