import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'geology_quiz_screen.dart';

class _GeoLevel {
  final String emoji;
  final String name;
  final Color cardColor;
  const _GeoLevel({required this.emoji, required this.name, required this.cardColor});
}

const List<_GeoLevel> _kLevels = [
  _GeoLevel(emoji: '🌋', name: 'Volcano',     cardColor: Color(0xFFE53935)),
  _GeoLevel(emoji: '💎', name: 'Diamond',     cardColor: Color(0xFF42A5F5)),
  _GeoLevel(emoji: '🟡', name: 'Gold',        cardColor: Color(0xFFFFB300)),   // ⚠️ no gold emoji
  _GeoLevel(emoji: '🟠', name: 'Copper',      cardColor: Color(0xFFEF6C00)),   // ⚠️ no copper emoji
  _GeoLevel(emoji: '⬛', name: 'Obsidian',    cardColor: Color(0xFF212121)),   // ⚠️ no obsidian emoji
  _GeoLevel(emoji: '🪨', name: 'Igneous',     cardColor: Color(0xFF8D6E63)),
  _GeoLevel(emoji: '🪨', name: 'Sedimentary', cardColor: Color(0xFF9E9D24)),
  _GeoLevel(emoji: '🪨', name: 'Metamorphic', cardColor: Color(0xFF6A1B9A)),
];

class GeologyLevelSelectScreen extends StatefulWidget {
  const GeologyLevelSelectScreen({super.key});

  @override
  State<GeologyLevelSelectScreen> createState() => _GeologyLevelSelectScreenState();
}

class _GeologyLevelSelectScreenState extends State<GeologyLevelSelectScreen> {
  int _maxUnlocked = 1;
  Map<int, int> _stars = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt('geology_progress') ?? 1;
    final Map<int, int> stars = {};
    for (int i = 0; i < _kLevels.length; i++) {
      stars[i] = prefs.getInt('geology_stars_$i') ?? 0;
    }
    if (mounted) setState(() { _maxUnlocked = unlocked; _stars = stars; });
  }

  Future<void> _saveProgress(int completedIndex, int earnedStars) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (completedIndex + 2).clamp(1, _kLevels.length);
    if (next > _maxUnlocked) await prefs.setInt('geology_progress', next);
    final prev = _stars[completedIndex] ?? 0;
    if (earnedStars > prev) await prefs.setInt('geology_stars_$completedIndex', earnedStars);
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        elevation: 0,
        title: const Text('GEOLOGY',
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
            crossAxisCount: 2, crossAxisSpacing: 14,
            mainAxisSpacing: 14, childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) {
            final level = _kLevels[i];
            final unlocked = (i + 1) <= _maxUnlocked;
            final earnedStars = _stars[i] ?? 0;

            return GestureDetector(
              onTap: unlocked
                  ? () async {
                      await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => GeologyQuizScreen(
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
                        color: unlocked ? level.cardColor : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: unlocked ? level.cardColor.withValues(alpha: 0.35) : Colors.transparent,
                            blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(unlocked ? level.emoji : '🔒',
                                style: const TextStyle(fontSize: 52)),
                          ),
                          Positioned(
                            top: 8, left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('LVL.${i + 1}',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 11, fontWeight: FontWeight.w800)),
                            ),
                          ),
                          if (unlocked)
                            Positioned(
                              bottom: 8, right: 0, left: 0,
                              child: Center(
                                child: Text(level.name,
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 12, fontWeight: FontWeight.w800)),
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
                      color: s < earnedStars ? const Color(0xFFFFC107) : Colors.white24,
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
