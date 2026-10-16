import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

import 'ar_session_gate.dart';
import 'model_registry.dart';

class ArEarthMapScreen extends StatefulWidget {
  final String qrValue;

  const ArEarthMapScreen({super.key, required this.qrValue});

  @override
  State<ArEarthMapScreen> createState() => _ArEarthMapScreenState();
}

class _ArEarthMapScreenState extends State<ArEarthMapScreen>
    with WidgetsBindingObserver {
  ArCoreController? _arController;
  ModelEntry? _modelEntry;
  ArCoreAvailability? _arAvailability;
  bool _isCheckingAr = false;
  bool _isLoading = true;
  bool _isPlaced = false;
  bool _showInstructions = true;
  bool _isClosing = false;
  bool _showInfoCard = false;
  bool _isStartingAr = false;
  String? _arStartError;
  /// Bumps each screen instance so Android PlatformViews are never recycled.
  static int _nextArViewEpoch = 0;
  late final int _arViewEpoch;

  @override
  void initState() {
    super.initState();
    _arViewEpoch = ++_nextArViewEpoch;
    ArSessionGate.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    _modelEntry = ModelRegistry.resolve(widget.qrValue);
    if (_modelEntry != null) {
      _preloadModel(_modelEntry!.assetPath);
      _checkArAvailability();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check after the user comes back from installing Google Play Services for AR.
    if (state == AppLifecycleState.resumed &&
        _arAvailability != null &&
        _arAvailability != ArCoreAvailability.SUPPORTED_INSTALLED) {
      _checkArAvailability();
    }
  }

  Future<void> _checkArAvailability() async {
    if (_isCheckingAr) return;
    _isCheckingAr = true;

    ArCoreAvailability availability;
    try {
      availability = await ArCoreController.getArCoreAvailability();
    } catch (e) {
      debugPrint("⚠️ ARCore availability check failed: $e");
      availability = ArCoreAvailability.UNKNOWN_ERROR;
    } finally {
      _isCheckingAr = false;
    }

    if (mounted && !_isClosing) {
      setState(() => _arAvailability = availability);
    }
  }

  Future<void> _requestArCoreInstall() async {
    try {
      final installed = await ArCoreController.requestArCoreInstall();
      if (installed) await _checkArAvailability();
    } on PlatformException catch (e) {
      debugPrint("⚠️ ARCore install request failed: ${e.code} ${e.message}");
      if (!mounted || _isClosing) return;
      setState(() {
        _arAvailability = e.code == "UNSUPPORTED"
            ? ArCoreAvailability.UNSUPPORTED_DEVICE_NOT_CAPABLE
            : ArCoreAvailability.UNKNOWN_ERROR;
      });
    }
  }

  Future<void> _preloadModel(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
    } catch (e) {
      debugPrint("⚠️ Failed to preload model: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onArViewCreated(ArCoreController controller) {
    if (_isClosing) {
      return;
    }

    _arController = controller;
    controller.onPlaneTap = _onPlaneTap;
    controller.onArReady = () {
      if (!mounted || _isClosing) return;
      setState(() {
        _isStartingAr = false;
        _arStartError = null;
      });
    };
    controller.onError = (message) {
      if (!mounted || _isClosing) return;
      setState(() {
        _isStartingAr = false;
        _arStartError = message;
      });
    };
  }

  Future<void> _onPlaneTap(List<ArCoreHitTestResult> hits) async {
    if (_isPlaced || hits.isEmpty || _modelEntry == null) return;

    final hit = hits.first;
    final position = hit.pose.translation + vector64.Vector3(0, 0.05, 0);

    final node = ArCoreReferenceNode(
      name: "DynamicModel",
      objectUrl: _modelEntry!.assetPath,
      position: position,
      rotation: hit.pose.rotation,
      scale: vector64.Vector3(0.3, 0.3, 0.3),
    );

    try {
      await _arController?.addArCoreNodeWithAnchor(node);
      if (mounted) {
        setState(() {
          _isPlaced = true;
          _showInfoCard = true;
        });
      }
    } catch (e) {
      debugPrint("🔴 Failed to place model: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detachArController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _detachArController() {
    final controller = _arController;
    if (controller == null) return;

    controller.onPlaneTap = null;
    controller.onNodeTap = null;
    controller.onError = null;
    controller.onArReady = null;
    controller.onPlaneDetected = null;
    controller.onTrackingImage = null;
    _arController = null;
  }

  Future<void> _close() async {
    if (_isClosing) return;
    _isClosing = true;

    final controller = _arController;
    final hadLiveAr = controller != null;
    _detachArController();

    if (hadLiveAr) {
      ArSessionGate.beginTeardown();
    }

    // Soft-dispose (pause) while the view is still mounted, then remove it so
    // Flutter's PlatformView.dispose can destroy Sceneform after detach.
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (e) {
        debugPrint("AR controller dispose failed: $e");
      }
    }

    if (!mounted) return;
    setState(() {});
    await WidgetsBinding.instance.endOfFrame;

    if (hadLiveAr) {
      // Waits for delayed native teardown signal + engine-idle poll.
      await ArSessionGate.waitUntilReady();
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _startArSession() async {
    if (_isClosing) return;
    await ArSessionGate.waitUntilReady();
    if (!mounted || _isClosing) return;
    setState(() {
      _showInstructions = false;
      _isStartingAr = true;
      _arStartError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arAvailability = _arAvailability;
    final isArReady = arAvailability == ArCoreAvailability.SUPPORTED_INSTALLED;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _close,
          ),
          title: Text(_modelEntry?.displayName ?? "Model Not Found"),
          centerTitle: true,
        ),
        body: _modelEntry == null
            ? const Center(
                child: Text(
                  "No model registered for this QR code.",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : Stack(
                children: [
                  if (!_isClosing &&
                      isArReady &&
                      !_showInstructions &&
                      !_isLoading)
                    ArCoreView(
                      // Force a fresh PlatformView each AR open (avoid recycled HC state).
                      key: ValueKey('arcore_${widget.qrValue}_$_arViewEpoch'),
                      onArCoreViewCreated: _onArViewCreated,
                      enablePlaneRenderer: true,
                      enableTapRecognizer: true,
                    )
                  else
                    const ColoredBox(color: Colors.black),
                  if (_isLoading || arAvailability == null)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isLoading
                                  ? "Loading model…"
                                  : "Checking AR support…",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!isArReady)
                    _ArUnavailableOverlay(
                      availability: arAvailability,
                      modelName: _modelEntry!.displayName,
                      onInstall: _requestArCoreInstall,
                      onBack: _close,
                    )
                  else if (_showInstructions)
                    _InstructionsOverlay(
                      modelName: _modelEntry!.displayName,
                      onStart: _startArSession,
                    )
                  else if (_arStartError != null)
                    _ArStartErrorOverlay(
                      message: _arStartError!,
                      onBack: _close,
                    )
                  else if (_isStartingAr)
                    Container(
                      color: Colors.black.withValues(alpha: 0.55),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              "Starting camera…",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!_isPlaced)
                    Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF5BBFBF,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              color: Color(0xFF5BBFBF),
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Slowly move your camera around until you see white dots, then tap on them to place the model.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_isPlaced && !_isLoading)
                    _ModelInfoOverlay(
                      modelEntry: _modelEntry!,
                      visible: _showInfoCard,
                      onToggle: () =>
                          setState(() => _showInfoCard = !_showInfoCard),
                    ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info card shown once the model has been placed, with a floating
// toggle button to show/hide it so it doesn't permanently block the view.
// ─────────────────────────────────────────────────────────────────────────────
class _ModelInfoOverlay extends StatelessWidget {
  final ModelEntry modelEntry;
  final bool visible;
  final VoidCallback onToggle;

  const _ModelInfoOverlay({
    required this.modelEntry,
    required this.visible,
    required this.onToggle,
  });

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.bottomCenter,
                child: visible ? _buildCard() : const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              _ToggleButton(visible: visible, onTap: onToggle),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF14201F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _teal.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(modelEntry.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelEntry.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        modelEntry.category.label,
                        style: TextStyle(
                          color: _teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            modelEntry.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _ToggleButton({required this.visible, required this.onTap});

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    if (visible) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _teal,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen instruction overlay shown before AR begins
// ─────────────────────────────────────────────────────────────────────────────
class _InstructionsOverlay extends StatelessWidget {
  final String modelName;
  final VoidCallback onStart;

  const _InstructionsOverlay({required this.modelName, required this.onStart});

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              // Icon badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _teal, width: 2),
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: _teal,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Get Ready for AR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "You're about to view: $modelName",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Step cards
              _StepCard(
                step: "1",
                icon: Icons.accessibility_new_rounded,
                title: "Stand up & clear the area",
                description:
                    "Get off your chair and make sure there's enough open space around you for the best experience.",
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: "2",
                icon: Icons.videocam_rounded,
                title: "Slowly move your camera",
                description:
                    "Point your phone at a flat surface like a table or floor and move it around slowly. White dots will appear — that means the surface is detected.",
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: "3",
                icon: Icons.touch_app_rounded,
                title: "Tap the white dots",
                description:
                    "Once you see the white dots, tap on them to reveal the $modelName in AR right on that surface.",
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "I'm Ready — Start AR",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final IconData icon;
  final String title;
  final String description;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _teal.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: _teal.withValues(alpha: 0.6)),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: _teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: _teal, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shown when the AR camera fails to start after the user taps Start
// ─────────────────────────────────────────────────────────────────────────────
class _ArStartErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ArStartErrorOverlay({
    required this.message,
    required this.onBack,
  });

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade400, width: 2),
                  ),
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.orange.shade400,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Couldn't start the AR camera",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Go Back",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shown instead of AR when Google Play Services for AR is missing, outdated,
// or not supported on this phone
// ─────────────────────────────────────────────────────────────────────────────
class _ArUnavailableOverlay extends StatelessWidget {
  final ArCoreAvailability availability;
  final String modelName;
  final VoidCallback onInstall;
  final VoidCallback onBack;

  const _ArUnavailableOverlay({
    required this.availability,
    required this.modelName,
    required this.onInstall,
    required this.onBack,
  });

  static const _teal = Color(0xFF5BBFBF);

  @override
  Widget build(BuildContext context) {
    final (String title, String message, String? installLabel) =
        switch (availability) {
          ArCoreAvailability.UNSUPPORTED_DEVICE_NOT_CAPABLE => (
            "AR isn't supported on this phone",
            "This phone can't run Google Play Services for AR, so the $modelName can't be placed in AR here. Try scanning the flashcard on another phone.",
            null,
          ),
          ArCoreAvailability.SUPPORTED_APK_TOO_OLD => (
            "Update needed for AR",
            "Google Play Services for AR needs an update before the $modelName can appear in AR.",
            "Update Google Play Services for AR",
          ),
          ArCoreAvailability.SUPPORTED_NOT_INSTALLED => (
            "AR needs one more app",
            "Install Google Play Services for AR, then come back here to place the $modelName.",
            "Install Google Play Services for AR",
          ),
          _ => (
            "AR may not work on this phone",
            "This phone couldn't confirm that it supports Google Play Services for AR, which is needed to place the $modelName in AR.",
            "Try Installing Anyway",
          ),
        };

    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.shade400, width: 2),
                  ),
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    color: Colors.orange.shade400,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: installLabel != null ? onInstall : onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      installLabel ?? "Go Back",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (installLabel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onBack,
                    child: Text(
                      "Go Back",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
