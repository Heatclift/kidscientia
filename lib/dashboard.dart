import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan.dart';
import 'minigame/level_map_screen.dart';
import 'minigame/zoology_level_select_screen.dart';
import 'minigame/anatomy_level_select_screen.dart';
import 'minigame/astronomy_level_select_screen.dart';
import 'minigame/geology_level_select_screen.dart';
import 'personal_info.dart';
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // ── HEADER ──────────────────────────────────────────────
                const _Header(),

                const SizedBox(height: 16),

                // ── SUBJECTS CARD ────────────────────────────────────────
                const _SubjectsCard(),

                const SizedBox(height: 16),

                // ── ROCKET / FLASHCARD BANNER ────────────────────────────
                const _RocketBanner(),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  HEADER
// ============================================================
class _Header extends StatelessWidget {
  const _Header();

  Future<String> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('user_first_name')?.trim() ?? '';
    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadFirstName(),
      builder: (context, snapshot) {
        final firstName = snapshot.data?.trim() ?? '';
        final welcomeText =
            firstName.isEmpty ? 'Welcome, Kiddos!' : 'Welcome, $firstName!';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    welcomeText,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Where your kids learn.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInfoScreen(),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF5FC4C4),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/avatar.png"),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFCC00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
//  SUBJECTS CARD  (teal rounded container)
// ============================================================
class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF7DCACA),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Physical Science ───────────────────────────────
          const Text(
            "Physical Science",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              SubjectCard(
                label: "BOTANY",
                imagePath: "assets/images/botany.png",
              ),
              SubjectCard(
                label: "ZOOLOGY",
                imagePath: "assets/images/zoology.png",
              ),
              SubjectCard(
                label: "ANATOMY",
                imagePath: "assets/images/anatomy.png",
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── Earth Science ──────────────────────────────────
          const Text(
            "Earth Science",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SubjectCard(
                label: "GEOLOGY",
                imagePath: "assets/images/geology.png",
              ),
              SizedBox(width: 26),
              SubjectCard(
                label: "ASTRONOMY",
                imagePath: "assets/images/astronomy.png",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  REUSABLE SUBJECT CARD WIDGET
// ============================================================
class SubjectCard extends StatelessWidget {
  final String label;
  final String imagePath;

  const SubjectCard({
    super.key,
    required this.label,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (label == 'ZOOLOGY')    return const ZoologyLevelSelectScreen();
            if (label == 'ANATOMY')    return const AnatomyLevelSelectScreen();
            if (label == 'ASTRONOMY')  return const AstronomyLevelSelectScreen();
            if (label == 'GEOLOGY')    return const GeologyLevelSelectScreen();
            return LevelMapScreen(
              category: label,
              mapAsset: label == 'BOTANY'
                  ? 'assets/images/maps/botany_map.png'
                  : null,
            );
          },
        ),
      ),
      child: Column(
      children: [
        // Rounded image tile with shadow
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 86,
              height: 86,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Label below icon
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
      ],
      ),
    );
  }
}

// ============================================================
//  ROCKET / FLASHCARD BANNER
// ============================================================
class _RocketBanner extends StatelessWidget {
  const _RocketBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        // Purple-lavender gradient matching the reference image
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCFBCF2),
            Color(0xFFAA93E0),
            Color(0xFF8B6FCC),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Rocket illustration — covers left+center, overflows top slightly
            Positioned(
              left: -10,
              top: -14,
              bottom: 0,
              child: Image.asset(
                "assets/images/rocketKIDS.png",
                fit: BoxFit.contain,
                width: 220,
              ),
            ),

// Scan button — bottom right
            Positioned(
              bottom: 16,
              right: 14,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // Camera shutter icon (matches reference)
                      Icon(
                        Icons.camera_alt,
                        size: 34,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "SCAN YOU\nFLASHCARD\nHERE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          height: 1.55,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
