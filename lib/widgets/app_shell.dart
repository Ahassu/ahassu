import 'package:flutter/material.dart';

import '../screens/notes_screen.dart';
import '../screens/plan_screen.dart';
import '../theme.dart';

/// Two destinations, deliberately. The plan is the app; notes are where the
/// scripted answers get rewritten in the user's own words.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    PlanScreen(),
    NotesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: kLightPurple,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_rounded),
            label: 'My Notes',
          ),
        ],
      ),
    );
  }
}
