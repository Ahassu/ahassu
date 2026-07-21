import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../screens/home_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/topics_screen.dart';
import '../theme.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    TopicsScreen(),
    NotesScreen(),
    StatsScreen(),
  ];

  Future<void> _logStudySession() async {
    final pathsAsync = ref.read(learningPathsProvider);
    final paths = pathsAsync.value ?? [];
    final minutesController = TextEditingController(text: '30');
    String? selectedPathId;
    String? selectedPathTitle;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Study Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes studied'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedPathId,
                decoration: const InputDecoration(labelText: 'Learning path (optional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  for (final p in paths) DropdownMenuItem(value: p.id, child: Text(p.title)),
                ],
                onChanged: (v) => setState(() {
                  selectedPathId = v;
                  selectedPathTitle = paths.where((p) => p.id == v).map((p) => p.title).firstOrNull;
                }),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      final minutes = int.tryParse(minutesController.text.trim()) ?? 0;
      if (minutes > 0) {
        await ref.read(firestoreServiceProvider).logStudySession(
              minutes: minutes,
              learningPathId: selectedPathId,
              learningPathTitle: selectedPathTitle,
            );
      }
    }
  }

  Future<void> _showQuickActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer, color: kPrimaryPurple),
              title: const Text('Log Study Session'),
              onTap: () => Navigator.pop(ctx, 'session'),
            ),
            ListTile(
              leading: const Icon(Icons.note_add, color: kPrimaryPurple),
              title: const Text('Add Note'),
              onTap: () => Navigator.pop(ctx, 'note'),
            ),
          ],
        ),
      ),
    );

    if (action == 'session') {
      await _logStudySession();
    } else if (action == 'note' && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const NoteEditorScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.menu_book_rounded, 'Topics', 1),
            const SizedBox(width: 40),
            _navItem(Icons.description_rounded, 'Notes', 2),
            _navItem(Icons.bar_chart_rounded, 'Stats', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final selected = _index == index;
    final color = selected ? kPrimaryPurple : Colors.black45;
    return InkWell(
      onTap: () => setState(() => _index = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
