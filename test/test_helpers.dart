import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanicalc/app_providers.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/core/localization/app_localizations.dart';
import 'package:vanicalc/core/services/speech_service.dart';
import 'package:vanicalc/core/services/tts_service.dart';
import 'package:vanicalc/core/theme/app_colors.dart';
import 'package:vanicalc/core/theme/app_theme.dart';
import 'package:vanicalc/features/history/domain/calculation_record.dart';
import 'package:vanicalc/features/history/domain/history_store.dart';

/// Records every phrase passed to the platform text-to-speech engine.
class FakeSpeechSynthesizer implements SpeechSynthesizer {
  final List<String> spoken = [];
  final List<String> locales = [];
  bool stopped = false;

  @override
  Future<void> speak(
    String text, {
    required String locale,
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    spoken.add(text);
    locales.add(locale);
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<bool> isLanguageAvailable(String locale) async => true;

  @override
  Future<List<String>> languages() async => ['en-IN', 'te-IN', 'hi-IN'];
}

/// Deterministic speech recognizer used by unit and widget tests.
class FakeSpeechRecognizer implements SpeechRecognizer {
  FakeSpeechRecognizer({this.locales = const ['en_US', 'te_IN', 'hi_IN']});

  final List<String> locales;
  bool initialized = false;
  bool listening = false;
  String? lastLocale;
  void Function(VoiceRecognitionResult result)? _onResult;
  void Function(String code)? _onError;

  @override
  bool get isAvailable => initialized;

  @override
  bool get isListening => listening;

  @override
  Future<bool> initialize() async {
    initialized = true;
    return true;
  }

  @override
  Future<void> start({
    required String localeId,
    required void Function(VoiceRecognitionResult result) onResult,
    void Function(String code)? onError,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    listening = true;
    lastLocale = localeId;
    _onResult = onResult;
    _onError = onError;
  }

  @override
  Future<void> stop() async {
    listening = false;
  }

  @override
  Future<void> cancel() async {
    listening = false;
  }

  @override
  Future<List<String>> availableLocales() async => locales;

  void emit(String text, {bool isFinal = true, double confidence = 0.92}) {
    _onResult?.call(
      VoiceRecognitionResult(
        text: text,
        isFinal: isFinal,
        confidence: confidence,
      ),
    );
  }

  void fail(String code) => _onError?.call(code);
}

/// In-memory history store so widget tests never touch the file system.
class InMemoryHistoryStore implements HistoryStore {
  final List<CalculationRecord> _records = [];
  int _sequence = 0;

  @override
  List<CalculationRecord> all() {
    final records = List<CalculationRecord>.from(_records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  @override
  List<CalculationRecord> search(String query, {bool favoritesOnly = false}) {
    final normalized = query.trim().toLowerCase();
    return all()
        .where((record) {
          if (favoritesOnly && !record.favorite) return false;
          if (normalized.isEmpty) return true;
          return record.expression.toLowerCase().contains(normalized) ||
              record.result.toLowerCase().contains(normalized);
        })
        .toList(growable: false);
  }

  @override
  Future<CalculationRecord> add({
    required String expression,
    required String result,
    required String type,
    required String languageCode,
    double? value,
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();
    final record = CalculationRecord(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      expression: expression,
      result: result,
      value: value,
      type: type,
      languageCode: languageCode,
      createdAt: now,
    );
    _records.add(record);
    return record;
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<void> clear() async => _records.clear();

  @override
  Future<CalculationRecord?> toggleFavorite(String id) async {
    final index = _records.indexWhere((record) => record.id == id);
    if (index == -1) return null;
    final updated = _records[index].copyWith(
      favorite: !_records[index].favorite,
    );
    _records[index] = updated;
    return updated;
  }

  @override
  int countToday({DateTime? now}) {
    final reference = now ?? DateTime.now();
    return _records.where((record) {
      return record.createdAt.year == reference.year &&
          record.createdAt.month == reference.month &&
          record.createdAt.day == reference.day;
    }).length;
  }

  @override
  int get favoriteCount => _records.where((record) => record.favorite).length;
}

/// Shared test environment with mocked preferences, history and voice services.
class TestEnvironment {
  TestEnvironment._(
    this.preferences,
    this.history,
    this.recognizer,
    this.synthesizer,
    this.container,
  );

  final SharedPreferences preferences;
  final InMemoryHistoryStore history;
  final FakeSpeechRecognizer recognizer;
  final FakeSpeechSynthesizer synthesizer;
  final ProviderContainer container;

  List<Override> get overrides => [
    sharedPreferencesProvider.overrideWithValue(preferences),
    historyRepositoryProvider.overrideWithValue(history),
    speechRecognizerProvider.overrideWithValue(recognizer),
    speechSynthesizerProvider.overrideWithValue(synthesizer),
  ];

  static Future<TestEnvironment> create({
    Map<String, Object> preferences = const {},
  }) async {
    SharedPreferences.setMockInitialValues(preferences);
    final prefs = await SharedPreferences.getInstance();
    final history = InMemoryHistoryStore();
    final recognizer = FakeSpeechRecognizer();
    final synthesizer = FakeSpeechSynthesizer();
    final overrides = <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      historyRepositoryProvider.overrideWithValue(history),
      speechRecognizerProvider.overrideWithValue(recognizer),
      speechSynthesizerProvider.overrideWithValue(synthesizer),
    ];
    final container = ProviderContainer(overrides: overrides);
    return TestEnvironment._(
      prefs,
      history,
      recognizer,
      synthesizer,
      container,
    );
  }

  Future<void> dispose() async {
    container.dispose();
  }
}

/// Builds a provider container for pure controller tests.
Future<ProviderContainer> createTestContainer({
  Map<String, Object> preferences = const {},
}) async {
  final environment = await TestEnvironment.create(preferences: preferences);
  addTearDown(environment.dispose);
  return environment.container;
}

/// Wraps a widget with the app theme, localization and provider scope.
Widget wrapForTest(
  Widget child, {
  required List<Override> overrides,
  AppLanguage language = AppLanguage.english,
  AppThemeMode themeMode = AppThemeMode.light,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.light(AccentPalette.orange),
      darkTheme: AppTheme.dark(AccentPalette.orange),
      themeMode: themeMode.themeMode,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );
}
