import 'package:flutter/material.dart';

import '../models/learning_path.dart';
import '../theme.dart';

class PathTile extends StatelessWidget {
  final LearningPath path;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onNotesTap;

  const PathTile({
    super.key,
    required this.path,
    required this.index,
    required this.onTap,
    required this.onNotesTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusFg;
    IconData icon;
    Color iconColor;

    if (path.isCompleted) {
      statusBg = const Color(0xFFE3F5E7);
      statusFg = kGreen;
      icon = Icons.check_circle;
      iconColor = kGreen;
    } else if (path.isInProgress) {
      statusBg = const Color(0xFFE5EEFF);
      statusFg = kBlue;
      icon = Icons.radio_button_unchecked;
      iconColor = kBlue;
    } else {
      statusBg = const Color(0xFFF0F0F3);
      statusFg = Colors.black54;
      icon = Icons.radio_button_unchecked;
      iconColor = Colors.black26;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$index. ${path.title}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onNotesTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined, size: 14, color: kPrimaryPurple.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text('Notes', style: TextStyle(color: kPrimaryPurple.withValues(alpha: 0.9), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(path.statusLabel, style: TextStyle(color: statusFg, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
