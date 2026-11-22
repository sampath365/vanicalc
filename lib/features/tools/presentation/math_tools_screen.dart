import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../../../shared/voice_input.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../gst/domain/financial_calculators.dart';
import '../widgets/tool_widgets.dart';

enum _PercentMode { of, isWhat, change }

Widget _invalid(BuildContext context) => Text(
      context.tr('invalid_input'),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );

/// Percentage calculator with three common modes.
class PercentageScreen extends ConsumerStatefulWidget {
  const PercentageScreen({super.key});

  @override
  ConsumerState<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends ConsumerState<PercentageScreen> {
  final TextEditingController _a = TextEditingController(text: '15');
  final TextEditingController _b = TextEditingController(text: '200');
  _PercentMode _mode = _PercentMode.of;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  double? get _result {
    final a = double.tryParse(_a.text.trim());
    final b = double.tryParse(_b.text.trim());
    if (a == null || b == null) return null;
    return switch (_mode) {
      _PercentMode.of => FinancialCalculators.percentOf(a, b),
      _PercentMode.isWhat => FinancialCalculators.whatPercent(a, b),
      _PercentMode.change => FinancialCalculators.percentChange(a, b),
    };
  }

  String _labelA(BuildContext context) => switch (_mode) {
        _PercentMode.of => context.tr('percent'),
        _PercentMode.isWhat => context.tr('value_a'),
        _PercentMode.change => context.tr('original_value'),
      };

  String _labelB(BuildContext context) => switch (_mode) {
        _PercentMode.of => context.tr('amount'),
        _PercentMode.isWhat => context.tr('value_b'),
        _PercentMode.change => context.tr('new_value'),
      };

  String _format(double value) {
    final text = ResultFormatter.format(value);
    return _mode == _PercentMode.of ? text : '$text %';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final result = _result;
    final words = result == null
        ? ''
        : ref.read(numberToWordsEngineProvider).fromString(
              ResultFormatter.format(result),
              languageCode: settings.language.code,
              system: settings.numberSystem,
            );

    return ToolPage(
      title: context.tr('tool_percentage'),
      children: [
        SegmentedButton<_PercentMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: _PercentMode.of, label: Text(context.tr('percent'))),
            ButtonSegment(value: _PercentMode.isWhat, label: Text('a → %')),
            ButtonSegment(value: _PercentMode.change, label: Text('% Δ')),
          ],
          selected: {_mode},
          onSelectionChanged: (selection) => setState(() => _mode = selection.first),
        ),
        const SizedBox(height: 16),
        ToolField(
          controller: _a,
          label: _labelA(context),
          onChanged: (_) => setState(() {}),
          allowVoice: true,
          onVoice: () async {
            final value = await _voice(context);
            if (value == null) return;
            setState(() => _a.text = ResultFormatter.format(value));
          },
        ),
        ToolField(
          controller: _b,
          label: _labelB(context),
          onChanged: (_) => setState(() {}),
          allowVoice: true,
          onVoice: () async {
            final value = await _voice(context);
            if (value == null) return;
            setState(() => _b.text = ResultFormatter.format(value));
          },
        ),
        const SizedBox(height: 4),
        if (result == null)
          Text(
            context.tr('invalid_input'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else
          ToolResultCard(
            rows: [
              ToolRowData(context.tr('result'), _format(result), emphasized: true),
            ],
            words: words,
            onSpeak: () => speakWithSettings(context, ref, words),
            onCopy: () => copyWithFeedback(context, ref, '${_a.text} / ${_b.text} = $_format(result)'),
          ),
      ],
    );
  }

  Future<double?> _voice(BuildContext context) async {
    return captureSpokenNumber(context, ref);
  }
}

/// Simplifies a ratio and shows its decimal value.
class RatioScreen extends ConsumerStatefulWidget {
  const RatioScreen({super.key});

  @override
  ConsumerState<RatioScreen> createState() => _RatioScreenState();
}

class _RatioScreenState extends ConsumerState<RatioScreen> {
  final TextEditingController _a = TextEditingController(text: '16');
  final TextEditingController _b = TextEditingController(text: '24');

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_a.text.trim());
    final b = double.tryParse(_b.text.trim());
    final invalid = a == null || b == null || b == 0;

    return ToolPage(
      title: context.tr('tool_ratio'),
      children: [
        Row(
          children: [
            Expanded(
              child: ToolField(
                controller: _a,
                label: context.tr('value_a'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToolField(
                controller: _b,
                label: context.tr('value_b'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (invalid) _invalid(context) else _result(context, a, b),
      ],
    );
  }

  Widget _result(BuildContext context, double a, double b) {
    final settings = ref.read(settingsControllerProvider);
    final ratio = FinancialCalculators.simplifyRatio(a, b);
    final decimal = a / b;
    final words = ref.read(numberToWordsEngineProvider).fromString(
          ResultFormatter.format(decimal),
          languageCode: settings.language.code,
          system: settings.numberSystem,
        );
    return ToolResultCard(
      rows: [
        ToolRowData(context.tr('ratio_result'), ratio, emphasized: true),
        ToolRowData(
          context.tr('decimal_value'),
          ResultFormatter.format(decimal),
        ),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        '${_a.text} : ${_b.text} = $ratio',
      ),
    );
  }
}

/// Fraction to decimal conversion and simplification.
class FractionScreen extends ConsumerStatefulWidget {
  const FractionScreen({super.key});

  @override
  ConsumerState<FractionScreen> createState() => _FractionScreenState();
}

class _FractionScreenState extends ConsumerState<FractionScreen> {
  final TextEditingController _numerator = TextEditingController(text: '3');
  final TextEditingController _denominator = TextEditingController(text: '8');

  @override
  void dispose() {
    _numerator.dispose();
    _denominator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numerator = int.tryParse(_numerator.text.trim());
    final denominator = int.tryParse(_denominator.text.trim());
    final invalid =
        numerator == null || denominator == null || denominator == 0;

    return ToolPage(
      title: context.tr('tool_fraction'),
      children: [
        Row(
          children: [
            Expanded(
              child: ToolField(
                controller: _numerator,
                label: context.tr('fraction_a'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToolField(
                controller: _denominator,
                label: context.tr('fraction_b'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (invalid) _invalid(context) else _result(context, numerator, denominator),
      ],
    );
  }

  Widget _result(BuildContext context, int numerator, int denominator) {
    final settings = ref.read(settingsControllerProvider);
    final value = numerator / denominator;
    final words = ref.read(numberToWordsEngineProvider).fromString(
          ResultFormatter.format(value),
          languageCode: settings.language.code,
          system: settings.numberSystem,
        );
    return ToolResultCard(
      rows: [
        ToolRowData(
          context.tr('decimal_value'),
          ResultFormatter.format(value),
          emphasized: true,
        ),
        ToolRowData(
          context.tr('simplified'),
          FinancialCalculators.simplifyFraction(numerator, denominator),
        ),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        '${_numerator.text}/${_denominator.text} = ${ResultFormatter.format(value)}',
      ),
    );
  }
}

/// Age calculator using two date pickers.
class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  DateTime _birthDate = DateTime(1995, 1, 1);
  DateTime _asOn = DateTime.now();

  Future<void> _pickDate({required bool birth}) async {
    final initial = birth ? _birthDate : _asOn;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null) return;
    setState(() {
      if (birth) {
        _birthDate = picked;
      } else {
        _asOn = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final result = FinancialCalculators.dateDifference(_birthDate, _asOn);
    final words = ref.read(numberToWordsEngineProvider).convert(
          result.totalDays,
          languageCode: settings.language.code,
          system: settings.numberSystem,
        );

    return ToolPage(
      title: context.tr('tool_age'),
      children: [
        _DateTile(
          label: context.tr('date_of_birth'),
          date: _birthDate,
          onTap: () => _pickDate(birth: true),
        ),
        const SizedBox(height: 12),
        _DateTile(
          label: context.tr('as_on'),
          date: _asOn,
          onTap: () => _pickDate(birth: false),
        ),
        const SizedBox(height: 16),
        ToolResultCard(
          rows: [
            ToolRowData(
              context.tr('age_result'),
              '${result.years} ${context.tr('years_short')} '
                  '${result.months} ${context.tr('months_short')} '
                  '${result.days} ${context.tr('days_short')}',
              emphasized: true,
            ),
            ToolRowData(context.tr('total_days'), '${result.totalDays}'),
            ToolRowData(
              context.tr('total_weeks'),
              result.totalWeeks.toStringAsFixed(1),
            ),
            ToolRowData(
              context.tr('total_months'),
              result.totalMonths.toStringAsFixed(1),
            ),
          ],
          words: words,
          onSpeak: () => speakWithSettings(context, ref, words),
          onCopy: () => copyWithFeedback(
            context,
            ref,
            '${result.years} years ${result.months} months ${result.days} days',
          ),
        ),
      ],
    );
  }
}

/// Difference between two dates.
class DateDifferenceScreen extends ConsumerStatefulWidget {
  const DateDifferenceScreen({super.key});

  @override
  ConsumerState<DateDifferenceScreen> createState() =>
      _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends ConsumerState<DateDifferenceScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  Future<void> _pick({required bool from}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? _from : _to,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final result = FinancialCalculators.dateDifference(_from, _to);
    final words = ref.read(numberToWordsEngineProvider).convert(
          result.totalDays,
          languageCode: settings.language.code,
          system: settings.numberSystem,
        );

    return ToolPage(
      title: context.tr('tool_date_diff'),
      children: [
        _DateTile(
          label: context.tr('date_from'),
          date: _from,
          onTap: () => _pick(from: true),
        ),
        const SizedBox(height: 12),
        _DateTile(
          label: context.tr('date_to'),
          date: _to,
          onTap: () => _pick(from: false),
        ),
        const SizedBox(height: 16),
        ToolResultCard(
          rows: [
            ToolRowData(
              context.tr('difference_result'),
              '${result.years} ${context.tr('years_short')} '
                  '${result.months} ${context.tr('months_short')} '
                  '${result.days} ${context.tr('days_short')}',
              emphasized: true,
            ),
            ToolRowData(context.tr('total_days'), '${result.totalDays}'),
            ToolRowData(
              context.tr('total_weeks'),
              result.totalWeeks.toStringAsFixed(1),
            ),
            ToolRowData(
              context.tr('total_months'),
              result.totalMonths.toStringAsFixed(1),
            ),
            ToolRowData(
              context.tr('total_years'),
              result.totalYears.toStringAsFixed(2),
            ),
          ],
          words: words,
          onSpeak: () => speakWithSettings(context, ref, words),
          onCopy: () => copyWithFeedback(context, ref, '${result.totalDays} days'),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 18,
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_calendar_rounded,
            size: 18,
            color: theme.textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}
