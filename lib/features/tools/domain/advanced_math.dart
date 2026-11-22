import 'dart:math' as math;

/// Roots of a quadratic equation, real or complex.
class QuadraticResult {
  const QuadraticResult({
    required this.discriminant,
    this.root1,
    this.root2,
    this.realPart,
    this.imaginaryPart,
    required this.hasComplexRoots,
  });

  final double discriminant;
  final double? root1;
  final double? root2;
  final double? realPart;
  final double? imaginaryPart;
  final bool hasComplexRoots;
}

/// Descriptive statistics for a list of values.
class StatisticsResult {
  const StatisticsResult({
    required this.count,
    required this.sum,
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    required this.variance,
    required this.standardDeviation,
    this.mode,
  });

  final int count;
  final double sum;
  final double mean;
  final double median;
  final double? mode;
  final double min;
  final double max;
  final double variance;
  final double standardDeviation;
}

/// Conversion of an integer between common bases.
class BaseConversionResult {
  const BaseConversionResult({
    required this.decimal,
    required this.binary,
    required this.octal,
    required this.hexadecimal,
  });

  final int decimal;
  final String binary;
  final String octal;
  final String hexadecimal;
}

/// Pure helpers for the advanced calculator screens.
class AdvancedMath {
  const AdvancedMath._();

  /// Solves `ax² + bx + c = 0`. Returns `null` when `a` is zero.
  static QuadraticResult? solveQuadratic(double a, double b, double c) {
    if (a == 0) return null;
    final discriminant = b * b - 4 * a * c;
    if (discriminant >= 0) {
      final root = math.sqrt(discriminant);
      return QuadraticResult(
        discriminant: discriminant,
        root1: (-b + root) / (2 * a),
        root2: (-b - root) / (2 * a),
        hasComplexRoots: false,
      );
    }
    final real = -b / (2 * a);
    final imaginary = math.sqrt(-discriminant) / (2 * a).abs();
    return QuadraticResult(
      discriminant: discriminant,
      realPart: real,
      imaginaryPart: imaginary,
      hasComplexRoots: true,
    );
  }

  static StatisticsResult? statistics(
    List<double> values, {
    bool sample = true,
  }) {
    if (values.isEmpty) return null;
    final sorted = List<double>.from(values)..sort();
    final count = sorted.length;
    final sum = sorted.fold<double>(0, (total, value) => total + value);
    final mean = sum / count;
    final median = count.isOdd
        ? sorted[count ~/ 2]
        : (sorted[count ~/ 2 - 1] + sorted[count ~/ 2]) / 2;

    final divisor = sample && count > 1 ? count - 1 : count;
    final variance = divisor == 0
        ? 0.0
        : sorted.fold<double>(
                0,
                (total, value) => total + math.pow(value - mean, 2),
              ) /
              divisor;

    final frequencies = <double, int>{};
    for (final value in sorted) {
      frequencies[value] = (frequencies[value] ?? 0) + 1;
    }
    var bestValue = sorted.first;
    var bestCount = 0;
    for (final entry in frequencies.entries) {
      if (entry.value > bestCount) {
        bestCount = entry.value;
        bestValue = entry.key;
      }
    }

    return StatisticsResult(
      count: count,
      sum: sum,
      mean: mean,
      median: median,
      mode: bestCount > 1 ? bestValue : null,
      min: sorted.first,
      max: sorted.last,
      variance: variance,
      standardDeviation: math.sqrt(variance),
    );
  }

  /// Parses numbers separated by commas, spaces or semicolons.
  static List<double> parseNumbers(String input) {
    return input
        .split(RegExp(r'[\s,;]+'))
        .where((part) => part.trim().isNotEmpty)
        .map(double.tryParse)
        .whereType<double>()
        .toList(growable: false);
  }

  static BaseConversionResult? convertBase(String input, int base) {
    final trimmed = input.trim().toLowerCase().replaceAll('_', '');
    if (trimmed.isEmpty) return null;
    final decimal = int.tryParse(trimmed, radix: base);
    if (decimal == null || decimal < 0) return null;
    return BaseConversionResult(
      decimal: decimal,
      binary: decimal.toRadixString(2),
      octal: decimal.toRadixString(8),
      hexadecimal: decimal.toRadixString(16).toUpperCase(),
    );
  }

  static int gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final temp = y;
      y = x % y;
      x = temp;
    }
    return x;
  }

  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() ~/ gcd(a, b)) * b.abs();
  }

  static int permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) return 0;
    var result = 1;
    for (var index = 0; index < r; index++) {
      result *= n - index;
    }
    return result;
  }

  static int combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) return 0;
    final k = math.min(r, n - r);
    var result = 1;
    for (var index = 1; index <= k; index++) {
      result = result * (n - k + index) ~/ index;
    }
    return result;
  }

  static bool isPrime(int value) {
    if (value < 2) return false;
    if (value % 2 == 0) return value == 2;
    for (var divisor = 3; divisor * divisor <= value; divisor += 2) {
      if (value % divisor == 0) return false;
    }
    return true;
  }

  static List<int> primeFactors(int value) {
    var remaining = value.abs();
    final factors = <int>[];
    if (remaining < 2) return factors;
    for (var divisor = 2; divisor * divisor <= remaining; divisor++) {
      while (remaining % divisor == 0) {
        factors.add(divisor);
        remaining ~/= divisor;
      }
    }
    if (remaining > 1) factors.add(remaining);
    return factors;
  }
}
