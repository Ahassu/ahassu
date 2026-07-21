import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme.dart';
import 'path_detail_screen.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathsAsync = ref.watch(learningPathsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Topics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Your full Azure MLOps curriculum, fundamentals to expert.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Expanded(
              child: pathsAsync.when(
                data: (paths) => ListView.separated(
                  itemCount: paths.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final path = paths[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ExpansionTile(
                        title: Text('${path.order}. ${path.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${path.doneCount}/${path.totalCount} studied'
                          '${path.examCode != null ? ' · ${path.examCode}' : ''}'
                          '${path.certStatus.name == 'passed' ? ' · Certified ✓' : ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, size: 18, color: kPrimaryPurple),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PathDetailScreen(pathId: path.id)),
                          ),
                        ),
                        children: [
                          for (final topic in path.topics)
                            CheckboxListTile(
                              value: topic.done,
                              dense: true,
                              title: Text(
                                topic.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: topic.done ? TextDecoration.lineThrough : null,
                                  color: topic.done ? Colors.black45 : Colors.black87,
                                ),
                              ),
                              onChanged: (v) => ref
                                  .read(firestoreServiceProvider)
                                  .toggleTopic(path.id, topic.id, v ?? false),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
