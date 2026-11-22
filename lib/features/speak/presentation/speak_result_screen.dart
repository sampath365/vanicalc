import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/widgets/app_widgets.dart';

/// Speak a number or a complete calculation in the selected language.
class SpeakResultScreen extends ConsumerStatefulWidget {
  const SpeakResultScreen({super.key});

  @override
  ConsumerState<SpeakResultScreen> createState() => _SpeakResultScreenState();
}

class _SpeakResultScreenState extends ConsumerState<SpeakResultScreen> {
  final TextEditingController _controller = TextEditingController(
    text: '125 + 275',
  );
  bool _calculationMode = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _sentence {
    final input = _controller.text.trim();
    if (input.isEmpty) return null;
    final settings = ref.read(settingsControllerProvider);
    final language = settings.effectiveTtsLanguage;
    if (_calculationMode) {
      final outcome = ref.read(expressionEngineProvider).evaluate(input);
      if (!outcome.isSuccess) return null;
      return ref
          .read(calculationSpeakerProvider)
          .calculationSentence(
            input,
            outcome.value!,
            language,
            system: settings.numberSystem,
          );
    }
    final words = ref
        .read(numberToWordsEngineProvider)
        .fromString(
          input,
          languageCode: language.code,
          system: settings.numberSystem,
        );
    return words.isEmpty ? null : words;
  }

  Future<void> _speak() async {
    final sentence = _sentence;
    if (sentence == null) return;
    final settings = ref.read(settingsControllerProvider);
    try {
      await ref
          .read(speechSynthesizerProvider)
          .speak(
            sentence,
            locale: settings.effectiveTtsLanguage.ttsLocale,
            rate: settings.speechRate,
            pitch: settings.speechPitch,
          );
    } catch (_) {
      if (!mounted) return;
      showAppSnack(context, context.tr('voice_unavailable'), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final sentence = _sentence;
    final hasInput = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('feature_speak')),
        actions: [
          IconButton(
            tooltip: context.tr('language_title'),
            onPressed: () => context.push('/language'),
            icon: const Icon(Icons.translate_rounded),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
          children: [
            Text(
              context.tr('feature_speak_desc'),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.functions_rounded, size: 18),
                  label: Text(context.tr('feature_calculator')),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.pin_outlined, size: 18),
                  label: Text(context.tr('words_input_label')),
                ),
              ],
              selected: {_calculationMode},
              onSelectionChanged: (selection) => setState(() {
                _calculationMode = selection.first;
                _controller.text = _calculationMode ? '125 + 275' : '11800';
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 24),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _calculationMode
                    ? context.tr('calc_expression')
                    : context.tr('words_input_label'),
                hintText: _calculationMode ? '125 + 275' : '11800',
              ),
            ),
            const SizedBox(height: 14),
            if (hasInput && sentence == null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  context.tr('calc_invalid'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SurfaceCard(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              border: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('words_result_label'),
                        style: theme.textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        settings.effectiveTtsLanguage.nativeName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      sentence ?? context.tr('words_empty_hint'),
                      key: ValueKey(sentence),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        height: 1.45,
                      ),
                    ),
                  ),
                  if (_calculationMode && sentence != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '= ${ResultFormatter.format(ref.read(expressionEngineProvider).evaluate(_controller.text).value ?? 0)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: context.tr('speak'),
                    icon: Icons.volume_up_rounded,
                    onPressed: sentence == null ? null : _speak,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(speechSynthesizerProvider).stop();
                    },
                    icon: const Icon(Icons.stop_rounded, size: 18),
                    label: Text(context.tr('stop')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: sentence == null ? null : _speak,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: Text(context.tr('retry')),
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('settings_rate'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        settings.speechRate.toStringAsFixed(2),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.speechRate,
                    min: 0.2,
                    max: 1,
                    divisions: 8,
                    onChanged: (value) => ref
                        .read(settingsControllerProvider.notifier)
                        .setSpeechRate(value),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('settings_pitch'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        settings.speechPitch.toStringAsFixed(2),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.speechPitch,
                    min: 0.5,
                    max: 2,
                    divisions: 15,
                    onChanged: (value) => ref
                        .read(settingsControllerProvider.notifier)
                        .setSpeechPitch(value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
