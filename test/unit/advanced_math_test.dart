import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/features/tools/domain/advanced_math.dart';

void main() {
  group('quadratic', () {
    test('real roots', () {
      final result = AdvancedMath.solveQuadratic(1, -3, 2)!;
      expect(result.hasComplexRoots, isFalse);
      expect(result.discriminant, 1);
      expect(result.root1, closeTo(2, 1e-9));
      expect(result.root2, closeTo(1, 1e-9));
    });

    test('double root', () {
      final result = AdvancedMath.solveQuadratic(1, -2, 1)!;
      expect(result.root1, closeTo(1, 1e-9));
      expect(result.root2, closeTo(1, 1e-9));
    });

    test('complex roots', () {
      final result = AdvancedMath.solveQuadratic(1, 0, 1)!;
      expect(result.hasComplexRoots, isTrue);
      expect(result.realPart, closeTo(0, 1e-9));
      expect(result.imaginaryPart, closeTo(1, 1e-9));
    });

    test('a = 0 is rejected', () {
      expect(AdvancedMath.solveQuadratic(0, 2, 1), isNull);
    });
  });

  group('statistics', () {
    test('mean, median and spread', () {
      final result = AdvancedMath.statistics([10, 20, 30, 40, 50])!;
      expect(result.count, 5);
      expect(result.sum, 150);
      expect(result.mean, 30);
      expect(result.median, 30);
      expect(result.min, 10);
      expect(result.max, 50);
      expect(result.standardDeviation, closeTo(15.811388, 1e-5));
      expect(result.mode, isNull);
    });

    test('even count median and mode', () {
      final result = AdvancedMath.statistics([2, 2, 4, 6])!;
      expect(result.median, 3);
      expect(result.mode, 2);
    });

    test('empty input', () {
      expect(AdvancedMath.statistics(const []), isNull);
    });

    test('parse numbers with separators', () {
      expect(AdvancedMath.parseNumbers('10, 20;30 40\n50'), [
        10,
        20,
        30,
        40,
        50,
      ]);
    });
  });

  group('base conversion', () {
    test('binary to all bases', () {
      final result = AdvancedMath.convertBase('1010', 2)!;
      expect(result.decimal, 10);
      expect(result.binary, '1010');
      expect(result.octal, '12');
      expect(result.hexadecimal, 'A');
    });

    test('hexadecimal input', () {
      final result = AdvancedMath.convertBase('FF', 16)!;
      expect(result.decimal, 255);
      expect(result.binary, '11111111');
    });

    test('invalid digits', () {
      expect(AdvancedMath.convertBase('102', 2), isNull);
      expect(AdvancedMath.convertBase('', 10), isNull);
    });
  });

  group('number theory', () {
    test('gcd and lcm', () {
      expect(AdvancedMath.gcd(48, 18), 6);
      expect(AdvancedMath.lcm(4, 6), 12);
      expect(AdvancedMath.lcm(0, 6), 0);
    });

    test('permutations and combinations', () {
      expect(AdvancedMath.permutations(5, 2), 20);
      expect(AdvancedMath.combinations(5, 2), 10);
      expect(AdvancedMath.combinations(5, 6), 0);
    });

    test('prime checks and factors', () {
      expect(AdvancedMath.isPrime(97), isTrue);
      expect(AdvancedMath.isPrime(1), isFalse);
      expect(AdvancedMath.isPrime(100), isFalse);
      expect(AdvancedMath.primeFactors(360), [2, 2, 2, 3, 3, 5]);
      expect(AdvancedMath.primeFactors(1), isEmpty);
    });
  });
}
