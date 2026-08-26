import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/study_area.dart';
import '../providers/providers.dart';
import '../widgets/dictation_field.dart';

/// Write or rewrite one question card. Passing [existing] edits that card;
/// passing null adds a new one to the subtopic.
class CardEditorScreen extends ConsumerStatefulWidget {
  final StudyArea area;
  final String subtopicId;
  final String subtopicTitle;
  final StudyCard? existing;

  const CardEditorScreen({
    super.key,
    required this.area,
    required this.subtopicId,
    required this.subtopicTitle,
    this.existing,
  });

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  late final TextEditingController _question;
  late final TextEditingController _answer;
  final _dictation = DictationController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.existing?.question ?? '');
    _answer = TextEditingController(text: widget.existing?.answer ?? '');
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final question = _question.text.trim();
    final answer = _answer.text.trim();
    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A card needs both a question and an answer.')),
      );
      return;
    }

    setState(() => _saving = true);
    final service = ref.read(firestoreServiceProvider);
    final existing = widget.existing;
    if (existing == null) {
      await service.addCard(widget.area, widget.subtopicId,
          question: question, answer: answer);
    } else {
      await service.saveCard(widget.area, widget.subtopicId, existing,
          question: question, answer: answer);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New question' : 'Edit question'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Text(widget.subtopicTitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 18),
          DictationField(
            controller: _question,
            dictation: _dictation,
            label: 'QUESTION',
            hint: 'How the interviewer would ask it',
            minLines: 2,
          ),
          const SizedBox(height: 20),
          DictationField(
            controller: _answer,
            dictation: _dictation,
            label: 'ANSWER',
            hint: 'What you would say back, in your own words',
            minLines: 8,
          ),
          const SizedBox(height: 16),
          const Text(
            'Say it out loud and let the mic write it down — reading back your '
            'own wording is a better rehearsal than reading mine.',
            style: TextStyle(fontSize: 12.5, color: Colors.black45, height: 1.4),
          ),
        ],
      ),
    );
  }
}
