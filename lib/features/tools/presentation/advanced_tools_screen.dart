import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app_providers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/result_formatter.dart';
import '../domain/advanced_math.dart';
import '../widgets/tool_widgets.dart';

Widget _invalidText(BuildContext context) => Text(
  context.tr('invalid_input'),
  style: TextStyle(color: Theme.of(context).colorScheme.error),
);

String _fmt(double value) => ResultFormatter.format(value);

String _words(BuildContext context, WidgetRef ref, double value) {
  final settings = ref.read(settingsControllerProvider);
  return ref
      .read(numberToWordsEngineProvider)
      .fromString(
        _fmt(value),
        languageCode: settings.language.code,
        system: settings.numberSystem,
      );
}

/// Solves ax² + bx + c = 0, including complex roots.
class QuadraticScreen extends ConsumerStatefulWidget {
  const QuadraticScreen({super.key});

  @override
  ConsumerState<QuadraticScreen> createState() => _QuadraticScreenState();
}

class _QuadraticScreenState extends ConsumerState<QuadraticScreen> {
  final TextEditingController _a = TextEditingController(text: '1');
  final TextEditingController _b = TextEditingController(text: '-3');
  final TextEditingController _c = TextEditingController(text: '2');

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = double.tryParse(_a.text.trim());
    final b = double.tryParse(_b.text.trim());
    final c = double.tryParse(_c.text.trim());
    final invalid = a == null || b == null || c == null || a == 0;

    return ToolPage(
      title: context.tr('tool_quadratic'),
      children: [
        ToolField(
          controller: _a,
          label: context.tr('coefficient_a'),
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _b,
          label: context.tr('coefficient_b'),
          onChanged: (_) => setState(() {}),
        ),
        ToolField(
          controller: _c,
          label: context.tr('coefficient_c'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (invalid) _invalidText(context) else _result(context, a, b, c),
      ],
    );
  }

  Widget _result(BuildContext context, double a, double b, double c) {
    final result = AdvancedMath.solveQuadratic(a, b, c)!;
    final rows = <ToolRowData>[
      ToolRowData(context.tr('discriminant'), _fmt(result.discriminant)),
    ];
    late final String words;
    if (result.hasComplexRoots) {
      rows.add(
        ToolRowData(
          context.tr('complex_roots'),
          '${_fmt(result.realPart!)} ± ${_fmt(result.imaginaryPart!)}i',
          emphasized: true,
        ),
      );
      rows.add(ToolRowData(context.tr('real_part'), _fmt(result.realPart!)));
      rows.add(
        ToolRowData(context.tr('imaginary_part'), _fmt(result.imaginaryPart!)),
      );
      words = _words(context, ref, result.realPart!);
    } else {
      rows.add(
        ToolRowData(
          context.tr('root_1'),
          _fmt(result.root1!),
          emphasized: true,
        ),
      );
      rows.add(ToolRowData(context.tr('root_2'), _fmt(result.root2!)));
      words = _words(context, ref, result.root1!);
    }
    return ToolResultCard(
      rows: rows,
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        'a=${_a.text}, b=${_b.text}, c=${_c.text} • '
        '${context.tr('discriminant')}: ${_fmt(result.discriminant)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: '${_a.text}x² + ${_b.text}x + ${_c.text} = 0',
        result: result.hasComplexRoots
            ? '${_fmt(result.realPart!)} ± ${_fmt(result.imaginaryPart!)}i'
            : 'x1=${_fmt(result.root1!)} , x2=${_fmt(result.root2!)}',
        value: result.root1,
      ),
    );
  }
}

/// Mean, median, mode, spread and range for a list of numbers.
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final TextEditingController _numbers = TextEditingController(
    text: '10, 20, 30, 40, 50',
  );

  @override
  void dispose() {
    _numbers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = AdvancedMath.parseNumbers(_numbers.text);
    final stats = AdvancedMath.statistics(values);

    return ToolPage(
      title: context.tr('tool_statistics'),
      children: [
        ToolField(
          controller: _numbers,
          label: context.tr('numbers_input'),
          numeric: false,
          onChanged: (_) => setState(() {}),
        ),
        Text(
          context.tr('numbers_hint'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        if (stats == null) _invalidText(context) else _result(context, stats),
      ],
    );
  }

  Widget _result(BuildContext context, StatisticsResult stats) {
    final words = _words(context, ref, stats.mean);
    return ToolResultCard(
      rows: [
        ToolRowData(context.tr('count'), '${stats.count}'),
        ToolRowData(context.tr('sum'), _fmt(stats.sum)),
        ToolRowData(context.tr('mean'), _fmt(stats.mean), emphasized: true),
        ToolRowData(context.tr('median'), _fmt(stats.median)),
        ToolRowData(
          context.tr('mode'),
          stats.mode == null ? context.tr('no_mode') : _fmt(stats.mode!),
        ),
        ToolRowData(context.tr('std_dev'), _fmt(stats.standardDeviation)),
        ToolRowData(context.tr('variance'), _fmt(stats.variance)),
        ToolRowData(context.tr('min_value'), _fmt(stats.min)),
        ToolRowData(context.tr('max_value'), _fmt(stats.max)),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        'n=${stats.count} • ${context.tr('mean')}: ${_fmt(stats.mean)} • '
        '${context.tr('median')}: ${_fmt(stats.median)}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: _numbers.text,
        result: '${context.tr('mean')}: ${_fmt(stats.mean)}',
        value: stats.mean,
      ),
    );
  }
}

/// Binary, octal, decimal and hexadecimal conversion.
class BaseConverterScreen extends ConsumerStatefulWidget {
  const BaseConverterScreen({super.key});

  @override
  ConsumerState<BaseConverterScreen> createState() =>
      _BaseConverterScreenState();
}

class _BaseConverterScreenState extends ConsumerState<BaseConverterScreen> {
  final TextEditingController _input = TextEditingController(text: '1010');
  int _base = 2;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = AdvancedMath.convertBase(_input.text, _base);

    return ToolPage(
      title: context.tr('tool_base_converter'),
      children: [
        ToolField(
          controller: _input,
          label: context.tr('number_value'),
          numeric: false,
          onChanged: (_) => setState(() {}),
        ),
        Text(
          context.tr('base_input_hint'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 2, label: Text('BIN')),
            ButtonSegment(value: 8, label: Text('OCT')),
            ButtonSegment(value: 10, label: Text('DEC')),
            ButtonSegment(value: 16, label: Text('HEX')),
          ],
          selected: {_base},
          onSelectionChanged: (selection) =>
              setState(() => _base = selection.first),
        ),
        const SizedBox(height: 16),
        if (result == null) _invalidText(context) else _result(context, result),
      ],
    );
  }

  Widget _result(BuildContext context, BaseConversionResult result) {
    final words = _words(context, ref, result.decimal.toDouble());
    return ToolResultCard(
      rows: [
        ToolRowData(context.tr('binary'), result.binary, emphasized: true),
        ToolRowData(context.tr('octal'), result.octal),
        ToolRowData(context.tr('decimal'), '${result.decimal}'),
        ToolRowData(context.tr('hexadecimal'), result.hexadecimal),
      ],
      words: words,
      onSpeak: () => speakWithSettings(context, ref, words),
      onCopy: () => copyWithFeedback(
        context,
        ref,
        'BIN ${result.binary} • OCT ${result.octal} • '
        'DEC ${result.decimal} • HEX ${result.hexadecimal}',
      ),
      onSave: () => saveToolHistory(
        context,
        ref,
        expression: '${_input.text} (base $_base)',
        result: 'DEC ${result.decimal}',
        value: result.decimal.toDouble(),
      ),
    );
  }
}

/// GCD/LCM, permutations/combinations and prime tools in one screen.
class NumberToolsScreen extends ConsumerStatefulWidget {
  const NumberToolsScreen({super.key});

  @override
  ConsumerState<NumberToolsScreen> createState() => _NumberToolsScreenState();
}

class _NumberToolsScreenState extends ConsumerState<NumberToolsScreen> {
  final TextEditingController _gcdA = TextEditingController(text: '48');
  final TextEditingController _gcdB = TextEditingController(text: '18');
  final TextEditingController _n = TextEditingController(text: '5');
  final TextEditingController _r = TextEditingController(text: '2');
  final TextEditingController _prime = TextEditingController(text: '97');

  @override
  void dispose() {
    _gcdA.dispose();
    _gcdB.dispose();
    _n.dispose();
    _r.dispose();
    _prime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = int.tryParse(_gcdA.text.trim());
    final b = int.tryParse(_gcdB.text.trim());
    final n = int.tryParse(_n.text.trim());
    final r = int.tryParse(_r.text.trim());
    final prime = int.tryParse(_prime.text.trim());

    final rows = <ToolRowData>[];
    String words = '';
    if (a != null && b != null) {
      rows.add(ToolRowData(context.tr('gcd'), '${AdvancedMath.gcd(a, b)}'));
      rows.add(ToolRowData(context.tr('lcm'), '${AdvancedMath.lcm(a, b)}'));
    }
    if (n != null && r != null) {
      rows.add(
        ToolRowData(
          context.tr('permutations'),
          '${AdvancedMath.permutations(n, r)}',
        ),
      );
      rows.add(
        ToolRowData(
          context.tr('combinations'),
          '${AdvancedMath.combinations(n, r)}',
          emphasized: true,
        ),
      );
    }
    if (prime != null) {
      rows.add(
        ToolRowData(
          context.tr('is_prime'),
          AdvancedMath.isPrime(prime)
              ? context.tr('prime_yes')
              : context.tr('prime_no'),
        ),
      );
      final factors = AdvancedMath.primeFactors(prime);
      rows.add(
        ToolRowData(
          context.tr('prime_factors'),
          factors.isEmpty ? '—' : factors.join(' × '),
        ),
      );
      words = _words(context, ref, prime.toDouble());
    }

    return ToolPage(
      title: context.tr('tool_number_tools'),
      children: [
        Row(
          children: [
            Expanded(
              child: ToolField(
                controller: _gcdA,
                label: context.tr('value_a'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToolField(
                controller: _gcdB,
                label: context.tr('value_b'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ToolField(
                controller: _n,
                label: context.tr('n_value'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToolField(
                controller: _r,
                label: context.tr('r_value'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolField(
          controller: _prime,
          label: context.tr('number_value'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        if (rows.isEmpty)
          _invalidText(context)
        else
          ToolResultCard(
            rows: rows,
            words: words,
            onSpeak: words.isEmpty
                ? null
                : () => speakWithSettings(context, ref, words),
            onCopy: () => copyWithFeedback(
              context,
              ref,
              rows.map((row) => '${row.label}: ${row.value}').join('\n'),
            ),
            onSave: () => saveToolHistory(
              context,
              ref,
              expression:
                  'GCD ${_gcdA.text},${_gcdB.text} • '
                  'nCr ${_n.text},${_r.text} • ${_prime.text}',
              result: rows.map((row) => row.value).join(' | '),
            ),
          ),
      ],
    );
  }
}
