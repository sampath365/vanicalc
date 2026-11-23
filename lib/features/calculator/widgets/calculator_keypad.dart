import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_widgets.dart';

enum CalcKeyType { number, operator, function, equals, destructive }

class CalcKeySpec {
  const CalcKeySpec(this.value, {this.label, this.flex = 1});

  final String value;
  final String? label;
  final int flex;

  CalcKeyType get type {
    if (value == '=') return CalcKeyType.equals;
    if (value == 'AC') return CalcKeyType.destructive;
    if (RegExp(r'^\d$').hasMatch(value) || value == '.') {
      return CalcKeyType.number;
    }
    if (const {'+', '-', '*', '/', '^'}.contains(value)) {
      return CalcKeyType.operator;
    }
    return CalcKeyType.function;
  }

  String get display {
    if (label != null) return label!;
    return switch (value) {
      '*' => '×',
      '/' => '÷',
      'back' => '⌫',
      'sqrt(' => '√',
      'square' => 'x²',
      'cube' => 'x³',
      'reciprocal' => '1/x',
      'pi' => 'π',
      '+/-' => '±',
      _ => value,
    };
  }
}

/// The keypad used by both the standard and scientific calculators.
class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.onKey,
    this.scientific = false,
  });

  final ValueChanged<String> onKey;
  final bool scientific;

  static const List<List<CalcKeySpec>> standardRows = [
    [
      CalcKeySpec('AC'),
      CalcKeySpec('('),
      CalcKeySpec(')'),
      CalcKeySpec('back'),
    ],
    [CalcKeySpec('7'), CalcKeySpec('8'), CalcKeySpec('9'), CalcKeySpec('/')],
    [CalcKeySpec('4'), CalcKeySpec('5'), CalcKeySpec('6'), CalcKeySpec('*')],
    [CalcKeySpec('1'), CalcKeySpec('2'), CalcKeySpec('3'), CalcKeySpec('-')],
    [CalcKeySpec('+/-'), CalcKeySpec('0'), CalcKeySpec('.'), CalcKeySpec('+')],
    [CalcKeySpec('%'), CalcKeySpec('mod'), CalcKeySpec('=', flex: 2)],
  ];

  static const List<List<CalcKeySpec>> scientificRows = [
    [
      CalcKeySpec('sin('),
      CalcKeySpec('cos('),
      CalcKeySpec('tan('),
      CalcKeySpec('log('),
      CalcKeySpec('ln('),
    ],
    [
      CalcKeySpec('sqrt('),
      CalcKeySpec('square'),
      CalcKeySpec('cube'),
      CalcKeySpec('^'),
      CalcKeySpec('reciprocal'),
    ],
    [
      CalcKeySpec('pi'),
      CalcKeySpec('e'),
      CalcKeySpec('!'),
      CalcKeySpec('mod'),
      CalcKeySpec('back'),
    ],
    [
      CalcKeySpec('AC'),
      CalcKeySpec('('),
      CalcKeySpec(')'),
      CalcKeySpec('%'),
      CalcKeySpec('/'),
    ],
    [
      CalcKeySpec('7'),
      CalcKeySpec('8'),
      CalcKeySpec('9'),
      CalcKeySpec('*'),
      CalcKeySpec('mc'),
    ],
    [
      CalcKeySpec('4'),
      CalcKeySpec('5'),
      CalcKeySpec('6'),
      CalcKeySpec('-'),
      CalcKeySpec('mr'),
    ],
    [
      CalcKeySpec('1'),
      CalcKeySpec('2'),
      CalcKeySpec('3'),
      CalcKeySpec('+'),
      CalcKeySpec('m+'),
    ],
    [
      CalcKeySpec('+/-'),
      CalcKeySpec('0'),
      CalcKeySpec('.'),
      CalcKeySpec('m-'),
      CalcKeySpec('='),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final rows = scientific ? scientificRows : standardRows;
    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    flex: key.flex,
                    child: CalcKeyButton(
                      spec: key,
                      onTap: () => onKey(key.value),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class CalcKeyButton extends StatelessWidget {
  const CalcKeyButton({super.key, required this.spec, required this.onTap});

  final CalcKeySpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalcPalette>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late final Color background;
    late final Color foreground;
    late final double fontSize;

    switch (spec.type) {
      case CalcKeyType.number:
        background = palette.numberButton;
        foreground = palette.onNumber;
        fontSize = 24;
      case CalcKeyType.operator:
        background = palette.operatorButton;
        foreground = palette.onOperator;
        fontSize = 24;
      case CalcKeyType.destructive:
        background = isDark
            ? AppColors.danger.withValues(alpha: 0.16)
            : AppColors.danger.withValues(alpha: 0.1);
        foreground = AppColors.danger;
        fontSize = 18;
      case CalcKeyType.equals:
        background = Colors.transparent;
        foreground = Colors.white;
        fontSize = 26;
      case CalcKeyType.function:
        background = palette.functionButton;
        foreground = palette.onFunction;
        fontSize = spec.display.length > 2 ? 15 : 19;
    }

    final content = Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: spec.type == CalcKeyType.equals ? null : background,
        gradient: spec.type == CalcKeyType.equals
            ? LinearGradient(
                colors: [palette.equalsStart, palette.equalsEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: spec.value == 'back'
          ? Icon(Icons.backspace_outlined, size: 22, color: foreground)
          : Text(
              spec.display,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: spec.type == CalcKeyType.number
                    ? FontWeight.w600
                    : FontWeight.w700,
                color: foreground,
                letterSpacing: -0.2,
              ),
            ),
    );

    return Semantics(
      key: ValueKey('calc_key_${spec.value}'),
      button: true,
      label: spec.value == 'back' ? 'Backspace' : spec.display,
      child: PressableScale(onTap: onTap, scale: 0.92, child: content),
    );
  }
}

/// Horizontal strip of scientific shortcuts shown above the standard keypad.
class FunctionStrip extends StatelessWidget {
  const FunctionStrip({super.key, required this.onKey});

  final ValueChanged<String> onKey;

  static const List<CalcKeySpec> keys = [
    CalcKeySpec('sqrt('),
    CalcKeySpec('square'),
    CalcKeySpec('cube'),
    CalcKeySpec('^'),
    CalcKeySpec('reciprocal'),
    CalcKeySpec('pi'),
    CalcKeySpec('!'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<CalcPalette>()!;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: keys.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final spec = keys[index];
          return PressableScale(
            key: ValueKey('calc_fn_${spec.value}'),
            scale: 0.93,
            onTap: () => onKey(spec.value),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: palette.functionButton,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                spec.display,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.onFunction,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Memory chips shown inside the calculator display card.
class MemoryBar extends StatelessWidget {
  const MemoryBar({
    super.key,
    required this.memorySet,
    required this.memory,
    required this.onKey,
    required this.memoryLabel,
  });

  final bool memorySet;
  final double memory;
  final ValueChanged<String> onKey;
  final String memoryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        for (final key in const ['mc', 'mr', 'm+', 'm-'])
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: memorySet || key == 'mc' || key == 'm+' || key == 'm-'
                  ? () => onKey(key)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  key.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        Text(
          memorySet ? '$memoryLabel ${_format(memory)}' : memoryLabel,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');
  }
}
