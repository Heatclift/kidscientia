import 'package:flutter/material.dart';
import 'login.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}


class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {


  // ── Fun facts ──────────────────────────────────────────────────────────
  final List<String> _funFacts = [
    'Did you know that Pluto is no longer a planet?',
    'Did you know that the Sun is the largest star in our solar system?',
    'Did you know that a day on Venus is longer than a year on Venus?',
    'Did you know that Saturn could float on water?',
    'Did you know that there are more stars in space than grains of sand on Earth?',
    'Did you know that the Moon is slowly drifting away from Earth?',
    'Did you know that Jupiter has the shortest day of all the planets?',
    'Did you know that one million Earths could fit inside the Sun?',
  ];

  int _currentFactIndex = 0;

  // ── Animation controllers ──────────────────────────────────────────────
  late AnimationController _rocketController;
  late Animation<double> _rocketOpacity;
  late Animation<Offset> _rocketSlide;

  late AnimationController _factController;
  late Animation<double> _factOpacity;

  // ── Fact cycling ───────────────────────────────────────────────────────
  static const Duration _initialDelay = Duration(seconds: 2);
  static const Duration _factDuration = Duration(seconds: 3);
  static const Duration _fadeDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();

    // Rocket: fade in + slide up from slightly below
    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _rocketOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeIn),
    );
    _rocketSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeOut),
    );

    // Fun fact: fade in/out
    _factController = AnimationController(
      vsync: this,
      duration: _fadeDuration,
    );
    _factOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _factController, curve: Curves.easeInOut),
    );

_rocketController.forward();
    _startFactCycle();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _startFactCycle() async {
    // Initial delay before first fact appears
    await Future.delayed(_initialDelay);
    if (!mounted) return;

    while (mounted) {
      // Fade in
      await _factController.forward();
      await Future.delayed(_factDuration);
      if (!mounted) return;

      // Fade out
      await _factController.reverse();
      if (!mounted) return;

      // Cycle to next fact
      setState(() {
        _currentFactIndex = (_currentFactIndex + 1) % _funFacts.length;
      });

      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _factController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      body: Column(
        children: [

          const Spacer(flex: 2),

          // ─── ROCKET GIF ─────────────────────────────────────────────────
          SlideTransition(
            position: _rocketSlide,
            child: FadeTransition(
              opacity: _rocketOpacity,
              child: Image.asset(
                'assets/images/rocket.gif', // 🔁 paste your rocket gif path here
                width: 120,
                height: 120,
              ),
            ),
          ),

          const Spacer(flex: 3),

          // ─── FUN FACT TEXT ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FadeTransition(
              opacity: _factOpacity,
              child: Text(
                _funFacts[_currentFactIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const Spacer(flex: 3),

        ],
      ),
    );
  }
}