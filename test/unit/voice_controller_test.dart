import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/app_providers.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/history/domain/calculation_record.dart';
import 'package:vanicalc/features/voice_calculator/presentation/voice_controller.dart';

import '../test_helpers.dart';

void main() {
  test('recognises and calculates an English phrase', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.process('What is 25 plus 35?');

    final state = container.read(voiceControllerProvider);
    expect(state.expression, '25+35');
    expect(state.result, '60');
    expect(state.value, 60);
    expect(state.status, VoiceStatus.result);
    expect(state.hasResult, isTrue);
    expect(state.errorCode, isNull);

    final history = container.read(historyControllerProvider);
    expect(history, hasLength(1));
    expect(history.first.type, CalculationType.voice);
    expect(history.first.expression, '25+35');
    expect(history.first.result, '60');
  });

  test('speaks the full calculation automatically', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;

    await container
        .read(voiceControllerProvider.notifier)
        .process('What is 25 plus 35?');

    expect(environment.synthesizer.spoken, isNotEmpty);
    final sentence = environment.synthesizer.spoken.last;
    expect(sentence, contains('Twenty-Five'));
    expect(sentence, contains('equals'));
    expect(sentence, contains('Sixty'));
    expect(environment.synthesizer.locales.last, 'en-IN');
  });

  test('does not speak when auto speak is disabled', () async {
    final environment = await TestEnvironment.create(
      preferences: {'settings.auto_speak': false},
    );
    addTearDown(environment.dispose);
    await environment.container
        .read(voiceControllerProvider.notifier)
        .process('10 plus 5');
    expect(environment.synthesizer.spoken, isEmpty);
    expect(environment.container.read(voiceControllerProvider).result, '15');
  });

  test('asks for confirmation when no operator was heard', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container.read(voiceControllerProvider.notifier).process('25');

    final state = container.read(voiceControllerProvider);
    expect(state.status, VoiceStatus.needsConfirmation);
    expect(state.ambiguous, isTrue);
    expect(state.expression, '25');
    expect(state.hasResult, isFalse);
  });

  test('confirmed expression can be calculated', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    final controller = container.read(voiceControllerProvider.notifier);
    await controller.process('25');
    await controller.calculate();

    final state = container.read(voiceControllerProvider);
    expect(state.result, '25');
    expect(state.status, VoiceStatus.result);
  });

  test('handles a divide by zero error', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container
        .read(voiceControllerProvider.notifier)
        .process('25 divided by 0');

    final state = container.read(voiceControllerProvider);
    expect(state.status, VoiceStatus.error);
    expect(state.errorCode, 'error_divide_by_zero');
    expect(state.hasResult, isFalse);
  });

  test('rejects unclear speech', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container.read(voiceControllerProvider.notifier).process('banana');

    final state = container.read(voiceControllerProvider);
    expect(state.status, VoiceStatus.error);
    expect(state.errorCode, isNotNull);
  });

  test('changes the language by voice command', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container
        .read(voiceControllerProvider.notifier)
        .process('Change language to Telugu');

    expect(
      container.read(settingsControllerProvider).language,
      AppLanguage.telugu,
    );
    expect(environment.preferences.getString('settings.language'), 'te');
  });

  test('reads the result in a requested language', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    final controller = container.read(voiceControllerProvider.notifier);
    await controller.process('25 plus 35');
    await controller.process('Read result in Hindi');

    expect(
      container.read(settingsControllerProvider).effectiveTtsLanguage,
      AppLanguage.hindi,
    );
    expect(environment.synthesizer.locales.last, 'hi-IN');
    expect(environment.synthesizer.spoken.last, contains('साठ'));
  });

  test('repeats the last answer', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    final controller = container.read(voiceControllerProvider.notifier);
    await controller.process('25 plus 35');
    environment.synthesizer.spoken.clear();
    await controller.process('repeat answer');

    expect(environment.synthesizer.spoken, isNotEmpty);
    expect(environment.synthesizer.spoken.last, 'Sixty');
  });

  test('navigates for show history command', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container
        .read(voiceControllerProvider.notifier)
        .process('show history');
    expect(container.read(voiceControllerProvider).navigateTo, '/history');
    container.read(voiceControllerProvider.notifier).consumeNavigation();
    expect(container.read(voiceControllerProvider).navigateTo, isNull);
  });

  test('listening uses the selected speech locale', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.telugu);
    await container.read(voiceControllerProvider.notifier).startListening();

    expect(environment.recognizer.lastLocale, 'te_IN');
    expect(
      container.read(voiceControllerProvider).status,
      VoiceStatus.listening,
    );

    environment.recognizer.emit('ఇరవై ఐదు ప్లస్ ముప్పై ఐదు');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(voiceControllerProvider);
    expect(state.expression, '25+35');
    expect(state.result, '60');
  });

  test('surfaces recognizer errors', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    final container = environment.container;
    await container.read(voiceControllerProvider.notifier).startListening();
    environment.recognizer.fail('voice_permission_denied');

    final state = container.read(voiceControllerProvider);
    expect(state.status, VoiceStatus.error);
    expect(state.errorCode, 'voice_permission_denied');
  });

  test('falls back to English when the locale is unsupported', () async {
    final environment = await TestEnvironment.create();
    addTearDown(environment.dispose);
    environment.recognizer.locales;
    final container = environment.container;
    await container
        .read(settingsControllerProvider.notifier)
        .setLanguage(AppLanguage.punjabi);
    await container.read(voiceControllerProvider.notifier).startListening();

    expect(environment.recognizer.lastLocale, 'en_US');
    expect(
      container.read(voiceControllerProvider).notice,
      'voice_locale_unavailable',
    );
  });
}
