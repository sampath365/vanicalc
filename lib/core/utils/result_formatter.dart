import '../constants/number_system.dart';

/// Formats doubles for display without floating point noise.
class ResultFormatter {
  const ResultFormatter._();

  static const int _precision = 12;
  static const double _plainLimit = 1e15;

  /// Formats [value] with up to 12 significant digits and no trailing zeros.
  static String format(num value, {int precision = _precision}) {
    if (value is int) return value.toString();
    final d = value.toDouble();
    if (d.isNaN) return 'NaN';
    if (d.isInfinite) return d.isNegative ? '-∞' : '∞';
    if (d == 0) return '0';

    if (d == d.roundToDouble() && d.abs() < _plainLimit) {
      return d.toInt().toString();
    }

    final raw = d.toStringAsPrecision(precision);
    if (raw.contains('e')) {
      final parts = raw.split('e');
      final mantissa = _trim(parts[0]);
      final exponent = int.parse(parts[1]).toString();
      return '${mantissa}e$exponent';
    }
    return _trim(raw);
  }

  static String _trim(String value) {
    if (!value.contains('.')) return value;
    var out = value.replaceFirst(RegExp(r'0+$'), '');
    if (out.endsWith('.')) out = out.substring(0, out.length - 1);
    if (out == '-0') return '0';
    return out;
  }

  /// Groups the integer part of [value] using the selected numbering system.
  static String grouped(
    num value, {
    NumberSystem system = NumberSystem.international,
  }) {
    final text = format(value);
    if (text.contains('e') || text.contains('∞') || text == 'NaN') return text;

    var sign = '';
    var body = text;
    if (body.startsWith('-')) {
      sign = '-';
      body = body.substring(1);
    }
    final dot = body.indexOf('.');
    var whole = dot == -1 ? body : body.substring(0, dot);
    final fraction = dot == -1 ? '' : body.substring(dot);
    if (whole.length <= 3) return '$sign$whole$fraction';

    if (system == NumberSystem.indian) {
      final last3 = whole.substring(whole.length - 3);
      var rest = whole.substring(0, whole.length - 3);
      final chunks = <String>[];
      while (rest.length > 2) {
        chunks.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) chunks.insert(0, rest);
      return '$sign${chunks.join(',')},$last3$fraction';
    }

    final chunks = <String>[];
    var i = whole.length;
    while (i > 0) {
      final start = i - 3 < 0 ? 0 : i - 3;
      chunks.insert(0, whole.substring(start, i));
      i = start;
    }
    return '$sign${chunks.join(',')}$fraction';
  }
}
