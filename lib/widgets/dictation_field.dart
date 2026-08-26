import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../theme.dart';

/// Shared recogniser for the fields on one screen.
///
/// The platform allows a single recognition session at a time, so starting a
/// second while one is live fails silently — which looks exactly like a broken
/// button. Sharing one instance makes switching fields stop the previous
/// session first.
///
/// The recogniser also stops by itself: browsers end a session after a pause,
/// and errors end it too. Nothing polls for that, so [onStopped] is how the
/// field learns it is no longer listening. Without it the button sits on
/// "Stop" forever while nothing is being recorded, which is the most confusing
/// possible failure.
class DictationController {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  /// Last message from the platform, shown to the user rather than swallowed.
  String? lastError;

  void Function(String words, bool isFinal)? _onWords;
  void Function()? _onStopped;

  bool get isAvailable => _initialized;

  Future<bool> _init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError: (e) {
        lastError = e.errorMsg;
        debugPrint('Ahassu: speech error — ${e.errorMsg}');
        _onStopped?.call();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') _onStopped?.call();
      },
    );
    if (!_initialized) {
      lastError ??= 'speech recognition unavailable in this browser';
    }
    return _initialized;
  }

  Future<bool> start({
    required void Function(String words, bool isFinal) onWords,
    required void Function() onStopped,
  }) async {
    lastError = null;
    if (_speech.isListening) await _speech.stop();
    if (!await _init()) return false;

    _onWords = onWords;
    _onStopped = onStopped;
    await _speech.listen(
      onResult: (r) => _onWords?.call(r.recognizedWords, r.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        // Dictation mode keeps the session open through natural pauses, which
        // is what long spoken answers need.
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 8),
      ),
    );
    return true;
  }

  Future<void> stop() async {
    _onStopped = null;
    await _speech.stop();
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

  /// Text that is settled: what was already in the field, plus every utterance
  /// the recogniser has finalised. Results arrive as the whole current
  /// utterance rather than as a delta, so the field is rebuilt from this each
  /// time. Without it, pausing and speaking again would replace what you said
  /// first rather than continue it.
  String _committed = '';

  void _setText(String words, bool isFinal) {
    final text = _committed.isEmpty ? words : '$_committed $words';
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    if (isFinal) _committed = text;
  }

  Future<void> _toggle() async {
    if (_listening) {
      await widget.dictation.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    _committed = widget.controller.text.trimRight();
    final started = await widget.dictation.start(
      onWords: (words, isFinal) {
        if (words.isNotEmpty) _setText(words, isFinal);
      },
      onStopped: () {
        if (mounted) setState(() => _listening = false);
      },
    );

    if (!mounted) return;
    if (!started) {
      final reason = widget.dictation.lastError ?? 'unknown reason';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            'Dictation could not start ($reason). Use Chrome or Edge, and '
            'allow the microphone when the browser asks.',
          ),
        ),
      );
      return;
    }
    setState(() => _listening = true);
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
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
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
            child: Text('Listening — speak, then tap Stop. It keeps going through pauses.',
                style: TextStyle(fontSize: 12, color: kPrimaryPurple)),
          ),
      ],
    );
  }
}
