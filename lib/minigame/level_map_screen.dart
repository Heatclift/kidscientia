import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'botany_quiz_screen.dart';

// Level positions as (left%, top%) fractions of the map area.
// Winding snake path: starts bottom-right, zigzags up to top-right.
const List<Offset> _kLevelPositions = [
  Offset(0.72, 0.91), // 1  – bottom-right
  Offset(0.38, 0.80), // 2
  Offset(0.58, 0.68), // 3
  Offset(0.22, 0.57), // 4
  Offset(0.48, 0.47), // 5
  Offset(0.18, 0.38), // 6
  Offset(0.62, 0.30), // 7
  Offset(0.46, 0.20), // 8
  Offset(0.22, 0.11), // 9
  Offset(0.65, 0.03), // 10 – top-right
];

class LevelMapScreen extends StatefulWidget {
  final String category;   // e.g. "BOTANY"
  final String? mapAsset;  // e.g. "assets/images/maps/botany_map.png" — null = placeholder

  const LevelMapScreen({
    super.key,
    required this.category,
    this.mapAsset,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  int _maxUnlocked = 1; // level 1 is always unlocked

  String get _prefKey => '${widget.category.toLowerCase()}_progress';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefKey) ?? 1;
    if (mounted) setState(() => _maxUnlocked = saved);
  }

  // Call this from a level screen when the user completes a level.
  Future<void> _unlockNext(int completedLevel) async {
    final next = completedLevel + 1;
    if (next > _maxUnlocked && next <= 10) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, next);
      if (mounted) setState(() => _maxUnlocked = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            children: [
              // ── Map background ──────────────────────────────────────────
              Positioned.fill(
                child: widget.mapAsset != null
                    ? Image.asset(widget.mapAsset!, fit: BoxFit.cover)
                    : _MapPlaceholder(),
              ),

              // ── Level nodes ─────────────────────────────────────────────
              for (int i = 0; i < 10; i++)
                _LevelNode(
                  level: i + 1,
                  unlocked: (i + 1) <= _maxUnlocked,
                  position: Offset(
                    _kLevelPositions[i].dx * w,
                    _kLevelPositions[i].dy * h,
                  ),
                  onTap: (i + 1) <= _maxUnlocked
                      ? () => _openLevel(context, i + 1)
                      : null,
                ),
            ],
          );
        },
      ),
    );
  }

  void _openLevel(BuildContext context, int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BotanyQuizScreen(
          level: level,
          onLevelComplete: () => _unlockNext(level),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Placeholder background — remove once the real map image is dropped in
// ──────────────────────────────────────────────────────────────────────────────
class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5FA85A), // forest green top
            Color(0xFF89C46A), // lighter mid
            Color(0xFFC8E6A0), // pale green bottom
          ],
        ),
      ),
      child: Center(
        child: Text(
          'Map image goes here\n(drop your PNG into assets/images/maps/)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Single level node (circle + stars)
// ──────────────────────────────────────────────────────────────────────────────
class _LevelNode extends StatelessWidget {
  final int level;
  final bool unlocked;
  final Offset position; // centre point in pixels
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.unlocked,
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double nodeSize = 52;
    const double starRowWidth = 72;

    return Positioned(
      left: position.dx - nodeSize / 2,
      top: position.dy - nodeSize / 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stars above the node
          SizedBox(
            width: starRowWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star,
                  size: 18,
                  color: unlocked
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Circle button
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? const Color(0xFF8ECAE6)
                    : const Color(0xFF9E9E9E),
                border: Border.all(
                  color: unlocked ? Colors.white : Colors.white30,
                  width: 3,
                ),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: unlocked
                  ? Center(
                      child: Text(
                        '$level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Colors.white54, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
