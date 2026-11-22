import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/features/calculator/domain/calculator_error.dart';
import 'package:vanicalc/features/calculator/domain/expression_engine.dart';

void main() {
  const engine = ExpressionEngine();

  double? value(String expression) => engine.tryEvaluate(expression);

  group('basic arithmetic', () {
    test('addition', () => expect(value('2+3'), 5));
    test('subtraction', () => expect(value('10-4'), 6));
    test('multiplication', () => expect(value('6*7'), 42));
    test('division', () => expect(value('10/4'), 2.5));
    test('decimal numbers', () => expect(value('1.5+2.25'), 3.75));
    test('modulus', () => expect(value('100 mod 7'), 2));
    test('unary minus', () => expect(value('-5+8'), 3));
    test('positive sign', () => expect(value('+5'), 5));
    test('unicode operators', () => expect(value('6 × 7 ÷ 2'), 21));
    test('thousands separators', () => expect(value('1,000+2,500'), 3500));
  });

  group('operator precedence', () {
    test('multiplication before addition', () => expect(value('2+3*4'), 14));
    test('parentheses override precedence', () => expect(value('(2+3)*4'), 20));
    test('nested parentheses', () => expect(value('((1+2)*(3+4))'), 21));
    test('power is right associative', () => expect(value('2^3^2'), 512));
    test('power binds before unary minus', () => expect(value('-2^2'), -4));
    test('negative exponent', () => expect(value('2^-3'), 0.125));
    test('implicit multiplication', () => expect(value('2(3+4)'), 14));
    test('implicit multiplication with pi', () {
      expect(value('2pi'), closeTo(6.283185307, 1e-6));
    });
  });

  group('functions and constants', () {
    test('square root', () => expect(value('sqrt(144)'), 12));
    test('square root symbol', () => expect(value('√144'), 12));
    test('cube root', () => expect(value('cbrt(27)'), closeTo(3, 1e-9)));
    test('absolute value', () => expect(value('abs(-7)'), 7));
    test('log base ten', () => expect(value('log(1000)'), closeTo(3, 1e-9)));
    test('natural log', () => expect(value('ln(e)'), closeTo(1, 1e-9)));
    test('sine of zero', () => expect(value('sin(0)'), 0));
    test('factorial', () => expect(value('5!'), 120));
    test('zero factorial', () => expect(value('0!'), 1));
    test('factorial function alias', () => expect(value('fact(4)'), 24));
    test('pi constant', () => expect(value('pi'), closeTo(3.14159265, 1e-7)));
  });

  group('percentages', () {
    test('standalone percent divides by 100', () {
      expect(value('50%'), 0.5);
    });
    test('percent in multiplication', () {
      expect(value('200*10%'), 20);
    });
    test('percent of a value', () {
      expect(value('15%*200'), 30);
    });
    test('addition of a percentage is relative', () {
      expect(value('200+10%'), 220);
    });
    test('subtraction of a percentage is relative', () {
      expect(value('200-10%'), 180);
    });
  });

  group('error handling', () {
    test('empty expression', () {
      final result = engine.evaluate('');
      expect(result.errorCode, CalcError.empty);
    });

    test('invalid expression', () {
      final result = engine.evaluate('hello');
      expect(result.errorCode, CalcError.invalid);
    });

    test('divide by zero', () {
      final result = engine.evaluate('5/0');
      expect(result.errorCode, CalcError.divideByZero);
    });

    test('modulus by zero', () {
      final result = engine.evaluate('5 mod 0');
      expect(result.errorCode, CalcError.divideByZero);
    });

    test('square root of a negative number', () {
      final result = engine.evaluate('sqrt(-4)');
      expect(result.errorCode, CalcError.domain);
    });

    test('log of zero', () {
      final result = engine.evaluate('log(0)');
      expect(result.errorCode, CalcError.domain);
    });

    test('fractional factorial', () {
      final result = engine.evaluate('2.5!');
      expect(result.errorCode, CalcError.factorial);
    });

    test('negative factorial', () {
      final result = engine.evaluate('(-3)!');
      expect(result.errorCode, CalcError.factorial);
    });

    test('factorial overflow', () {
      final result = engine.evaluate('171!');
      expect(result.errorCode, CalcError.overflow);
    });

    test('power overflow', () {
      final result = engine.evaluate('9^999');
      expect(result.errorCode, CalcError.overflow);
    });

    test('unbalanced brackets', () {
      final result = engine.evaluate('(2+3');
      expect(result.errorCode, CalcError.unbalanced);
    });

    test('trailing operator', () {
      final result = engine.evaluate('2+');
      expect(result.errorCode, CalcError.invalid);
    });

    test('unknown function', () {
      final result = engine.evaluate('foo(2)');
      expect(result.errorCode, CalcError.invalid);
    });
  });

  group('result formatting', () {
    test('floating point noise is removed', () {
      expect(engine.evaluate('0.1+0.2').display, '0.3');
    });

    test('integers have no decimal suffix', () {
      expect(engine.evaluate('8/2').display, '4');
    });

    test('large values use exponential notation', () {
      expect(engine.evaluate('10^20').display, '1e20');
    });

    test('negative zero becomes zero', () {
      expect(engine.evaluate('0*(-1)').display, '0');
    });
  });
}
