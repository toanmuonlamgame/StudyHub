import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceFeedback {
  const DeviceFeedback._();

  static Future<void> selection() => _run(HapticFeedback.selectionClick);
  static Future<void> success() => _run(HapticFeedback.lightImpact);
  static Future<void> destructive() => _run(HapticFeedback.mediumImpact);

  static Future<void> _run(Future<void> Function() feedback) async {
    if (kIsWeb) return;

    try {
      await feedback();
    } on PlatformException {
      // Haptics are optional feedback and must never block the learning flow.
    }
  }
}
