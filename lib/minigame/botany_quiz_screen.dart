import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Question data ────────────────────────────────────────────────────────────

class _Question {
  final String emoji;
  final String question;
  final List<String> choices;
  final int correctIndex;

  const _Question({
    required this.emoji,
    required this.question,
    required this.choices,
    required this.correctIndex,
  });
}

const List<List<_Question>> _kLevels = [
  // ── Level 1 – What Plants Need ───────────────────────────────────────────
  [
    _Question(
      emoji: '☀️',
      question: 'What do plants need to make their food?',
      choices: ['Sunlight', 'Candy', 'Rocks', 'Plastic'],
      correctIndex: 0,
    ),
    _Question(
      emoji: '💧',
      question: 'What do plants drink to stay alive?',
      choices: ['Juice', 'Milk', 'Water', 'Soda'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🌱',
      question: 'Where do most plants grow?',
      choices: ['In the sky', 'In the ocean', 'In soil', 'On clouds'],
      correctIndex: 2,
    ),
  ],

  // ── Level 2 – Plant Parts ────────────────────────────────────────────────
  [
    _Question(
      emoji: '🌿',
      question: 'Which part holds the plant in the ground?',
      choices: ['Leaves', 'Flower', 'Roots', 'Seeds'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🪴',
      question: 'Which part carries water up to the leaves?',
      choices: ['Stem', 'Petal', 'Seed', 'Fruit'],
      correctIndex: 0,
    ),
    _Question(
      emoji: '🍃',
      question: 'Where does a plant mostly make its food?',
      choices: ['Roots', 'Stem', 'Leaves', 'Flower'],
      correctIndex: 2,
    ),
  ],

  // ── Level 3 – Types of Plants ────────────────────────────────────────────
  [
    _Question(
      emoji: '🌵',
      question: 'Which plant lives in the hot desert?',
      choices: ['Cactus', 'Lily', 'Oak tree', 'Seaweed'],
      correctIndex: 0,
    ),
    _Question(
      emoji: '🌻',
      question: 'Which of these is a flowering plant?',
      choices: ['Mushroom', 'Fern', 'Sunflower', 'Moss'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🌊',
      question: 'What do we call plants that live in water?',
      choices: ['Desert plants', 'Aquatic plants', 'Rock plants', 'Air plants'],
      correctIndex: 1,
    ),
  ],

  // ── Level 4 – Seeds & Fruits ─────────────────────────────────────────────
  [
    _Question(
      emoji: '🍎',
      question: 'What grows inside a fruit?',
      choices: ['Leaves', 'Water', 'Seeds', 'Roots'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🌬️',
      question: 'How do dandelion seeds travel far away?',
      choices: ['They swim', 'The wind blows them', 'They jump', 'They drive'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🌰',
      question: 'What does a seed grow into?',
      choices: ['A rock', 'A cloud', 'A new plant', 'A river'],
      correctIndex: 2,
    ),
  ],

  // ── Level 5 – Leaves ─────────────────────────────────────────────────────
  [
    _Question(
      emoji: '🍀',
      question: 'What colour are most healthy leaves?',
      choices: ['Purple', 'Green', 'Orange', 'Blue'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🌞',
      question: 'Leaves use sunlight to do what?',
      choices: ['Sleep', 'Make food', 'Play music', 'Drink milk'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🍂',
      question: 'Why do some leaves turn red and orange in autumn?',
      choices: ['They are sick', 'They stop making green colour', 'They are on fire', 'They get painted'],
      correctIndex: 1,
    ),
  ],

  // ── Level 6 – Flowers & Pollination ─────────────────────────────────────
  [
    _Question(
      emoji: '🌸',
      question: 'What do flowers make that becomes new plants?',
      choices: ['Honey', 'Seeds', 'Leaves', 'Rocks'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🐝',
      question: 'Which animal is the most helpful for pollinating flowers?',
      choices: ['Lion', 'Fish', 'Bee', 'Elephant'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🌼',
      question: 'What is the yellow powder inside flowers called?',
      choices: ['Sugar', 'Salt', 'Pollen', 'Sand'],
      correctIndex: 2,
    ),
  ],

  // ── Level 7 – Roots ──────────────────────────────────────────────────────
  [
    _Question(
      emoji: '🥕',
      question: 'Which vegetable is actually the root of the plant?',
      choices: ['Lettuce', 'Tomato', 'Carrot', 'Corn'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '💪',
      question: 'What is one important job of roots?',
      choices: ['Making flowers', 'Keeping the plant from falling over', 'Making seeds', 'Growing leaves'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🚿',
      question: 'What do roots absorb from the soil?',
      choices: ['Sunlight', 'Air', 'Water and nutrients', 'Seeds'],
      correctIndex: 2,
    ),
  ],

  // ── Level 8 – Plant Life Cycle ───────────────────────────────────────────
  [
    _Question(
      emoji: '🔄',
      question: 'What is the very first stage of a plant\'s life?',
      choices: ['Flower', 'Fruit', 'Seed', 'Tree'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🌱',
      question: 'What do we call a very young plant that just sprouted?',
      choices: ['A seedling', 'A boulder', 'A mushroom', 'A cloud'],
      correctIndex: 0,
    ),
    _Question(
      emoji: '🌳',
      question: 'What does a plant produce when it is fully grown?',
      choices: ['Rainbows', 'Flowers and fruits', 'Clouds', 'Thunder'],
      correctIndex: 1,
    ),
  ],

  // ── Level 9 – Photosynthesis ─────────────────────────────────────────────
  [
    _Question(
      emoji: '😮‍💨',
      question: 'What useful gas do plants release into the air?',
      choices: ['Carbon dioxide', 'Smoke', 'Oxygen', 'Helium'],
      correctIndex: 2,
    ),
    _Question(
      emoji: '🏭',
      question: 'What gas do plants absorb to make food?',
      choices: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Steam'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🌿',
      question: 'What is the green stuff inside leaves that captures sunlight?',
      choices: ['Ketchup', 'Chlorophyll', 'Honey', 'Juice'],
      correctIndex: 1,
    ),
  ],

  // ── Level 10 – Expert Botanist ───────────────────────────────────────────
  [
    _Question(
      emoji: '🔬',
      question: 'What do we call a scientist who studies plants?',
      choices: ['Zoologist', 'Botanist', 'Chef', 'Astronaut'],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🌍',
      question: 'Why are plants important for all living things on Earth?',
      choices: [
        'They make noise',
        'They produce oxygen and food',
        'They build houses',
        'They drive cars',
      ],
      correctIndex: 1,
    ),
    _Question(
      emoji: '🏆',
      question: 'What is the process called when plants make food using sunlight?',
      choices: ['Digestion', 'Hibernation', 'Photosynthesis', 'Migration'],
      correctIndex: 2,
    ),
  ],
];

// ── Screen ───────────────────────────────────────────────────────────────────

class BotanyQuizScreen extends StatefulWidget {
  final int level; // 1-based
  final VoidCallback onLevelComplete;

  const BotanyQuizScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
  });

  @override
  State<BotanyQuizScreen> createState() => _BotanyQuizScreenState();
}

class _BotanyQuizScreenState extends State<BotanyQuizScreen>
    with TickerProviderStateMixin {
  late final List<_Question> _questions;
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _questions = _kLevels[widget.level - 1];

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _answer(int index) {
    if (_answered) return;
    final correct = index == _questions[_current].correctIndex;

    setState(() {
      _selected = index;
      _answered = true;
      if (correct) _score++;
    });

    HapticFeedback.mediumImpact();
    if (correct) _bounceCtrl.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_current + 1 < _questions.length) {
        setState(() {
          _current++;
          _selected = null;
          _answered = false;
        });
      } else {
        setState(() => _finished = true);
        if (_score == _questions.length) widget.onLevelComplete();
      }
    });
  }

  int get _stars {
    if (_score == _questions.length) return 3;
    if (_score >= (_questions.length / 2).ceil()) return 2;
    if (_score > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        title: Text('Botany — Level ${widget.level}',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: _finished ? _ResultView(score: _score, total: _questions.length, stars: _stars, onRetry: () {
        setState(() {
          _current = 0;
          _score = 0;
          _selected = null;
          _answered = false;
          _finished = false;
        });
      }, onExit: () => Navigator.pop(context)) : _QuizView(
        question: _questions[_current],
        questionIndex: _current,
        total: _questions.length,
        selected: _selected,
        answered: _answered,
        bounceAnim: _bounceAnim,
        onAnswer: _answer,
      ),
    );
  }
}

// ── Quiz view ─────────────────────────────────────────────────────────────────

class _QuizView extends StatelessWidget {
  final _Question question;
  final int questionIndex;
  final int total;
  final int? selected;
  final bool answered;
  final Animation<double> bounceAnim;
  final ValueChanged<int> onAnswer;

  const _QuizView({
    required this.question,
    required this.questionIndex,
    required this.total,
    required this.selected,
    required this.answered,
    required this.bounceAnim,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: i == questionIndex ? 24 : 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: i < questionIndex
                    ? const Color(0xFF4CAF50)
                    : i == questionIndex
                        ? const Color(0xFF81C784)
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            )),
          ),
          const SizedBox(height: 32),

          // Emoji
          ScaleTransition(
            scale: answered && selected == question.correctIndex
                ? bounceAnim
                : const AlwaysStoppedAnimation(1.0),
            child: Text(question.emoji, style: const TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, height: 1.4),
          ),
          const SizedBox(height: 32),

          // Choices grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(question.choices.length, (i) {
                final isCorrect = i == question.correctIndex;
                final isSelected = i == selected;

                Color bg = Colors.white;
                Color border = Colors.grey.shade300;
                Color text = Colors.black87;

                if (answered) {
                  if (isCorrect) {
                    bg = const Color(0xFFDCF8DC);
                    border = const Color(0xFF4CAF50);
                    text = const Color(0xFF2E7D32);
                  } else if (isSelected) {
                    bg = const Color(0xFFFFE0E0);
                    border = const Color(0xFFE53935);
                    text = const Color(0xFFB71C1C);
                  }
                }

                return GestureDetector(
                  onTap: () => onAnswer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          question.choices[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: text,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result view ───────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final int stars;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _ResultView({
    required this.score,
    required this.total,
    required this.stars,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = score == total;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(perfect ? '🎉' : '😊', style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              perfect ? 'Perfect!' : 'Good try!',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '$score out of $total correct',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: i < stars ? const Color(0xFFFFC107) : Colors.grey.shade300,
                  size: 48,
                ),
              )),
            ),
            const SizedBox(height: 36),

            if (!perfect) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onExit,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                child: Text(
                  perfect ? 'Back to Map' : 'Back to Map',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4CAF50)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
