import 'package:flutter_tts/flutter_tts.dart';

import '../errors/app_exception.dart';

/// Platform independent text-to-speech contract.
abstract class SpeechSynthesizer {
  Future<void> speak(
    String text, {
    required String locale,
    double rate = 0.5,
    double pitch = 1.0,
  });

  Future<void> stop();

  Future<bool> isLanguageAvailable(String locale);

  Future<List<String>> languages();
}

/// `flutter_tts` backed implementation.
class DeviceSpeechSynthesizer implements SpeechSynthesizer {
  DeviceSpeechSynthesizer([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(
    String text, {
    required String locale,
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      final supported = await _resolveLocale(locale);
      await _tts.setLanguage(supported);
      await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
      await _tts.awaitSpeakCompletion(false);
      await _tts.speak(text);
    } catch (error) {
      throw TtsException('voice_unavailable', detail: error.toString());
    }
  }

  /// Picks the best available locale, falling back to English.
  Future<String> _resolveLocale(String locale) async {
    final requested = locale.replaceAll('_', '-');
    try {
      if (await _tts.isLanguageAvailable(requested) == true) return requested;
      final base = requested.split('-').first;
      if (await _tts.isLanguageAvailable(base) == true) return base;
    } catch (_) {
      // Some engines throw instead of returning false; fall through.
    }
    return 'en-IN';
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore stop failures from the platform channel.
    }
  }

  @override
  Future<bool> isLanguageAvailable(String locale) async {
    try {
      return await _tts.isLanguageAvailable(locale.replaceAll('_', '-')) ==
          true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> languages() async {
    try {
      final result = await _tts.getLanguages;
      if (result is List) {
        return result.map((value) => value.toString()).toList(growable: false);
      }
    } catch (_) {
      // Engines without language enumeration simply report none.
    }
    return const [];
  }
}
