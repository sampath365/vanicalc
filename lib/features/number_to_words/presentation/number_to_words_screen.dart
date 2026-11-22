import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/widgets/app_widgets.dart';

/// Offline number-to-words converter with Indian and international grouping,
/// currency output, copy, share and speech.
class NumberToWordsScreen extends ConsumerStatefulWidget {
  const NumberToWordsScreen({super.key, this.initialValue});

  final String? initialValue;

  @override
  ConsumerState<NumberToWordsScreen> createState() =>
      _NumberToWordsScreenState();
}

class _NumberToWordsScreenState extends ConsumerState<NumberToWordsScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue ?? '1634391',
  );
  NumberSystem _system = NumberSystem.indian;
  bool _currency = false;
  bool _speaking = false;

  static const _examples = [
    '100',
    '1000',
    '10000',
    '100000',
    '1000000',
    '10000000',
    '1634391',
  ];

  @override
  void initState() {
    super.initState();
    _system = ref.read(settingsControllerProvider).numberSystem;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _words {
    final settings = ref.read(settingsControllerProvider);
    return ref
        .read(numberToWordsEngineProvider)
        .fromString(
          _controller.text.trim(),
          languageCode: settings.language.code,
          system: _system,
          currency: _currency,
        );
  }

  Future<void> _copy(String text) async {
    if (text.isEmpty) return;
    await ref.read(platformServicesProvider).copy(text);
    if (!mounted) return;
    showAppSnack(context, context.tr('copied'));
  }

  Future<void> _share(String text) async {
    if (text.isEmpty) return;
    await ref
        .read(platformServicesProvider)
        .share(text, subject: context.tr('words_title'));
    if (!mounted) return;
    showAppSnack(context, context.tr('shared'));
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    setState(() => _speaking = true);
    try {
      await ref
          .read(speechSynthesizerProvider)
          .speak(
            text,
            locale: settings.effectiveTtsLanguage.ttsLocale,
            rate: settings.speechRate,
            pitch: settings.speechPitch,
          );
    } catch (_) {
      if (mounted) {
        showAppSnack(context, context.tr('voice_unavailable'), error: true);
      }
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _stop() async {
    await ref.read(speechSynthesizerProvider).stop();
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final words = _words;
    final input = _controller.text.trim();
    final hasInput = input.isNotEmpty;
    final grouped = ResultFormatter.grouped(
      num.tryParse(input.replaceAll(',', '')) ?? 0,
      system: _system,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('words_title')),
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
              context.tr('words_subtitle'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              style: theme.textTheme.headlineMedium,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.tr('words_input_label'),
                hintText: context.tr('words_input_hint'),
                suffixIcon: IconButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _WordsCard(
              words: words,
              grouped: grouped,
              hasInput: hasInput,
              speaking: _speaking,
              languageName: settings.effectiveTtsLanguage.nativeName,
              system: _system,
              currency: _currency,
              onSystemChanged: (system) => setState(() => _system = system),
              onCurrencyChanged: (value) => setState(() => _currency = value),
              onCopy: () => _copy(words),
              onShare: () => _share(words),
              onSpeak: _speaking ? _stop : () => _speak(words),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final example in _examples)
                  ActionChip(
                    label: Text(example),
                    onPressed: () {
                      _controller.text = example;
                      setState(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('words_examples'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  for (final value in const [100, 1000, 10000, 100000, 1634391])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 92,
                            child: Text(
                              ResultFormatter.grouped(value, system: _system),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ref
                                  .read(numberToWordsEngineProvider)
                                  .convert(
                                    value,
                                    languageCode: settings.language.code,
                                    system: _system,
                                  ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
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

class _WordsCard extends StatelessWidget {
  const _WordsCard({
    required this.words,
    required this.grouped,
    required this.hasInput,
    required this.speaking,
    required this.languageName,
    required this.system,
    required this.currency,
    required this.onSystemChanged,
    required this.onCurrencyChanged,
    required this.onCopy,
    required this.onShare,
    required this.onSpeak,
  });

  final String words;
  final String grouped;
  final bool hasInput;
  final bool speaking;
  final String languageName;
  final NumberSystem system;
  final bool currency;
  final ValueChanged<NumberSystem> onSystemChanged;
  final ValueChanged<bool> onCurrencyChanged;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('words_result_label'),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (hasInput)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(grouped, style: theme.textTheme.bodySmall),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              words.isEmpty ? context.tr('words_empty_hint') : words,
              key: ValueKey('$words-$currency-$system'),
              style: theme.textTheme.headlineMedium?.copyWith(
                height: 1.4,
                color: words.isEmpty
                    ? theme.textTheme.bodySmall?.color
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (hasInput && words.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('words_invalid'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<NumberSystem>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(
                      value: NumberSystem.indian,
                      label: Text(context.tr('words_indian')),
                    ),
                    ButtonSegment(
                      value: NumberSystem.international,
                      label: Text(context.tr('words_international')),
                    ),
                  ],
                  selected: {system},
                  onSelectionChanged: (selection) =>
                      onSystemChanged(selection.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Switch(value: currency, onChanged: onCurrencyChanged),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  context.tr('words_currency_mode'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(languageName, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.copy_rounded,
                  label: context.tr('copy'),
                  onTap: onCopy,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionTile(
                  icon: Icons.share_rounded,
                  label: context.tr('share'),
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionTile(
                  icon: speaking
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_rounded,
                  label: context.tr('speak'),
                  onTap: onSpeak,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, maxLines: 1, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
