import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _Rock {
  final String emoji;
  final String name;
  final String riddle;
  final Color color;
  const _Rock({required this.emoji, required this.name, required this.riddle, required this.color});
}

const List<_Rock> _kRocks = [
  _Rock(
    emoji: '🌋', name: 'Volcano',
    riddle: 'I am a mountain that can shoot out hot melted rock called lava! People can see me erupt from far away. What am I?',
    color: Color(0xFFE53935),
  ),
  _Rock(
    emoji: '💎', name: 'Diamond',
    riddle: 'I am the hardest natural material on Earth. People put me on rings and jewellery because I sparkle so beautifully. What am I?',
    color: Color(0xFF42A5F5),
  ),
  _Rock(
    emoji: '🟡', name: 'Gold',
    riddle: 'I am a shiny yellow metal found deep in the ground. Kings and queens wore me as crowns and jewellery. What am I?',
    color: Color(0xFFFFB300),
  ),
  _Rock(
    emoji: '🟠', name: 'Copper',
    riddle: 'I am a reddish-orange metal used to make coins and electrical wires. I turn green when I get old and wet. What am I?',
    color: Color(0xFFEF6C00),
  ),
  _Rock(
    emoji: '⬛', name: 'Obsidian',
    riddle: 'I am a shiny black rock formed when lava cools down very quickly. Ancient people used me to make sharp tools and arrowheads. What am I?',
    color: Color(0xFF424242),
  ),
  _Rock(
    emoji: '🪨', name: 'Igneous',
    riddle: 'I am a type of rock born from cooling magma or lava. My name comes from the Latin word for fire! What type of rock am I?',
    color: Color(0xFF8D6E63),
  ),
  _Rock(
    emoji: '🪨', name: 'Sedimentary',
    riddle: 'I am made of tiny bits of sand, shells, and mud that were pressed together over millions of years. Fossils are often found inside me! What type of rock am I?',
    color: Color(0xFF9E9D24),
  ),
  _Rock(
    emoji: '🪨', name: 'Metamorphic',
    riddle: 'I started as one type of rock but heat and pressure deep underground changed me into something new. My name means "changed form". What type of rock am I?',
    color: Color(0xFF6A1B9A),
  ),
];

const List<String> _kAllEmojis = ['🌋','💎','🟡','🟠','⬛','🪨','🪨','🪨'];
const List<String> _kAllNames  = ['Volcano','Diamond','Gold','Copper','Obsidian','Igneous','Sedimentary','Metamorphic'];

const int _k3StarSec = 15;
const int _k2StarSec = 30;
const int _k1StarSec = 60;

class GeologyQuizScreen extends StatefulWidget {
  final int levelIndex;
  final ValueChanged<int> onComplete;
  const GeologyQuizScreen({super.key, required this.levelIndex, required this.onComplete});

  @override
  State<GeologyQuizScreen> createState() => _GeologyQuizScreenState();
}

class _GeologyQuizScreenState extends State<GeologyQuizScreen>
    with SingleTickerProviderStateMixin {
  late final _Rock _rock;
  late final List<int> _choiceIndices;

  Timer? _timer;
  int _elapsed = 0;
  int? _tappedIndex;
  bool _answered = false;
  bool _timeUp = false;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _rock = _kRocks[widget.levelIndex];
    final others = List<int>.generate(_kRocks.length, (i) => i)
      ..remove(widget.levelIndex)
      ..shuffle();
    _choiceIndices = ([widget.levelIndex, others[0], others[1], others[2]])..shuffle();

    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.3)
        .animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));

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

  void _onTap(int pos) {
    if (_answered || _timeUp) return;
    final isCorrect = _choiceIndices[pos] == widget.levelIndex;
    HapticFeedback.mediumImpact();
    setState(() => _tappedIndex = pos);

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
        correct: correct, stars: stars, rock: _rock,
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
    final remaining = (_k1StarSec - _elapsed).clamp(0, _k1StarSec);
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                  const Spacer(),
                  Text('LVL.${widget.levelIndex + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _elapsed <= _k3StarSec ? const Color(0xFF4CAF50)
                          : _elapsed <= _k2StarSec ? const Color(0xFFFFC107)
                          : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Text('⏰', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('${remaining}s',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 14)),
                    ]),
                  ),
                ],
              ),
            ),

            // Star bar
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

            // Quiz card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4E342E),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: _rock.color.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: _rock.color.withValues(alpha: 0.2),
                          blurRadius: 20, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      children: [
                        // Riddle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _rock.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _rock.color.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Text(
                            _rock.riddle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                height: 1.5, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('Tap the correct answer!',
                            style: TextStyle(fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 14),

                        // Choice grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(_choiceIndices.length, (pos) {
                              final idx = _choiceIndices[pos];
                              final isCorrect = idx == widget.levelIndex;
                              final isTapped = _tappedIndex == pos;

                              Color bg = const Color(0xFF5D4037);
                              Color border = Colors.transparent;
                              if (isTapped) {
                                bg = isCorrect ? const Color(0xFF1B5E20) : const Color(0xFF7F0000);
                                border = isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
                              } else if (_answered && isCorrect) {
                                bg = const Color(0xFF1B5E20);
                                border = const Color(0xFF4CAF50);
                              }

                              return GestureDetector(
                                onTap: () => _onTap(pos),
                                child: ScaleTransition(
                                  scale: (_answered && isCorrect)
                                      ? _bounceAnim
                                      : const AlwaysStoppedAnimation(1.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: border, width: 2.5),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(_kAllEmojis[idx], style: const TextStyle(fontSize: 44)),
                                        const SizedBox(height: 6),
                                        Text(_kAllNames[idx],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12,
                                                fontWeight: FontWeight.w700, color: Colors.white)),
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

class _StarChip extends StatelessWidget {
  final String label;
  final bool lit;
  const _StarChip({required this.label, required this.lit});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(lit ? Icons.star_rounded : Icons.star_outline_rounded,
          color: lit ? const Color(0xFFFFC107) : Colors.white24, size: 22),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
          color: lit ? Colors.white : Colors.white24,
          fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _ResultSheet extends StatelessWidget {
  final bool correct;
  final int stars;
  final _Rock rock;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  const _ResultSheet({required this.correct, required this.stars, required this.rock,
      required this.onRetry, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(color: const Color(0xFF4E342E), borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(correct ? '🎉' : '😢', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 10),
          Text(
            correct ? 'Correct!' : 'It was ${rock.name}! ${rock.emoji}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < stars ? const Color(0xFFFFC107) : Colors.white24, size: 44),
            )),
          ),
          const SizedBox(height: 24),
          if (!correct) ...[
            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5BBFBF), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(width: double.infinity,
            child: OutlinedButton(
              onPressed: onNext,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFF5BBFBF), width: 2),
              ),
              child: const Text('Back to Levels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF5BBFBF))),
            ),
          ),
        ],
      ),
    );
  }
}
