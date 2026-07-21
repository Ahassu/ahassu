import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_question.dart';
import '../providers/providers.dart';

class QuizScreen extends ConsumerWidget {
  final String pathId;
  final String pathTitle;

  const QuizScreen({super.key, required this.pathId, required this.pathTitle});

  Future<void> _addQuestion(BuildContext context, WidgetRef ref) async {
    final questionController = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());
    var correctIndex = 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Quiz Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: questionController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 12),
                const Text('Options (select the correct one):', style: TextStyle(fontSize: 12, color: Colors.black54)),
                for (var i = 0; i < 4; i++)
                  Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: correctIndex,
                        onChanged: (v) => setState(() => correctIndex = v!),
                      ),
                      Expanded(
                        child: TextField(
                          controller: optionControllers[i],
                          decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
          ],
        ),
      ),
    );

    if (result == true) {
      final options = optionControllers.map((c) => c.text.trim()).toList();
      if (questionController.text.trim().isEmpty || options.any((o) => o.isEmpty)) return;
      await ref.read(firestoreServiceProvider).addQuizQuestion(
            learningPathId: pathId,
            question: questionController.text.trim(),
            options: options,
            correctIndex: correctIndex,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(quizQuestionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Quiz · $pathTitle')),
      body: questionsAsync.when(
        data: (all) {
          final questions = all.where((q) => q.learningPathId == pathId).toList();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: questions.isEmpty
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => _QuizRunner(pathTitle: pathTitle, questions: questions)),
                                  ),
                          icon: const Icon(Icons.play_arrow),
                          label: Text('Take Quiz (${questions.length})'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _addQuestion(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: questions.isEmpty
                        ? const Center(
                            child: Text('No quiz questions yet. Tap Add to write one.', style: TextStyle(color: Colors.black45)),
                          )
                        : ListView.separated(
                            itemCount: questions.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final q = questions[i];
                              return Card(
                                child: ListTile(
                                  title: Text(q.question),
                                  subtitle: Text('Correct: ${q.options[q.correctIndex]}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.black38),
                                    onPressed: () => ref.read(firestoreServiceProvider).deleteQuizQuestion(q.id),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _QuizRunner extends StatefulWidget {
  final String pathTitle;
  final List<QuizQuestion> questions;

  const _QuizRunner({required this.pathTitle, required this.questions});

  @override
  State<_QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<_QuizRunner> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  void _submit() {
    if (_selected == null) return;
    setState(() {
      _answered = true;
      if (_selected == widget.questions[_index].correctIndex) _score += 1;
    });
  }

  void _next() {
    setState(() {
      _index += 1;
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
              const SizedBox(height: 16),
              Text('Score: $_score / ${widget.questions.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
            ],
          ),
        ),
      );
    }

    final question = widget.questions[_index];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_index + 1}/${widget.questions.length}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++)
                Card(
                  color: _answered
                      ? (i == question.correctIndex
                          ? const Color(0xFFE3F5E7)
                          : (i == _selected ? const Color(0xFFFCE4E4) : null))
                      : null,
                  child: RadioListTile<int>(
                    title: Text(question.options[i]),
                    value: i,
                    groupValue: _selected,
                    onChanged: _answered ? null : (v) => setState(() => _selected = v),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _answered ? _next : _submit,
                  child: Text(_answered
                      ? (_index + 1 == widget.questions.length ? 'See Results' : 'Next Question')
                      : 'Submit Answer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
