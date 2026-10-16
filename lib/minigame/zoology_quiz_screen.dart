import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Animal data ──────────────────────────────────────────────────────────────

class _Animal {
  final String emoji;
  final String name;

  const _Animal({required this.emoji, required this.name});
}

const List<_Animal> _kAnimals = [
  _Animal(emoji: '🦁', name: 'Lion'),
  _Animal(emoji: '🐊', name: 'Crocodile'),
  _Animal(emoji: '🕷️', name: 'Spider'),
  _Animal(emoji: '🐋', name: 'Whale'),
  _Animal(emoji: '🐍', name: 'Snake'),
  _Animal(emoji: '🐹', name: 'Capybara'),  // ⚠️ placeholder emoji
  _Animal(emoji: '🐆', name: 'Cheetah'),   // ⚠️ placeholder emoji
  _Animal(emoji: '🦅', name: 'Eagle'),
];

// ── Star thresholds (seconds elapsed) ───────────────────────────────────────
const int _k3StarSec = 30;
const int _k2StarSec = 60;
const int _k1StarSec = 120;

// ── Screen ───────────────────────────────────────────────────────────────────

class ZoologyQuizScreen extends StatefulWidget {
  final int levelIndex;
  final ValueChanged<int> onComplete;

  const ZoologyQuizScreen({
    super.key,
    required this.levelIndex,
    required this.onComplete,
  });

  @override
  State<ZoologyQuizScreen> createState() => _ZoologyQuizScreenState();
}

class _ZoologyQuizScreenState extends State<ZoologyQuizScreen> {
  late final _Animal _animal;
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _elapsed = 0;
  bool _answered = false;
  bool _correct = false;
  bool _timeUp = false;
  bool _shakeWrong = false;

  @override
  void initState() {
    super.initState();
    _animal = _kAnimals[widget.levelIndex];
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= _k1StarSec && !_answered) {
        _timer?.cancel();
        setState(() => _timeUp = true);
        _showResult(false, 0);
      }
    });
  }

  int get _currentStars {
    if (_elapsed <= _k3StarSec) return 3;
    if (_elapsed <= _k2StarSec) return 2;
    return 1;
  }

  void _submit() {
    if (_answered || _timeUp) return;
    final input = _textCtrl.text.trim().toLowerCase();
    final answer = _animal.name.toLowerCase();

    if (input.isEmpty) return;

    final isCorrect = input == answer;
    HapticFeedback.mediumImpact();

    if (!isCorrect) {
      // Shake feedback then clear
      setState(() => _shakeWrong = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() => _shakeWrong = false);
        _textCtrl.clear();
        _focusNode.requestFocus();
      });
      return;
    }

    _timer?.cancel();
    final stars = _currentStars;
    setState(() {
      _answered = true;
      _correct = true;
    });
    widget.onComplete(stars);

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _showResult(true, stars);
    });
  }

  void _showResult(bool correct, int stars) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(
        correct: correct,
        stars: stars,
        animalName: _animal.name,
        onRetry: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onNext: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: bottomInset + 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  _TopBar(levelIndex: widget.levelIndex, animal: _animal),
                  const SizedBox(height: 8),
                  _StarTimerBar(elapsed: _elapsed),
                  const SizedBox(height: 8),
                  _TimerDisplay(elapsed: _elapsed, timeUp: _timeUp),
                  const SizedBox(height: 12),
                  _QuizCard(
                    animal: _animal,
                    textCtrl: _textCtrl,
                    focusNode: _focusNode,
                    answered: _answered,
                    correct: _correct,
                    shakeWrong: _shakeWrong,
                    timeUp: _timeUp,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int levelIndex;
  final _Animal animal;
  const _TopBar({required this.levelIndex, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(
                  color: Colors.white24, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const Spacer(),
          Text(
            'LVL.${levelIndex + 1}',
            style: const TextStyle(
                color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const Spacer(),
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: Text(animal.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star + progress bar ───────────────────────────────────────────────────────

class _StarTimerBar extends StatelessWidget {
  final int elapsed;
  const _StarTimerBar({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final progress = (elapsed / _k1StarSec).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StarLabel(label: '2 Min', lit: elapsed <= _k1StarSec),
              _StarLabel(label: '1 Min', lit: elapsed <= _k2StarSec),
              _StarLabel(label: '30 Sec', lit: elapsed <= _k3StarSec),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(
                elapsed <= _k3StarSec
                    ? const Color(0xFF4CAF50)
                    : elapsed <= _k2StarSec
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFE53935),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarLabel extends StatelessWidget {
  final String label;
  final bool lit;
  const _StarLabel({required this.label, required this.lit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          lit ? Icons.star_rounded : Icons.star_outline_rounded,
          color: lit ? const Color(0xFFFFC107) : Colors.white38,
          size: 28,
        ),
        Text(label,
            style: TextStyle(
                color: lit ? Colors.white : Colors.white38,
                fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Timer display ─────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final int elapsed;
  final bool timeUp;
  const _TimerDisplay({required this.elapsed, required this.timeUp});

  @override
  Widget build(BuildContext context) {
    final remaining = (_k1StarSec - elapsed).clamp(0, _k1StarSec);
    final mins = remaining ~/ 60;
    final secs = remaining % 60;
    final label = timeUp
        ? "Time's up!"
        : '${mins > 0 ? "$mins:" : ""}${secs.toString().padLeft(2, "0")} seconds';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⏰', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: timeUp ? const Color(0xFFFF5252) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Quiz card ─────────────────────────────────────────────────────────────────

class _QuizCard extends StatelessWidget {
  final _Animal animal;
  final TextEditingController textCtrl;
  final FocusNode focusNode;
  final bool answered;
  final bool correct;
  final bool shakeWrong;
  final bool timeUp;
  final VoidCallback onSubmit;

  const _QuizCard({
    required this.animal,
    required this.textCtrl,
    required this.focusNode,
    required this.answered,
    required this.correct,
    required this.shakeWrong,
    required this.timeUp,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What Animal is this?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // Animal emoji
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: answered && correct
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF5BBFBF),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    timeUp ? '❓' : animal.emoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Text input
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                transform: Matrix4.translationValues(
                    shakeWrong ? 6 : 0, 0, 0),
                child: TextField(
                  controller: textCtrl,
                  focusNode: focusNode,
                  enabled: !answered && !timeUp,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmit(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Type the animal name…',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: shakeWrong
                        ? const Color(0xFFFFE0E0)
                        : answered && correct
                            ? const Color(0xFFDCF8DC)
                            : const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF5BBFBF), width: 2),
                    ),
                    suffixIcon: shakeWrong
                        ? const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFE53935),
                          )
                        : answered && correct
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF4CAF50),
                              )
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!answered && !timeUp) ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BBFBF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Submit',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result sheet ──────────────────────────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  final bool correct;
  final int stars;
  final String animalName;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  const _ResultSheet({
    required this.correct,
    required this.stars,
    required this.animalName,
    required this.onRetry,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(correct ? '🎉' : '😢',
              style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            correct ? 'Correct!' : 'It was a $animalName!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars
                    ? const Color(0xFFFFC107)
                    : Colors.grey.shade300,
                size: 44,
              ),
            )),
          ),
          const SizedBox(height: 24),
          if (!correct) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BBFBF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onNext,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFF5BBFBF), width: 2),
              ),
              child: const Text(
                'Back to Levels',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5BBFBF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
