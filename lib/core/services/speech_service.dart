import 'package:speech_to_text/speech_recognition_error.dart' as stt_error;
import 'package:speech_to_text/speech_recognition_result.dart' as stt_result;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../errors/app_exception.dart';

/// Result emitted by the speech recognizer.
class VoiceRecognitionResult {
  const VoiceRecognitionResult({
    required this.text,
    required this.isFinal,
    this.confidence = 0,
  });

  final String text;
  final bool isFinal;
  final double confidence;
}

/// Platform independent speech-to-text contract.
abstract class SpeechRecognizer {
  Future<bool> initialize();

  bool get isAvailable;

  bool get isListening;

  Future<void> start({
    required String localeId,
    required void Function(VoiceRecognitionResult result) onResult,
    void Function(String code)? onError,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  });

  Future<void> stop();

  Future<void> cancel();

  Future<List<String>> availableLocales();
}

/// `speech_to_text` backed implementation.
class DeviceSpeechRecognizer implements SpeechRecognizer {
  DeviceSpeechRecognizer([stt.SpeechToText? speech])
      : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _initialized = false;
  void Function(String code)? _errorHandler;

  @override
  bool get isAvailable => _initialized && _speech.isAvailable;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: _handleError,
        debugLogging: false,
      );
      return _initialized;
    } catch (error) {
      _initialized = false;
      throw SpeechException('voice_unavailable', detail: error.toString());
    }
  }

  @override
  Future<void> start({
    required String localeId,
    required void Function(VoiceRecognitionResult result) onResult,
    void Function(String code)? onError,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_initialized) {
      final ready = await initialize();
      if (!ready) {
        throw const SpeechException('voice_unavailable');
      }
    }
    _errorHandler = onError;
    try {
      await _speech.listen(
        onResult: (stt_result.SpeechRecognitionResult result) {
          onResult(
            VoiceRecognitionResult(
              text: result.recognizedWords,
              isFinal: result.finalResult,
              confidence: result.confidence,
            ),
          );
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
          listenFor: listenFor,
          pauseFor: pauseFor,
        ),
      );
    } catch (error) {
      throw SpeechException('voice_unavailable', detail: error.toString());
    }
  }

  void _handleError(stt_error.SpeechRecognitionError error) {
    _errorHandler?.call(_mapError(error.errorMsg));
  }

  static String _mapError(String error) {
    switch (error) {
      case 'error_permission':
      case 'error_insufficient_permissions':
        return 'voice_permission_denied';
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'voice_no_speech';
      case 'error_network':
      case 'error_network_timeout':
        return 'voice_network';
      default:
        return 'voice_unavailable';
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Stopping an inactive recognizer is not an error worth surfacing.
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {
      // Ignore cancellation failures from the platform channel.
    }
  }

  @override
  Future<List<String>> availableLocales() async {
    if (!_initialized) {
      await initialize();
    }
    final locales = await _speech.locales();
    return locales.map((locale) => locale.localeId).toList(growable: false);
  }
}
