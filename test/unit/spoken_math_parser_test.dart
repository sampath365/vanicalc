import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/core/localization/app_language.dart';
import 'package:vanicalc/features/calculator/domain/expression_engine.dart';
import 'package:vanicalc/features/voice_calculator/domain/spoken_math_parser.dart';

void main() {
  const parser = SpokenMathParser();
  const engine = ExpressionEngine();

  SpokenParseResult parse(
    String text, {
    AppLanguage language = AppLanguage.english,
  }) => parser.parse(text, language);

  double? value(String text, {AppLanguage language = AppLanguage.english}) {
    final result = parse(text, language: language);
    return result.expression.isEmpty
        ? null
        : engine.tryEvaluate(result.expression);
  }

  group('English phrases', () {
    test('what is 25 plus 35', () {
      final result = parse('What is 25 plus 35?');
      expect(result.expression, '25+35');
      expect(engine.tryEvaluate(result.expression), 60);
      expect(result.ambiguous, isFalse);
      expect(result.isCalculation, isTrue);
    });

    test('calculate 500 minus 150', () {
      expect(value('Calculate 500 minus 150.'), 350);
    });

    test('multiply 25 by 10', () {
      final result = parse('Multiply 25 by 10.');
      expect(result.expression, '25*10');
      expect(engine.tryEvaluate(result.expression), 250);
    });

    test('divide 1000 by 5', () {
      final result = parse('Divide 1000 by 5.');
      expect(result.expression, '1000/5');
      expect(engine.tryEvaluate(result.expression), 200);
    });

    test('15 percent of 200', () {
      expect(value('What is 15 percent of 200?'), 30);
    });

    test('add 500, 200 and 300', () {
      final result = parse('Add 500, 200 and 300.');
      expect(result.expression, '500+200+300');
      expect(engine.tryEvaluate(result.expression), 1000);
    });

    test('square root of 144', () {
      final result = parse('What is the square root of 144?');
      expect(result.expression, 'sqrt(144)');
      expect(engine.tryEvaluate(result.expression), 12);
    });

    test('25 multiplied by 4 and add 100', () {
      final result = parse('Calculate 25 multiplied by 4 and add 100.');
      expect(engine.tryEvaluate(result.expression), 200);
    });

    test('spoken decimals', () {
      expect(value('twelve point five plus two'), 14.5);
    });

    test('spoken hundreds and thousands', () {
      expect(value('two hundred seventy five plus twenty five'), 300);
    });

    test('spoken lakh and crore', () {
      expect(
        value(
          'sixteen lakh thirty four thousand three hundred ninety one plus nine',
        ),
        1634400,
      );
    });

    test('subtract from reverses the operands', () {
      expect(value('subtract 150 from 500'), 350);
    });

    test('percentage sign in speech', () {
      expect(value('fifteen percent of two hundred'), 30);
    });

    test('confidence is high for a full phrase', () {
      expect(parse('what is 25 plus 35').confidence, greaterThan(0.9));
    });
  });

  group('Indian language phrases', () {
    test('Hindi', () {
      final result = parse('पच्चीस प्लस पैंतीस', language: AppLanguage.hindi);
      expect(result.expression, '25+35');
      expect(engine.tryEvaluate(result.expression), 60);
    });

    test('Telugu', () {
      final result = parse(
        'ఇరవై ఐదు ప్లస్ ముప్పై ఐదు',
        language: AppLanguage.telugu,
      );
      expect(result.expression, '25+35');
      expect(engine.tryEvaluate(result.expression), 60);
    });

    test('Tamil', () {
      final result = parse(
        'இருபத்தைந்து கூட்டல் முப்பத்தைந்து',
        language: AppLanguage.tamil,
      );
      expect(engine.tryEvaluate(result.expression), 60);
    });

    test('Kannada', () {
      final result = parse(
        'ಇಪ್ಪತ್ತೈದು ಪ್ಲಸ್ ಮೂವತ್ತೈದು',
        language: AppLanguage.kannada,
      );
      expect(engine.tryEvaluate(result.expression), 60);
    });

    test('Malayalam', () {
      final result = parse(
        'ഇരുപത്തിയഞ്ച് പ്ലസ് മുപ്പത്തിയഞ്ച്',
        language: AppLanguage.malayalam,
      );
      expect(engine.tryEvaluate(result.expression), 60);
    });

    test('English digits work with an Indian language selected', () {
      expect(value('25 plus 35', language: AppLanguage.telugu), 60);
    });
  });

  group('voice commands', () {
    test('clear calculator', () {
      final result = parse('clear calculator');
      expect(result.isCommand, isTrue);
      expect(result.command!.type, VoiceCommandType.clear);
    });

    test('delete last number', () {
      expect(
        parse('delete last number').command!.type,
        VoiceCommandType.deleteLast,
      );
    });

    test('repeat answer', () {
      expect(
        parse('repeat answer').command!.type,
        VoiceCommandType.repeatAnswer,
      );
    });

    test('show history', () {
      expect(parse('show history').command!.type, VoiceCommandType.showHistory);
    });

    test('switch to scientific calculator', () {
      expect(
        parse('switch to scientific calculator').command!.type,
        VoiceCommandType.openScientific,
      );
    });

    test('change language to Telugu', () {
      final result = parse('change language to Telugu');
      expect(result.command!.type, VoiceCommandType.setLanguage);
      expect(result.command!.language, AppLanguage.telugu);
    });

    test('read result in Hindi', () {
      final result = parse('read result in Hindi');
      expect(result.command!.type, VoiceCommandType.speakInLanguage);
      expect(result.command!.language, AppLanguage.hindi);
    });
  });

  group('edge cases', () {
    test('lone number is ambiguous but valid', () {
      final result = parse('25');
      expect(result.expression, '25');
      expect(result.ambiguous, isTrue);
      expect(result.errorCode, isNull);
    });

    test('unrecognised speech is rejected', () {
      final result = parse('hello world');
      expect(result.expression, isEmpty);
      expect(result.errorCode, isNotNull);
      expect(result.ambiguous, isTrue);
    });

    test('empty input is rejected', () {
      final result = parse('   ');
      expect(result.expression, isEmpty);
    });

    test('divide by zero is surfaced', () {
      final result = parse('25 divided by 0');
      expect(result.expression, '25/0');
      expect(result.errorCode, 'error_divide_by_zero');
      expect(result.isCalculation, isFalse);
    });
  });
}
