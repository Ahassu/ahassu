import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../theme.dart';

/// A text field with a mic button that types what you say into it.
///
/// One recogniser is shared across the fields on a screen, because the
/// platform only allows one active session — starting a second while the
/// first is live fails silently, which looks exactly like a broken button.
class DictationController {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  Future<bool> ensureReady() async {
    if (_ready) return true;
    _ready = await _speech.initialize(
      onError: (e) => debugPrint('Ahassu: speech error — ${e.errorMsg}'),
    );
    return _ready;
  }

  bool get isListening => _speech.isListening;

  Future<void> stop() => _speech.stop();

  Future<void> listen(void Function(String words) onWords) async {
    await _speech.listen(onResult: (r) => onWords(r.recognizedWords));
  }
}

class DictationField extends StatefulWidget {
  final TextEditingController controller;
  final DictationController dictation;
  final String label;
  final String hint;
  final int minLines;

  const DictationField({
    super.key,
    required this.controller,
    required this.dictation,
    required this.label,
    required this.hint,
    this.minLines = 1,
  });

  @override
  State<DictationField> createState() => _DictationFieldState();
}

class _DictationFieldState extends State<DictationField> {
  bool _listening = false;

  /// What was in the field when dictation started. Results arrive as the whole
  /// utterance each time rather than as a delta, so the text is rebuilt from
  /// this base instead of appended to, which would repeat every word.
  String _base = '';

  Future<void> _toggle() async {
    if (_listening) {
      await widget.dictation.stop();
      setState(() => _listening = false);
      return;
    }

    final ready = await widget.dictation.ensureReady();
    if (!ready) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dictation is unavailable. Check the microphone permission for '
            'this browser, and note that Chrome and Edge support it best.',
          ),
        ),
      );
      return;
    }

    _base = widget.controller.text.trimRight();
    setState(() => _listening = true);
    await widget.dictation.listen((words) {
      if (words.isEmpty) return;
      widget.controller.text = _base.isEmpty ? words : '$_base $words';
      widget.controller.selection =
          TextSelection.collapsed(offset: widget.controller.text.length);
    });
  }

  @override
  void dispose() {
    if (_listening) widget.dictation.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
            const Spacer(),
            TextButton.icon(
              onPressed: _toggle,
              icon: Icon(_listening ? Icons.stop_circle_outlined : Icons.mic_none_rounded,
                  size: 18, color: _listening ? kCritical : kPrimaryPurple),
              label: Text(_listening ? 'Stop' : 'Speak',
                  style: TextStyle(color: _listening ? kCritical : kPrimaryPurple)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: null,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
        if (_listening)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Listening — speak, then tap Stop.',
                style: TextStyle(fontSize: 12, color: kPrimaryPurple)),
          ),
      ],
    );
  }
}
