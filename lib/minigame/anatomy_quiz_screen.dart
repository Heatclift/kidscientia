import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Body part data ────────────────────────────────────────────────────────────

class _BodyPart {
  final String emoji;
  final String name;
  final String riddle;       // fun clue shown to the kid
  final Color color;

  const _BodyPart({
    required this.emoji,
    required this.name,
    required this.riddle,
    required this.color,
  });
}

const List<_BodyPart> _kBodyParts = [
  _BodyPart(
    emoji: '🧠',
    name: 'Brain',
    riddle: 'I live in your head and help you think, remember, and dream. What am I?',
    color: Color(0xFF9C27B0),
  ),
  _BodyPart(
    emoji: '👁️',
    name: 'Eye',
    riddle: 'I let you see colors, faces, and all the beautiful things around you. What am I?',
    color: Color(0xFF2196F3),
  ),
  _BodyPart(
    emoji: '👂',
    name: 'Ear',
    riddle: 'I catch sounds like music, voices, and your favourite songs. What am I?',
    color: Color(0xFFF4A824),
  ),
  _BodyPart(
    emoji: '👃',
    name: 'Nose',
    riddle: 'I help you smell cookies baking and breathe fresh air. What am I?',
    color: Color(0xFFE91E63),
  ),
  _BodyPart(
    emoji: '🫀',
    name: 'Heart',
    riddle: 'I beat non-stop all day and night to pump blood all over your body. What am I?',
    color: Color(0xFFE53935),
  ),
  _BodyPart(
    emoji: '🫁',
    name: 'Lungs',
    riddle: 'Every time you breathe in, I fill up with air. Every time you breathe out, I empty. What am I?',
    color: Color(0xFF42A5F5),
  ),
  _BodyPart(
    emoji: '🦷',
    name: 'Teeth',
    riddle: 'I help you bite and chew your food. Brush me twice a day to keep me white! What am I?',
    color: Color(0xFF78909C),
  ),
  _BodyPart(
    emoji: '💪',
    name: 'Muscle',
    riddle: 'I help you run, jump, and carry heavy things. The more you exercise, the stronger I get! What am I?',
    color: Color(0xFF4CAF50),
  ),
];

// All emojis pool used to generate wrong choices
const List<String> _kAllEmojis = ['🧠','👁️','👂','👃','🫀','🫁','🦷','💪'];
const List<String> _kAllNames  = ['Brain','Eye','Ear','Nose','Heart','Lungs','Teeth','Muscle'];

// ── Star thresholds (seconds) ────────────────────────────────────────────────
const int _k3StarSec = 15;
const int _k2StarSec = 30;
const int _k1StarSec = 60;

// ── Screen ────────────────────────────────────────────────────────────────────

class AnatomyQuizScreen extends StatefulWidget {
  final int levelIndex;
  final ValueChanged<int> onComplete;

  const AnatomyQuizScreen({
    super.key,
    required this.levelIndex,
    required this.onComplete,
  });

  @override
  State<AnatomyQuizScreen> createState() => _AnatomyQuizScreenState();
}

class _AnatomyQuizScreenState extends State<AnatomyQuizScreen>
    with SingleTickerProviderStateMixin {
  late final _BodyPart _part;
  late final List<int> _choiceIndices; // indices into _kBodyParts (4 choices)

  Timer? _timer;
  int _elapsed = 0;
  int? _tappedIndex;   // index in _choiceIndices
  bool _answered = false;
  bool _timeUp = false;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _part = _kBodyParts[widget.levelIndex];

    // Build 4 unique choices including the correct one
    final correctIdx = widget.levelIndex;
    final others = List<int>.generate(_kBodyParts.length, (i) => i)
      ..remove(correctIdx)
      ..shuffle();
    _choiceIndices = ([correctIdx, others[0], others[1], others[2]])..shuffle();

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed++);
      if (_elapsed >= _k1StarSec && !_answered) {
        _timer?.cancel();
        setState(() => _timeUp = true);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showResult(false, 0);
        });
      }
    });
  }

  int get _currentStars {
    if (_elapsed <= _k3StarSec) return 3;
    if (_elapsed <= _k2StarSec) return 2;
    return 1;
  }

  void _onTap(int choicePos) {
    if (_answered || _timeUp) return;
    final tappedBodyIdx = _choiceIndices[choicePos];
    final isCorrect = tappedBodyIdx == widget.levelIndex;

    HapticFeedback.mediumImpact();
    setState(() => _tappedIndex = choicePos);

    if (isCorrect) {
      _timer?.cancel();
      _bounceCtrl.forward(from: 0);
      final stars = _currentStars;
      setState(() => _answered = true);
      widget.onComplete(stars);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _showResult(true, stars);
      });
    } else {
      // Wrong — flash red then reset
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _tappedIndex = null);
      });
    }
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
        part: _part,
        onRetry: () { Navigator.pop(context); Navigator.pop(context); },
        onNext:  () { Navigator.pop(context); Navigator.pop(context); },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Text('LVL.${widget.levelIndex + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const Spacer(),
                  // Timer badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _elapsed <= _k3StarSec
                          ? const Color(0xFF4CAF50)
                          : _elapsed <= _k2StarSec
                              ? const Color(0xFFFFC107)
                              : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('⏰', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${(_k1StarSec - _elapsed).clamp(0, _k1StarSec)}s',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Star bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StarChip(label: '1 min',  lit: _elapsed <= _k1StarSec),
                  _StarChip(label: '30 sec', lit: _elapsed <= _k2StarSec),
                  _StarChip(label: '15 sec', lit: _elapsed <= _k3StarSec),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Quiz card ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      children: [
                        // Riddle text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _part.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: _part.color.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Text(
                            _part.riddle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                                color: Colors.black87),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text('Tap the correct answer!',
                            style: TextStyle(fontSize: 13,
                                color: Colors.grey, fontWeight: FontWeight.w600)),

                        const SizedBox(height: 16),

                        // Choice grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(_choiceIndices.length, (pos) {
                              final bodyIdx = _choiceIndices[pos];
                              final isCorrect = bodyIdx == widget.levelIndex;
                              final isTapped = _tappedIndex == pos;

                              Color bg = const Color(0xFFF5F5F5);
                              Color border = Colors.transparent;

                              if (isTapped) {
                                bg = isCorrect
                                    ? const Color(0xFFDCF8DC)
                                    : const Color(0xFFFFE0E0);
                                border = isCorrect
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935);
                              } else if (_answered && isCorrect) {
                                bg = const Color(0xFFDCF8DC);
                                border = const Color(0xFF4CAF50);
                              }

                              final isAnimated = _answered && isCorrect;

                              return GestureDetector(
                                onTap: () => _onTap(pos),
                                child: ScaleTransition(
                                  scale: isAnimated ? _bounceAnim : const AlwaysStoppedAnimation(1.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: border, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.07),
                                          blurRadius: 6, offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(_kAllEmojis[bodyIdx],
                                            style: const TextStyle(fontSize: 46)),
                                        const SizedBox(height: 6),
                                        Text(_kAllNames[bodyIdx],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Star chip ─────────────────────────────────────────────────────────────────

class _StarChip extends StatelessWidget {
  final String label;
  final bool lit;
  const _StarChip({required this.label, required this.lit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(lit ? Icons.star_rounded : Icons.star_outline_rounded,
            color: lit ? const Color(0xFFFFC107) : Colors.white38, size: 22),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: lit ? Colors.white : Colors.white38,
                fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Result sheet ──────────────────────────────────────────────────────────────

class _ResultSheet extends StatelessWidget {
  final bool correct;
  final int stars;
  final _BodyPart part;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  const _ResultSheet({
    required this.correct,
    required this.stars,
    required this.part,
    required this.onRetry,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(correct ? '🎉' : '😢', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 10),
          Text(
            correct ? 'Correct!' : 'The answer was ${part.name}! ${part.emoji}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars ? const Color(0xFFFFC107) : Colors.grey.shade300,
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
              child: const Text('Back to Levels',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: Color(0xFF5BBFBF))),
            ),
          ),
        ],
      ),
    );
  }
}
