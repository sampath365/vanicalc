import 'dart:math' as math;

/// GST calculation result with the full tax breakup.
class GstResult {
  const GstResult({
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
    required this.rate,
    required this.added,
  });

  final double baseAmount;
  final double gstAmount;
  final double totalAmount;
  final double rate;
  final bool added;

  double get cgst => gstAmount / 2;
  double get sgst => gstAmount / 2;
  double get igst => gstAmount;
}

/// Result of a loan EMI calculation.
class EmiResult {
  const EmiResult({
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayment,
    required this.months,
  });

  final double monthlyEmi;
  final double totalInterest;
  final double totalPayment;
  final int months;
}

/// Result of an age or date-difference calculation.
class DateDifferenceResult {
  const DateDifferenceResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
  });

  final int years;
  final int months;
  final int days;
  final int totalDays;

  double get totalWeeks => totalDays / 7;
  double get totalMonths => totalDays / 30.4375;
  double get totalYears => totalDays / 365.25;
}

/// Pure, unit-testable financial and everyday maths.
class FinancialCalculators {
  const FinancialCalculators._();

  static GstResult addGst(double amount, double rate) {
    final gst = amount * rate / 100;
    return GstResult(
      baseAmount: amount,
      gstAmount: gst,
      totalAmount: amount + gst,
      rate: rate,
      added: true,
    );
  }

  static GstResult removeGst(double total, double rate) {
    final base = total / (1 + rate / 100);
    return GstResult(
      baseAmount: base,
      gstAmount: total - base,
      totalAmount: total,
      rate: rate,
      added: false,
    );
  }

  static double discountAmount(double price, double percent) =>
      price * percent / 100;

  static double finalPrice(double price, double percent) =>
      price - discountAmount(price, percent);

  static double profitAmount(double cost, double selling) => selling - cost;

  static double profitPercent(double cost, double selling) =>
      cost == 0 ? 0 : (selling - cost) / cost * 100;

  static EmiResult emi({
    required double principal,
    required double annualRate,
    required int months,
  }) {
    if (months <= 0) {
      return const EmiResult(
        monthlyEmi: 0,
        totalInterest: 0,
        totalPayment: 0,
        months: 0,
      );
    }
    final monthlyRate = annualRate / 12 / 100;
    double monthly;
    if (monthlyRate == 0) {
      monthly = principal / months;
    } else {
      final factor = math.pow(1 + monthlyRate, months).toDouble();
      monthly = principal * monthlyRate * factor / (factor - 1);
    }
    final total = monthly * months;
    return EmiResult(
      monthlyEmi: monthly,
      totalInterest: total - principal,
      totalPayment: total,
      months: months,
    );
  }

  static double simpleInterest({
    required double principal,
    required double annualRate,
    required double years,
  }) => principal * annualRate * years / 100;

  static double compoundInterest({
    required double principal,
    required double annualRate,
    required double years,
    int compoundsPerYear = 1,
  }) {
    if (principal == 0) return 0;
    final amount =
        principal *
        math.pow(
          1 + annualRate / (100 * compoundsPerYear),
          compoundsPerYear * years,
        );
    return amount - principal;
  }

  static double percentOf(double percent, double value) =>
      value * percent / 100;

  static double whatPercent(double part, double whole) =>
      whole == 0 ? 0 : part / whole * 100;

  static double percentChange(double from, double to) =>
      from == 0 ? 0 : (to - from) / from * 100;

  static double tipAmount(double bill, double percent) => bill * percent / 100;

  static double perPerson(double total, int people) =>
      people <= 0 ? 0 : total / people;

  /// Simplifies `a : b` using the greatest common divisor.
  static String simplifyRatio(double a, double b) {
    if (a == 0 || b == 0) return '${_trim(a)} : ${_trim(b)}';
    final scale = math.pow(10, 6);
    var left = (a * scale).round();
    var right = (b * scale).round();
    final divisor = _gcd(left.abs(), right.abs());
    if (divisor == 0) return '${_trim(a)} : ${_trim(b)}';
    left ~/= divisor;
    right ~/= divisor;
    return '$left : $right';
  }

  /// Returns the decimal value of a fraction.
  static double fractionValue(double numerator, double denominator) =>
      denominator == 0 ? 0 : numerator / denominator;

  /// Reduces a fraction to its lowest terms.
  static String simplifyFraction(int numerator, int denominator) {
    if (denominator == 0) return '$numerator / 0';
    final divisor = _gcd(numerator.abs(), denominator.abs());
    if (divisor == 0) return '$numerator / $denominator';
    final sign = denominator < 0 ? -1 : 1;
    return '${sign * numerator ~/ divisor} / ${sign * denominator ~/ divisor}';
  }

  static DateDifferenceResult dateDifference(DateTime from, DateTime to) {
    var start = from;
    var end = to;
    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }
    var years = end.year - start.year;
    var months = end.month - start.month;
    var days = end.day - start.day;

    if (days < 0) {
      months -= 1;
      final previousMonth = DateTime(end.year, end.month, 0);
      days += previousMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    return DateDifferenceResult(
      years: years,
      months: months,
      days: days,
      totalDays: end.difference(start).inDays,
    );
  }

  static int _gcd(int a, int b) {
    var x = a;
    var y = b;
    while (y != 0) {
      final temp = y;
      y = x % y;
      x = temp;
    }
    return x;
  }

  static String _trim(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}
