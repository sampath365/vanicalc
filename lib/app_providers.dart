import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/platform_services.dart';
import 'core/services/speech_service.dart';
import 'core/services/tts_service.dart';
import 'features/calculator/domain/expression_engine.dart';
import 'features/history/data/history_repository.dart';
import 'features/history/domain/calculation_record.dart';
import 'features/history/domain/history_store.dart';
import 'features/history/presentation/history_controller.dart';
import 'features/number_to_words/domain/number_to_words_engine.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/voice_calculator/domain/calculation_speaker.dart';
import 'features/voice_calculator/domain/spoken_math_parser.dart';

/// Overridden in `main()` after `SharedPreferences` is loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// Overridden in `main()` after Hive is initialised.
final historyBoxProvider = Provider<Box<dynamic>>(
  (ref) => throw UnimplementedError('historyBoxProvider not overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final historyRepositoryProvider = Provider<HistoryStore>(
  (ref) => HistoryRepository(ref.watch(historyBoxProvider)),
);

final historyControllerProvider =
    NotifierProvider<HistoryController, List<CalculationRecord>>(
  HistoryController.new,
);

final expressionEngineProvider = Provider<ExpressionEngine>(
  (ref) => const ExpressionEngine(),
);

final numberToWordsEngineProvider = Provider<NumberToWordsEngine>(
  (ref) => const NumberToWordsEngine(),
);

final spokenMathParserProvider = Provider<SpokenMathParser>(
  (ref) => SpokenMathParser(
    engine: ref.watch(expressionEngineProvider),
    numberEngine: ref.watch(numberToWordsEngineProvider),
  ),
);

final calculationSpeakerProvider = Provider<CalculationSpeaker>(
  (ref) => CalculationSpeaker(
    numberEngine: ref.watch(numberToWordsEngineProvider),
  ),
);

final speechRecognizerProvider = Provider<SpeechRecognizer>(
  (ref) => DeviceSpeechRecognizer(),
);

final speechSynthesizerProvider = Provider<SpeechSynthesizer>(
  (ref) => DeviceSpeechSynthesizer(),
);

final platformServicesProvider = Provider<PlatformServices>(
  (ref) => const PlatformServices(),
);
