import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/voice_input.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../history/domain/calculation_record.dart';
import '../domain/financial_calculators.dart';

/// GST calculator with add/remove modes, rate presets, CGST/SGST/IGST
/// breakup and amount in words.
class GstCalculatorScreen extends ConsumerStatefulWidget {
  const GstCalculatorScreen({super.key});

  @override
  ConsumerState<GstCalculatorScreen> createState() =>
      _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends ConsumerState<GstCalculatorScreen> {
  final TextEditingController _amount = TextEditingController(text: '10000');
  final TextEditingController _customRate = TextEditingController();
  bool _addGst = true;
  double _rate = 18;

  static const _presets = [5.0, 12.0, 18.0, 28.0];

  @override
  void dispose() {
    _amount.dispose();
    _customRate.dispose();
    super.dispose();
  }

  double? get _amountValue => double.tryParse(_amount.text.trim());

  GstResult? get _result {
    final amount = _amountValue;
    if (amount == null || amount < 0 || _rate < 0) return null;
    return _addGst
        ? FinancialCalculators.addGst(amount, _rate)
        : FinancialCalculators.removeGst(amount, _rate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final result = _result;
    final words = result == null
        ? ''
        : ref.read(numberToWordsEngineProvider).fromString(
              ResultFormatter.format(result.totalAmount),
              languageCode: settings.language.code,
              system: settings.numberSystem,
              currency: true,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('gst_title')),
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
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(context.tr('gst_add')),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  label: Text(context.tr('gst_remove')),
                ),
              ],
              selected: {_addGst},
              onSelectionChanged: (selection) =>
                  setState(() => _addGst = selection.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.tr('gst_amount'),
                prefixText: '₹ ',
                suffixIcon: IconButton(
                  tooltip: context.tr('voice_tap_to_speak'),
                  onPressed: () async {
                    final value = await captureSpokenNumber(context, ref);
                    if (value == null) return;
                    setState(() {
                      _amount.text = ResultFormatter.format(value);
                    });
                  },
                  icon: const Icon(Icons.mic_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.tr('gst_rate'), style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in _presets)
                  ChoiceChip(
                    label: Text('${preset.toInt()}%'),
                    selected: _rate == preset,
                    onSelected: (_) => setState(() {
                      _rate = preset;
                      _customRate.clear();
                    }),
                  ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _customRate,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: context.tr('gst_custom'),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixText: '%',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      setState(() {
                        if (parsed != null && parsed >= 0) _rate = parsed;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (result == null)
              SurfaceCard(
                child: Text(
                  context.tr('invalid_input'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              )
            else ...[
              SurfaceCard(
                child: Column(
                  children: [
                    _ResultRow(
                      label: context.tr('gst_taxable'),
                      value: result.baseAmount,
                      system: settings.numberSystem,
                    ),
                    const Divider(height: 22),
                    _ResultRow(
                      label: context.tr('gst_amount_label'),
                      value: result.gstAmount,
                      system: settings.numberSystem,
                    ),
                    const Divider(height: 22),
                    _ResultRow(
                      label: context.tr('gst_cgst'),
                      value: result.cgst,
                      system: settings.numberSystem,
                    ),
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: context.tr('gst_sgst'),
                      value: result.sgst,
                      system: settings.numberSystem,
                    ),
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: context.tr('gst_igst'),
                      value: result.igst,
                      system: settings.numberSystem,
                    ),
                    const Divider(height: 22),
                    _ResultRow(
                      label: context.tr('gst_final'),
                      value: result.totalAmount,
                      system: settings.numberSystem,
                      emphasized: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                border: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('gst_words'),
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(platformServicesProvider)
                                .copy(words);
                            if (!context.mounted) return;
                            showAppSnack(context, context.tr('copied'));
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                        ),
                        IconButton(
                          onPressed: () async {
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(words, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GradientButton(
                label: context.tr('save'),
                icon: Icons.bookmark_add_rounded,
                onPressed: () async {
                  await ref.read(historyControllerProvider.notifier).add(
                        expression:
                            'GST ${_addGst ? '+' : '-'}${_rate.toInt()}% on ₹${ResultFormatter.grouped(result.baseAmount, system: settings.numberSystem)}',
                        result: '₹${ResultFormatter.grouped(result.totalAmount, system: settings.numberSystem)}',
                        value: result.totalAmount,
                        type: CalculationType.gst,
                        languageCode: settings.language.code,
                      );
                  if (!context.mounted) return;
                  showAppSnack(context, context.tr('calc_saved'));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.system,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final NumberSystem system;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized
                ? theme.textTheme.titleMedium
                : theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          '₹ ${ResultFormatter.grouped(value, system: system)}',
          style: (emphasized
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            color: emphasized ? theme.colorScheme.primary : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
