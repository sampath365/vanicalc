import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/voice_input.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../history/domain/calculation_record.dart';
import '../domain/unit_converter.dart';

/// Eight-category offline unit converter with number words output.
class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() =>
      _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  final TextEditingController _value = TextEditingController(text: '1');
  int _categoryIndex = 0;
  late UnitOption _from = UnitConverter.categories.first.units.first;
  late UnitOption _to = UnitConverter.categories.first.units[1];

  UnitCategory get _category => UnitConverter.categories[_categoryIndex];

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() {
      _categoryIndex = index;
      _from = _category.units.first;
      _to = _category.units.length > 1
          ? _category.units[1]
          : _category.units.first;
    });
  }

  double? get _input => double.tryParse(_value.text.trim());

  double? get _converted {
    final input = _input;
    if (input == null) return null;
    return UnitConverter.convert(
      category: _category,
      from: _from,
      to: _to,
      value: input,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final converted = _converted;
    final formatted = converted == null
        ? ''
        : ResultFormatter.format(converted);
    final words = converted == null
        ? ''
        : ref
              .read(numberToWordsEngineProvider)
              .fromString(
                formatted,
                languageCode: settings.language.code,
                system: settings.numberSystem,
              );

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('converter_title'))),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
          children: [
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: UnitConverter.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = UnitConverter.categories[index];
                  return ChoiceChip(
                    label: Text(context.tr(category.labelKey)),
                    selected: _categoryIndex == index,
                    onSelected: (_) => _selectCategory(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.tr('amount'),
                suffixIcon: IconButton(
                  tooltip: context.tr('voice_tap_to_speak'),
                  onPressed: () async {
                    final value = await captureSpokenNumber(context, ref);
                    if (value == null) return;
                    setState(() => _value.text = ResultFormatter.format(value));
                  },
                  icon: const Icon(Icons.mic_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _UnitDropdown(
                    label: context.tr('converter_from'),
                    value: _from,
                    units: _category.units,
                    onChanged: (unit) => setState(() => _from = unit),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: IconButton(
                    tooltip: context.tr('converter_to'),
                    onPressed: () => setState(() {
                      final temp = _from;
                      _from = _to;
                      _to = temp;
                    }),
                    icon: Icon(
                      Icons.swap_horiz_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: _UnitDropdown(
                    label: context.tr('converter_to'),
                    value: _to,
                    units: _category.units,
                    onChanged: (unit) => setState(() => _to = unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              border: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('converter_result'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      converted == null ? '—' : '$formatted ${_to.symbol}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_value.text} ${_from.symbol} = $formatted ${_to.symbol}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (words.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(words, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: formatted.isEmpty
                        ? null
                        : () async {
                            await ref
                                .read(platformServicesProvider)
                                .copy('$formatted ${_to.symbol}');
                            if (!context.mounted) return;
                            showAppSnack(context, context.tr('copied'));
                          },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(context.tr('copy')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: converted == null
                        ? null
                        : () async {
                            final s = ref.read(settingsControllerProvider);
                            try {
                              await ref
                                  .read(speechSynthesizerProvider)
                                  .speak(
                                    words,
                                    locale: s.effectiveTtsLanguage.ttsLocale,
                                    rate: s.speechRate,
                                    pitch: s.speechPitch,
                                  );
                            } catch (_) {
                              if (!context.mounted) return;
                              showAppSnack(
                                context,
                                context.tr('voice_unavailable'),
                                error: true,
                              );
                            }
                          },
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: Text(context.tr('speak')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GradientButton(
              label: context.tr('save'),
              icon: Icons.bookmark_add_rounded,
              onPressed: converted == null
                  ? null
                  : () async {
                      await ref
                          .read(historyControllerProvider.notifier)
                          .add(
                            expression:
                                '${_value.text} ${_from.symbol} → ${_to.symbol}',
                            result: '$formatted ${_to.symbol}',
                            value: converted,
                            type: CalculationType.converter,
                            languageCode: settings.language.code,
                          );
                      if (!context.mounted) return;
                      showAppSnack(context, context.tr('calc_saved'));
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.label,
    required this.value,
    required this.units,
    required this.onChanged,
  });

  final String label;
  final UnitOption value;
  final List<UnitOption> units;
  final ValueChanged<UnitOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UnitOption>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final unit in units)
          DropdownMenuItem(
            value: unit,
            child: Text(
              '${unit.name} (${unit.symbol})',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
      ],
      onChanged: (unit) {
        if (unit != null) onChanged(unit);
      },
    );
  }
}
