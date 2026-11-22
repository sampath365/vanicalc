import 'package:flutter_test/flutter_test.dart';
import 'package:vanicalc/core/constants/number_system.dart';
import 'package:vanicalc/features/number_to_words/domain/number_to_words_engine.dart';

void main() {
  const engine = NumberToWordsEngine();

  String indian(num value, {String language = 'en'}) => engine.convert(
        value,
        languageCode: language,
        system: NumberSystem.indian,
      );

  String international(num value, {String language = 'en'}) => engine.convert(
        value,
        languageCode: language,
        system: NumberSystem.international,
      );

  String currency(num value, {String language = 'en'}) => engine.convert(
        value,
        languageCode: language,
        system: NumberSystem.indian,
        currency: true,
      );

  group('English Indian numbering', () {
    test('100', () => expect(indian(100), 'One Hundred'));
    test('1,000', () => expect(indian(1000), 'One Thousand'));
    test('10,000', () => expect(indian(10000), 'Ten Thousand'));
    test('1,00,000', () => expect(indian(100000), 'One Lakh'));
    test('10,00,000', () => expect(indian(1000000), 'Ten Lakh'));
    test('1,00,00,000', () => expect(indian(10000000), 'One Crore'));
    test('16,34,391', () {
      expect(
        indian(1634391),
        'Sixteen Lakh Thirty-Four Thousand Three Hundred Ninety-One',
      );
    });
    test('zero', () => expect(indian(0), 'Zero'));
    test('hyphenated tens', () => expect(indian(45), 'Forty-Five'));
  });

  group('English international numbering', () {
    test('one million', () {
      expect(international(1000000), 'One Million');
    });
    test('one billion', () {
      expect(international(1000000000), 'One Billion');
    });
    test('11800', () {
      expect(international(11800), 'Eleven Thousand Eight Hundred');
    });
    test('hundred thousand', () {
      expect(international(100000), 'One Hundred Thousand');
    });
  });

  group('decimals and negatives', () {
    test('decimal', () {
      expect(engine.fromString('12.5', languageCode: 'en'), 'Twelve Point Five');
    });
    test('decimal with trailing zero', () {
      expect(engine.fromString('12.50', languageCode: 'en'), 'Twelve Point Five');
    });
    test('negative', () {
      expect(engine.fromString('-5', languageCode: 'en'), 'Minus Five');
    });
    test('negative decimal', () {
      expect(
        engine.fromString('-1.25', languageCode: 'en'),
        'Minus One Point Two Five',
      );
    });
    test('invalid input returns empty', () {
      expect(engine.fromString('abc', languageCode: 'en'), '');
    });
  });

  group('currency', () {
    test('rupees only', () {
      expect(
        currency(11800),
        'Eleven Thousand Eight Hundred Rupees Only',
      );
    });
    test('single rupee is singular', () {
      expect(currency(1), 'One Rupee Only');
    });
    test('paise are included', () {
      expect(currency(1234.56), contains('Paise'));
    });
    test('single decimal digit means tens of paise', () {
      expect(currency(12.5), contains('Fifty Paise'));
    });

    test('telugu currency', () {
      expect(currency(10000, language: 'te'), contains('రూపాయలు'));
    });
  });

  group('Telugu', () {
    test('60 is అరవై', () => expect(indian(60, language: 'te'), 'అరవై'));
    test('25', () => expect(indian(25, language: 'te'), 'ఇరవై ఐదు'));
    test('125 uses నూట', () => expect(indian(125, language: 'te'), 'నూట ఇరవై ఐదు'));
    test('200 uses plural hundreds', () {
      expect(indian(200, language: 'te'), 'రెండు వందలు');
    });
    test('lakh', () => expect(indian(100000, language: 'te'), 'లక్ష'));
    test('lakhs with remainder', () {
      expect(indian(1634391, language: 'te'), contains('లక్షల'));
    });
  });

  group('Hindi', () {
    test('60 is साठ', () => expect(indian(60, language: 'hi'), 'साठ'));
    test('25', () => expect(indian(25, language: 'hi'), 'पच्चीस'));
    test('100', () => expect(indian(100, language: 'hi'), 'एक सौ'));
    test('11800', () => expect(indian(11800, language: 'hi'), contains('ग्यारह')));
  });

  group('Tamil', () {
    test('60 is அறுபது', () => expect(indian(60, language: 'ta'), 'அறுபது'));
    test('25', () => expect(indian(25, language: 'ta'), 'இருபத்தைந்து'));
    test('125', () => expect(indian(125, language: 'ta'), 'நூற்று இருபத்தைந்து'));
    test('1000', () => expect(indian(1000, language: 'ta'), 'ஆயிரம்'));
  });

  group('Kannada', () {
    test('60 is ಅರವತ್ತು', () => expect(indian(60, language: 'kn'), 'ಅರವತ್ತು'));
    test('25', () => expect(indian(25, language: 'kn'), 'ಇಪ್ಪತ್ತೈದು'));
    test('125', () => expect(indian(125, language: 'kn'), 'ನೂರ ಇಪ್ಪತ್ತೈದು'));
  });

  group('Malayalam', () {
    test('60', () => expect(indian(60, language: 'ml'), 'അറുപത്'));
    test('25', () => expect(indian(25, language: 'ml'), 'ഇരുപത്തിയഞ്ച്'));
    test('100', () => expect(indian(100, language: 'ml'), 'നൂറ്'));
  });

  group('other languages', () {
    test('Marathi 60', () => expect(indian(60, language: 'mr'), 'साठ'));
    test('Bengali 60', () => expect(indian(60, language: 'bn'), 'ষাট'));
    test('Gujarati 60', () => expect(indian(60, language: 'gu'), 'સાઠ'));
    test('Punjabi 60', () => expect(indian(60, language: 'pa'), 'ਸੱਠ'));
  });

  group('language tables', () {
    test('all supported languages expose 100 unique words', () {
      for (final language in NumberToWordsEngine.all) {
        expect(
          language.words0To99.length,
          100,
          reason: '${language.code} must have 100 number words',
        );
        expect(
          language.words0To99.toSet().length,
          100,
          reason: '${language.code} words must be unique',
        );
      }
    });

    test('unknown language falls back to English', () {
      expect(engine.convert(5, languageCode: 'xx'), 'Five');
    });
  });
}
