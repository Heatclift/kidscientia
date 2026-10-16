import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'anatomy_quiz_screen.dart';

class _AnatomyLevel {
  final String emoji;
  final String name;
  final Color cardColor;
  const _AnatomyLevel({required this.emoji, required this.name, required this.cardColor});
}

const List<_AnatomyLevel> _kLevels = [
  _AnatomyLevel(emoji: '🧠', name: 'Brain',  cardColor: Color(0xFF9C27B0)),
  _AnatomyLevel(emoji: '👁️', name: 'Eye',    cardColor: Color(0xFF2196F3)),
  _AnatomyLevel(emoji: '👂', name: 'Ear',    cardColor: Color(0xFFF4A824)),
  _AnatomyLevel(emoji: '👃', name: 'Nose',   cardColor: Color(0xFFE91E63)),
  _AnatomyLevel(emoji: '🫀', name: 'Heart',  cardColor: Color(0xFFE53935)),
  _AnatomyLevel(emoji: '🫁', name: 'Lungs',  cardColor: Color(0xFF42A5F5)),
  _AnatomyLevel(emoji: '🦷', name: 'Teeth',  cardColor: Color(0xFF78909C)),
  _AnatomyLevel(emoji: '💪', name: 'Muscle', cardColor: Color(0xFF4CAF50)),
];

class AnatomyLevelSelectScreen extends StatefulWidget {
  const AnatomyLevelSelectScreen({super.key});

  @override
  State<AnatomyLevelSelectScreen> createState() => _AnatomyLevelSelectScreenState();
}

class _AnatomyLevelSelectScreenState extends State<AnatomyLevelSelectScreen> {
  int _maxUnlocked = 1;
  Map<int, int> _stars = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt('anatomy_progress') ?? 1;
    final Map<int, int> stars = {};
    for (int i = 0; i < _kLevels.length; i++) {
      stars[i] = prefs.getInt('anatomy_stars_$i') ?? 0;
    }
    if (mounted) setState(() { _maxUnlocked = unlocked; _stars = stars; });
  }

  Future<void> _saveProgress(int completedIndex, int earnedStars) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (completedIndex + 2).clamp(1, _kLevels.length);
    if (next > _maxUnlocked) await prefs.setInt('anatomy_progress', next);
    final prev = _stars[completedIndex] ?? 0;
    if (earnedStars > prev) {
      await prefs.setInt('anatomy_stars_$completedIndex', earnedStars);
    }
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5BBFBF),
        elevation: 0,
        title: const Text('ANATOMY',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22,
                letterSpacing: 1.5, color: Colors.white)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: GridView.builder(
          itemCount: _kLevels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            final level = _kLevels[i];
            final unlocked = (i + 1) <= _maxUnlocked;
            final earnedStars = _stars[i] ?? 0;

            return GestureDetector(
              onTap: unlocked
                  ? () async {
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AnatomyQuizScreen(
                          levelIndex: i,
                          onComplete: (stars) => _saveProgress(i, stars),
                        ),
                      ));
                      _loadProgress();
                    }
                  : null,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: unlocked ? level.cardColor : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              unlocked ? level.emoji : '🔒',
                              style: const TextStyle(fontSize: 56),
                            ),
                          ),
                          Positioned(
                            top: 8, left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('LVL.${i + 1}',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 11, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (s) => Icon(
                      s < earnedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: s < earnedStars ? const Color(0xFFFFC107) : Colors.white54,
                      size: 20,
                    )),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
