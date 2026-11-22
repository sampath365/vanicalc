/// Stable error codes produced by the calculation engine.
///
/// The localization layer maps these codes to translated messages.
class CalcError {
  const CalcError._();

  static const String empty = 'error_empty';
  static const String invalid = 'error_invalid_expression';
  static const String divideByZero = 'error_divide_by_zero';
  static const String overflow = 'error_overflow';
  static const String domain = 'error_domain';
  static const String factorial = 'error_factorial';
  static const String unbalanced = 'error_unbalanced';
}
