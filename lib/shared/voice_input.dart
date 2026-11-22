import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../app_providers.dart';
import '../core/localization/app_localizations.dart';

/// Opens a listening dialog and returns the number spoken by the user.
///
/// The spoken phrase can be digits, words in any supported language or a small
/// expression such as "two thousand plus five hundred".
Future<double?> captureSpokenNumber(BuildContext context, WidgetRef ref) async {
  final recognizer = ref.read(speechRecognizerProvider);
  final settings = ref.read(settingsControllerProvider);
  final parser = ref.read(spokenMathParserProvider);
  final engine = ref.read(expressionEngineProvider);
  final transcript = ValueNotifier<String>('');
  final completer = Completer<double?>();
  final navigator = Navigator.of(context, rootNavigator: true);
  var finished = false;
  var dialogOpen = true;

  void closeDialog() {
    if (dialogOpen && navigator.canPop()) {
      dialogOpen = false;
      navigator.pop();
    }
  }

  Future<void> finish(double? value) async {
    if (finished) return;
    finished = true;
    await recognizer.cancel();
    closeDialog();
    if (!completer.isCompleted) completer.complete(value);
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(dialogContext.tr('voice_listening'))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: transcript,
              builder: (context, value, _) => Text(
                value.isEmpty ? dialogContext.tr('voice_mic_hint') : value,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dialogContext.tr('voice_examples'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => finish(null),
            child: Text(dialogContext.tr('cancel')),
          ),
        ],
      );
    },
  ).whenComplete(() {
    dialogOpen = false;
    finish(null);
  });

  try {
    final ready = await recognizer.initialize();
    if (!ready) {
      await finish(null);
      return await completer.future;
    }
    await recognizer.start(
      localeId: settings.effectiveSpeechLanguage.speechLocale,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 2),
      onError: (_) => finish(null),
      onResult: (result) {
        transcript.value = result.text;
        if (!result.isFinal) return;
        final parsed = parser.parse(
          result.text,
          settings.effectiveSpeechLanguage,
        );
        final value = parsed.expression.isEmpty
            ? null
            : engine.tryEvaluate(parsed.expression);
        finish(value);
      },
    );
    unawaited(
      Future<void>.delayed(const Duration(seconds: 17), () => finish(null)),
    );
  } catch (_) {
    await finish(null);
  }

  return await completer.future;
}
