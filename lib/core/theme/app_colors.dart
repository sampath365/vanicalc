import 'package:material_ui/material_ui.dart';

/// Accent palettes available in settings.
enum AccentPalette {
  orange('orange', 'Orange', Color(0xFFFF7A18), Color(0xFFFFA53C)),
  blue('blue', 'Blue', Color(0xFF2563EB), Color(0xFF5B8CFF)),
  teal('teal', 'Teal', Color(0xFF0D9488), Color(0xFF2DD4BF)),
  purple('purple', 'Purple', Color(0xFF7C3AED), Color(0xFFA78BFA)),
  rose('rose', 'Rose', Color(0xFFE11D48), Color(0xFFFB7185));

  const AccentPalette(this.key, this.label, this.seed, this.secondary);

  final String key;
  final String label;
  final Color seed;
  final Color secondary;

  static AccentPalette fromKey(String? key) {
    return AccentPalette.values.firstWhere(
      (palette) => palette.key == key,
      orElse: () => AccentPalette.orange,
    );
  }

  List<Color> get gradient => [seed, secondary];
}

/// Shared surface colours for light and dark themes.
class AppColors {
  const AppColors._();

  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F3F9);
  static const Color lightBorder = Color(0xFFE4E7EE);
  static const Color lightText = Color(0xFF101828);
  static const Color lightTextMuted = Color(0xFF667085);

  static const Color darkBackground = Color(0xFF080D1A);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceAlt = Color(0xFF1B2437);
  static const Color darkBorder = Color(0xFF27314A);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color danger = Color(0xFFF04438);

  static Color muted(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextMuted : lightTextMuted;
}

/// Calculator-specific colours exposed through [ThemeExtension].
class CalcPalette extends ThemeExtension<CalcPalette> {
  const CalcPalette({
    required this.numberButton,
    required this.operatorButton,
    required this.functionButton,
    required this.onNumber,
    required this.onOperator,
    required this.onFunction,
    required this.displayBackground,
    required this.shadow,
    required this.equalsStart,
    required this.equalsEnd,
  });

  final Color numberButton;
  final Color operatorButton;
  final Color functionButton;
  final Color onNumber;
  final Color onOperator;
  final Color onFunction;
  final Color displayBackground;
  final Color shadow;
  final Color equalsStart;
  final Color equalsEnd;

  @override
  CalcPalette copyWith({
    Color? numberButton,
    Color? operatorButton,
    Color? functionButton,
    Color? onNumber,
    Color? onOperator,
    Color? onFunction,
    Color? displayBackground,
    Color? shadow,
    Color? equalsStart,
    Color? equalsEnd,
  }) {
    return CalcPalette(
      numberButton: numberButton ?? this.numberButton,
      operatorButton: operatorButton ?? this.operatorButton,
      functionButton: functionButton ?? this.functionButton,
      onNumber: onNumber ?? this.onNumber,
      onOperator: onOperator ?? this.onOperator,
      onFunction: onFunction ?? this.onFunction,
      displayBackground: displayBackground ?? this.displayBackground,
      shadow: shadow ?? this.shadow,
      equalsStart: equalsStart ?? this.equalsStart,
      equalsEnd: equalsEnd ?? this.equalsEnd,
    );
  }

  @override
  CalcPalette lerp(CalcPalette? other, double t) {
    if (other == null) return this;
    return CalcPalette(
      numberButton: Color.lerp(numberButton, other.numberButton, t)!,
      operatorButton: Color.lerp(operatorButton, other.operatorButton, t)!,
      functionButton: Color.lerp(functionButton, other.functionButton, t)!,
      onNumber: Color.lerp(onNumber, other.onNumber, t)!,
      onOperator: Color.lerp(onOperator, other.onOperator, t)!,
      onFunction: Color.lerp(onFunction, other.onFunction, t)!,
      displayBackground:
          Color.lerp(displayBackground, other.displayBackground, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      equalsStart: Color.lerp(equalsStart, other.equalsStart, t)!,
      equalsEnd: Color.lerp(equalsEnd, other.equalsEnd, t)!,
    );
  }
}
