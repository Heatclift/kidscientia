import 'dart:async';

import 'package:flutter/services.dart';

/// Process-wide gate so a new AR view is not created until the previous
/// Sceneform/ARCore teardown has finished (or timed out).
class ArSessionGate {
  ArSessionGate._();

  static const _utilsChannel = MethodChannel('arcore_flutter_plugin/utils');
  static const _defaultTimeout = Duration(seconds: 5);

  static Completer<void>? _teardown;
  static bool _listening = false;

  static bool get isBusy =>
      _teardown != null && !_teardown!.isCompleted;

  static void ensureInitialized() {
    if (_listening) return;
    _listening = true;
    _utilsChannel.setMethodCallHandler(_onMethodCall);
  }

  static Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'onArTeardownComplete') {
      endTeardown();
    }
  }

  static void beginTeardown() {
    ensureInitialized();
    if (_teardown == null || _teardown!.isCompleted) {
      _teardown = Completer<void>();
    }
  }

  static void endTeardown() {
    final pending = _teardown;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
    _teardown = null;
  }

  /// Waits until the previous AR teardown finishes, the native engine is idle,
  /// or [timeout] elapses.
  static Future<void> waitUntilReady({
    Duration timeout = _defaultTimeout,
  }) async {
    ensureInitialized();
    final pending = _teardown;
    if (pending != null && !pending.isCompleted) {
      try {
        await pending.future.timeout(timeout);
      } on TimeoutException {
        endTeardown();
      }
    }

    // Native Filament cleanup can continue after destroy(); poll until idle.
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final ready =
            await _utilsChannel.invokeMethod<bool>('isArEngineReady') ?? true;
        if (ready) break;
      } on PlatformException {
        break;
      } on MissingPluginException {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
