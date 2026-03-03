import 'package:flutter/material.dart';
import 'loading.dart';

void main() {
  runApp(const KidScientiaApp());
}

class KidScientiaApp extends StatelessWidget {
  const KidScientiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Logo: fade + slide down from top
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  // Moon: slide up from bottom
  late AnimationController _moonController;
  late Animation<Offset> _moonSlide;

  // Einstein: fade + bounce up
  late AnimationController _einsteinController;
  late Animation<double> _einsteinOpacity;
  late Animation<Offset> _einsteinSlide;

  // Einstein: continuous floating (bob up/down)
  late AnimationController _floatController;
  late Animation<double> _floatOffset;

  // Button: fade in last
  late AnimationController _buttonController;
  late Animation<double> _buttonOpacity;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    // ── Logo ──────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // ── Moon ──────────────────────────────────────────
    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _moonSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _moonController, curve: Curves.easeOut));

    // ── Einstein ──────────────────────────────────────
    _einsteinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _einsteinOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _einsteinController, curve: Curves.easeIn),
    );
    _einsteinSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _einsteinController, curve: Curves.elasticOut),
    );

    // ── Float (looping bob) ───────────────────────────
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // ── Button ────────────────────────────────────────
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut),
    );

    // ── Sequence: stagger each animation ─────────────
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _moonController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _einsteinController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _moonController.dispose();
    _einsteinController.dispose();
    _floatController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF5BBFBF),
      body: Stack(
        children: [

          // ─── LOGO: fade + slide down ───────────────────────────────────
          Positioned(
            top: 48,
            left: 16,
            child: SlideTransition(
              position: _logoSlide,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                ),
              ),
            ),
          ),

          // ─── MOON: slide up ────────────────────────────────────────────
          Positioned(
            bottom: -size.width * 0.15,
            left: -size.width * 0.1,
            right: -size.width * 0.1,
            child: SlideTransition(
              position: _moonSlide,
              child: Image.asset(
                'assets/images/moon.png',
                width: size.width * 1.2,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),

          // ─── EINSTEIN: fade + bounce + continuous float ────────────────
          Positioned(
            bottom: size.height * 0.30,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _einsteinOpacity,
              child: SlideTransition(
                position: _einsteinSlide,
                child: AnimatedBuilder(
                  animation: _floatOffset,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatOffset.value),
                      child: child,
                    );
                  },
                  child: Center(
                    child: Image.asset(
                      'assets/images/einstein.png',
                      height: size.height * 0.45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── START BUTTON: fade + scale pop ───────────────────────────
          Positioned(
            bottom: 100,
            left: size.width * 0.25,
            right: size.width * 0.25,
            child: FadeTransition(
              opacity: _buttonOpacity,
              child: ScaleTransition(
                scale: _buttonScale,
                child: ElevatedButton(
onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoadingScreen()),
                );
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7DD4D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    side: const BorderSide(color: Colors.white24, width: 1),
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
