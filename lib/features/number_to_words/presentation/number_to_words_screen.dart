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
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue ?? '1634391');
  NumberSystem _system = NumberSystem.indian;
  bool _currency = false;
  bool _speaking = false;

  static const _examples = ['100', '1000', '10000', '100000', '1000000', '10000000', '1634391'];

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
    return ref.read(numberToWordsEngineProvider).fromString(
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
    await ref.read(platformServicesProvider).share(text, subject: context.tr('words_title'));
    if (!mounted) return;
    showAppSnack(context, context.tr('shared'));
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    final settings = ref.read(settingsControllerProvider);
    setState(() => _speaking = true);
    try {
      await ref.read(speechSynthesizerProvider).speak(
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final words = _words;
    final hasInput = _controller.text.trim().isNotEmpty;

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
            const SizedBox(height: 16),
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
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<NumberSystem>(
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
                    selected: {_system},
                    onSelectionChanged: (selection) {
                      setState(() => _system = selection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: _currency,
                  onChanged: (value) => setState(() => _currency = value),
                ),
                const SizedBox(width: 4),
                Text(context.tr('words_currency_mode')),
                const Spacer(),
                Text(
                  settings.language.nativeName,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      Text(
                        context.tr('words_result_label'),
                        style: theme.textTheme.titleSmall,
                      ),
                      const Spacer(),
                      if (hasInput)
                        Text(
                          ResultFormatter.grouped(
                            num.tryParse(_controller.text.replaceAll(',', '')) ?? 0,
                            system: _system,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      words.isEmpty
                          ? context.tr('words_empty_hint')
                          : words,
                      key: ValueKey('$words-$_currency-$_system'),
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
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _ActionIcon(
                        icon: Icons.copy_rounded,
                        label: context.tr('copy'),
                        onTap: () => _copy(words),
                      ),
                      const SizedBox(width: 8),
                      _ActionIcon(
                        icon: Icons.share_rounded,
                        label: context.tr('share'),
                        onTap: () => _share(words),
                      ),
                      const SizedBox(width: 8),
                      _ActionIcon(
                        icon: _speaking
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_rounded,
                        label: context.tr('speak'),
                        onTap: () {
                          if (_speaking) {
                            ref.read(speechSynthesizerProvider).stop();
                            setState(() => _speaking = false);
                          } else {
                            _speak(words);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              ResultFormatter.grouped(value, system: _system),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ref.read(numberToWordsEngineProvider).convert(
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

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
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
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
