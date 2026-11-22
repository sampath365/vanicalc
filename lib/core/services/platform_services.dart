import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Clipboard, sharing and haptic helpers with a thin testable surface.
class PlatformServices {
  const PlatformServices();

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> share(String text, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
  }

  Future<void> lightHaptic() => HapticFeedback.lightImpact();

  Future<void> mediumHaptic() => HapticFeedback.mediumImpact();

  Future<void> successHaptic() => HapticFeedback.selectionClick();
}
