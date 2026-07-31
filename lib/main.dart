import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'providers/providers.dart';
import 'theme.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: AhassuApp()));
}

class AhassuApp extends ConsumerStatefulWidget {
  const AhassuApp({super.key});

  @override
  ConsumerState<AhassuApp> createState() => _AhassuAppState();
}

class _AhassuAppState extends ConsumerState<AhassuApp> {
  @override
  void initState() {
    super.initState();
    final service = ref.read(firestoreServiceProvider);
    // Fire-and-forget, but never silently: a seed sync that fails (a denied
    // Firestore rule, say) leaves the app showing a stale curriculum with
    // nothing on screen to say why.
    service.syncSeedData().catchError(
        (Object e) => debugPrint('Ahassu: seed sync failed — $e'));
    service.seedGuideNotesIfMissing().catchError(
        (Object e) => debugPrint('Ahassu: guide note seed failed — $e'));
    service.seedInterviewPrepNoteIfMissing().catchError(
        (Object e) => debugPrint('Ahassu: interview note seed failed — $e'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahassu',
      debugShowCheckedModeBanner: false,
      theme: buildAhassuTheme(),
      home: const AppShell(),
    );
  }
}
