import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/constants/number_system.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/localization/app_language.dart';
import '../../calculator/presentation/calculator_controller.dart';
import '../../history/domain/calculation_record.dart';
import '../../settings/domain/app_settings.dart';
import '../domain/spoken_math_parser.dart';

enum VoiceStatus {
  idle,
  listening,
  processing,
  needsConfirmation,
  result,
  error,
}

/// State of the voice calculator screen.
class VoiceState {
  const VoiceState({
    this.status = VoiceStatus.idle,
    this.transcript = '',
    this.expression = '',
    this.result = '',
    this.value,
    this.errorCode,
    this.ambiguous = false,
    this.confidence = 0,
    this.notice,
    this.navigateTo,
    this.speaking = false,
  });

  final VoiceStatus status;
  final String transcript;
  final String expression;
  final String result;
  final double? value;
  final String? errorCode;
  final bool ambiguous;
  final double confidence;
  final String? notice;
  final String? navigateTo;
  final bool speaking;

  bool get hasResult => value != null && result.isNotEmpty;

  VoiceState copyWith({
    VoiceStatus? status,
    String? transcript,
    String? expression,
    String? result,
    double? value,
    String? errorCode,
    bool? ambiguous,
    double? confidence,
    String? notice,
    String? navigateTo,
    bool? speaking,
    bool clearError = false,
    bool clearValue = false,
    bool clearNotice = false,
    bool clearNavigation = false,
  }) {
    return VoiceState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      value: clearValue ? null : (value ?? this.value),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      ambiguous: ambiguous ?? this.ambiguous,
      confidence: confidence ?? this.confidence,
      notice: clearNotice ? null : (notice ?? this.notice),
      navigateTo: clearNavigation ? null : (navigateTo ?? this.navigateTo),
      speaking: speaking ?? this.speaking,
    );
  }
}

/// Drives speech recognition, interpretation, calculation and text-to-speech.
class VoiceController extends Notifier<VoiceState> {
  @override
  VoiceState build() {
    final recognizer = ref.read(speechRecognizerProvider);
    final synthesizer = ref.read(speechSynthesizerProvider);
    ref.onDispose(() {
      recognizer.cancel();
      synthesizer.stop();
    });
    return const VoiceState();
  }

  AppSettings get _settings => ref.read(settingsControllerProvider);

  Future<void> startListening() async {
    if (state.status == VoiceStatus.listening) return;
    state = state.copyWith(
      status: VoiceStatus.listening,
      transcript: '',
      clearError: true,
      clearNotice: true,
      clearNavigation: true,
      clearValue: true,
      result: '',
      expression: '',
      ambiguous: false,
    );
    final recognizer = ref.read(speechRecognizerProvider);
    try {
      final ready = await recognizer.initialize();
      if (!ready) {
        state = state.copyWith(
          status: VoiceStatus.error,
          errorCode: 'voice_unavailable',
        );
        return;
      }
      final locale = await _resolveLocale();
      await recognizer.start(
        localeId: locale,
        onResult: (result) {
          if (state.status == VoiceStatus.idle) return;
          state = state.copyWith(
            transcript: result.text,
            status: VoiceStatus.listening,
          );
          if (result.isFinal && result.text.trim().isNotEmpty) {
            process(result.text);
          }
        },
        onError: (code) {
          state = state.copyWith(status: VoiceStatus.error, errorCode: code);
        },
      );
    } on SpeechException catch (error) {
      state = state.copyWith(status: VoiceStatus.error, errorCode: error.code);
    } catch (_) {
      state = state.copyWith(
        status: VoiceStatus.error,
        errorCode: 'voice_unavailable',
      );
    }
  }

  Future<void> stopListening() async {
    await ref.read(speechRecognizerProvider).stop();
    if (state.status == VoiceStatus.listening) {
      state = state.copyWith(status: VoiceStatus.idle);
    }
  }

  Future<String> _resolveLocale() async {
    final language = _settings.effectiveSpeechLanguage;
    final wanted = language.speechLocale;
    try {
      final locales = await ref
          .read(speechRecognizerProvider)
          .availableLocales();
      String normalize(String value) =>
          value.replaceAll('-', '_').toLowerCase();
      if (locales.any((locale) => normalize(locale) == normalize(wanted))) {
        return wanted;
      }
      for (final locale in locales) {
        if (normalize(locale).startsWith('${language.code}_')) {
          return locale;
        }
      }
      state = state.copyWith(notice: 'voice_locale_unavailable');
      return 'en_US';
    } catch (_) {
      return wanted;
    }
  }

  /// Interprets [text] as a command or calculation.
  Future<void> process(String text) async {
    state = state.copyWith(
      status: VoiceStatus.processing,
      transcript: text,
      clearError: true,
      clearNotice: true,
    );
    final parsed = ref
        .read(spokenMathParserProvider)
        .parse(text, _settings.effectiveSpeechLanguage);

    if (parsed.isCommand) {
      await _handleCommand(parsed.command!);
      return;
    }

    if (parsed.expression.isEmpty || parsed.errorCode != null) {
      state = state.copyWith(
        status: VoiceStatus.error,
        expression: parsed.expression,
        errorCode: parsed.errorCode ?? 'voice_unclear',
        ambiguous: parsed.ambiguous,
        confidence: parsed.confidence,
      );
      return;
    }

    state = state.copyWith(
      expression: parsed.expression,
      ambiguous: parsed.ambiguous,
      confidence: parsed.confidence,
      status: parsed.ambiguous
          ? VoiceStatus.needsConfirmation
          : VoiceStatus.processing,
      clearError: true,
      clearValue: true,
      result: '',
    );

    if (!parsed.ambiguous) {
      await calculate();
    }
  }

  Future<void> _handleCommand(VoiceCommand command) async {
    switch (command.type) {
      case VoiceCommandType.clear:
        ref.read(calculatorControllerProvider.notifier).clear();
        state = state.copyWith(
          status: VoiceStatus.idle,
          expression: '',
          result: '',
          transcript: '',
          clearValue: true,
          notice: 'voice_applied',
        );
      case VoiceCommandType.deleteLast:
        ref.read(calculatorControllerProvider.notifier).backspace();
        state = state.copyWith(
          status: VoiceStatus.idle,
          notice: 'voice_applied',
        );
      case VoiceCommandType.repeatAnswer:
        if (!state.hasResult) {
          state = state.copyWith(
            status: VoiceStatus.error,
            errorCode: 'voice_no_speech',
          );
          return;
        }
        await speakCalculation(answerOnly: true);
        state = state.copyWith(status: VoiceStatus.result, clearNotice: true);
      case VoiceCommandType.showHistory:
        state = state.copyWith(
          status: VoiceStatus.idle,
          navigateTo: '/history',
          notice: 'voice_applied',
        );
      case VoiceCommandType.openScientific:
        state = state.copyWith(
          status: VoiceStatus.idle,
          navigateTo: '/scientific',
          notice: 'voice_applied',
        );
      case VoiceCommandType.setLanguage:
        final language = command.language;
        if (language != null) {
          await ref
              .read(settingsControllerProvider.notifier)
              .setLanguage(language);
        }
        state = state.copyWith(
          status: VoiceStatus.idle,
          notice: 'voice_applied',
          clearNavigation: true,
        );
      case VoiceCommandType.speakInLanguage:
        final language = command.language;
        if (!state.hasResult || language == null) {
          state = state.copyWith(
            status: VoiceStatus.error,
            errorCode: 'voice_no_speech',
          );
          return;
        }
        await ref
            .read(settingsControllerProvider.notifier)
            .setTtsLanguage(language);
        await speakCalculation(answerOnly: true, languageOverride: language);
        state = state.copyWith(
          status: VoiceStatus.result,
          notice: 'voice_applied',
        );
    }
  }

  void editExpression(String expression) {
    state = state.copyWith(
      expression: expression,
      status: VoiceStatus.needsConfirmation,
      clearError: true,
    );
  }

  Future<void> calculate({bool speak = true}) async {
    if (state.expression.trim().isEmpty) return;
    final outcome = ref
        .read(expressionEngineProvider)
        .evaluate(state.expression);
    if (!outcome.isSuccess) {
      state = state.copyWith(
        status: VoiceStatus.error,
        errorCode: outcome.errorCode,
        result: '',
        clearValue: true,
      );
      return;
    }
    state = state.copyWith(
      status: VoiceStatus.result,
      result: outcome.display,
      value: outcome.value,
      clearError: true,
      ambiguous: false,
    );
    await ref
        .read(historyControllerProvider.notifier)
        .add(
          expression: state.expression,
          result: outcome.display,
          value: outcome.value,
          type: CalculationType.voice,
          languageCode: _settings.language.code,
        );
    if (speak && _settings.autoSpeak) {
      await speakCalculation();
    }
  }

  Future<void> speakCalculation({
    bool answerOnly = false,
    AppLanguage? languageOverride,
  }) async {
    final value = state.value;
    if (value == null) return;
    final language = languageOverride ?? _settings.effectiveTtsLanguage;
    final speaker = ref.read(calculationSpeakerProvider);
    final system = _settings.numberSystem;
    final text = answerOnly
        ? speaker.resultWords(value, language, system: system)
        : speaker.calculationSentence(
            state.expression,
            value,
            language,
            system: system,
          );
    await _speak(text, language);
  }

  Future<void> speakTranscript() async {
    if (state.transcript.trim().isEmpty) return;
    await _speak(state.transcript, _settings.effectiveTtsLanguage);
  }

  Future<void> _speak(String text, AppLanguage language) async {
    state = state.copyWith(speaking: true);
    try {
      await ref
          .read(speechSynthesizerProvider)
          .speak(
            text,
            locale: language.ttsLocale,
            rate: _settings.speechRate,
            pitch: _settings.speechPitch,
          );
    } on TtsException catch (error) {
      state = state.copyWith(notice: error.code);
    } catch (_) {
      state = state.copyWith(notice: 'voice_unavailable');
    } finally {
      state = state.copyWith(speaking: false);
    }
  }

  Future<void> stopSpeaking() async {
    await ref.read(speechSynthesizerProvider).stop();
    state = state.copyWith(speaking: false);
  }

  void consumeNavigation() {
    if (state.navigateTo != null) {
      state = state.copyWith(clearNavigation: true);
    }
  }

  void reset() {
    state = const VoiceState();
  }

  NumberSystem get numberSystem => _settings.numberSystem;
}

final voiceControllerProvider = NotifierProvider<VoiceController, VoiceState>(
  VoiceController.new,
);
