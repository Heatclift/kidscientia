import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'zoology_quiz_screen.dart';

// ── Level definitions ────────────────────────────────────────────────────────

class _ZoologyLevel {
  final String emoji;   // null = use image instead
  final String name;
  final Color cardColor;

  const _ZoologyLevel({
    required this.emoji,
    required this.name,
    required this.cardColor,
  });
}

const List<_ZoologyLevel> _kLevels = [
  _ZoologyLevel(emoji: '🦁', name: 'Lion',       cardColor: Color(0xFFF4A824)),
  _ZoologyLevel(emoji: '🐊', name: 'Crocodile',  cardColor: Color(0xFF4CAF50)),
  _ZoologyLevel(emoji: '🕷️', name: 'Spider',     cardColor: Color(0xFF9C27B0)),
  _ZoologyLevel(emoji: '🐋', name: 'Whale',      cardColor: Color(0xFFFF6B35)),
  _ZoologyLevel(emoji: '🐍', name: 'Snake',      cardColor: Color(0xFFCDDC39)),
  _ZoologyLevel(emoji: '🐹', name: 'Capybara',   cardColor: Color(0xFF795548)), // ⚠️ No capybara emoji — using hamster as placeholder
  _ZoologyLevel(emoji: '🐆', name: 'Cheetah',    cardColor: Color(0xFFFFEB3B)), // ⚠️ No cheetah emoji — using leopard
  _ZoologyLevel(emoji: '🦅', name: 'Eagle',      cardColor: Color(0xFFE91E8C)),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ZoologyLevelSelectScreen extends StatefulWidget {
  const ZoologyLevelSelectScreen({super.key});

  @override
  State<ZoologyLevelSelectScreen> createState() =>
      _ZoologyLevelSelectScreenState();
}

class _ZoologyLevelSelectScreenState extends State<ZoologyLevelSelectScreen> {
  int _maxUnlocked = 1;
  Map<int, int> _stars = {}; // level index → stars earned

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt('zoology_progress') ?? 1;
    final Map<int, int> stars = {};
    for (int i = 0; i < _kLevels.length; i++) {
      stars[i] = prefs.getInt('zoology_stars_$i') ?? 0;
    }
    if (mounted) setState(() { _maxUnlocked = unlocked; _stars = stars; });
  }

  Future<void> _saveProgress(int completedIndex, int earnedStars) async {
    final prefs = await SharedPreferences.getInstance();
    final next = completedIndex + 2; // 1-based next level
    if (next > _maxUnlocked) {
      await prefs.setInt('zoology_progress', next.clamp(1, _kLevels.length));
    }
    final prev = _stars[completedIndex] ?? 0;
    if (earnedStars > prev) {
      await prefs.setInt('zoology_stars_$completedIndex', earnedStars);
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
        title: const Text(
          'ZOOLOGY',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1.5,
              color: Colors.white),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoologyQuizScreen(
                            levelIndex: i,
                            onComplete: (stars) => _saveProgress(i, stars),
                          ),
                        ),
                      );
                      _loadProgress();
                    }
                  : null,
              child: Column(
                children: [
                  // ── Card ──────────────────────────────────────────────
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? level.cardColor
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
                          // Level badge
                          Positioned(
                            top: 8,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'LVL.${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Stars ─────────────────────────────────────────────
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (s) => Icon(
                      s < earnedStars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: s < earnedStars
                          ? const Color(0xFFFFC107)
                          : Colors.white54,
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
