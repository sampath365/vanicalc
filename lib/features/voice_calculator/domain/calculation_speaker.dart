import '../../../core/constants/number_system.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/utils/result_formatter.dart';
import '../../number_to_words/domain/number_to_words_engine.dart';

/// Builds natural-language sentences for a calculation so text-to-speech can
/// read numbers in the selected language.
class CalculationSpeaker {
  const CalculationSpeaker({
    this.numberEngine = const NumberToWordsEngine(),
  });

  final NumberToWordsEngine numberEngine;

  /// Words for a single result value.
  String resultWords(
    num value,
    AppLanguage language, {
    NumberSystem system = NumberSystem.indian,
  }) {
    return numberEngine.fromString(
      ResultFormatter.format(value),
      languageCode: language.code,
      system: system,
    );
  }

  /// "twenty five plus thirty five" for `25+35`.
  String expressionWords(
    String expression,
    AppLanguage language, {
    NumberSystem system = NumberSystem.indian,
  }) {
    final vocabulary = _speakVocabulary[language.code] ?? _speakVocabulary['en']!;
    final tokens = RegExp(r'\d+\.?\d*|sqrt|pi|e|mod|[+\-*/^%!()]')
        .allMatches(expression)
        .map((match) => match.group(0)!)
        .toList();
    final parts = <String>[];
    for (final token in tokens) {
      final number = double.tryParse(token);
      if (number != null) {
        parts.add(
          numberEngine.fromString(
            token,
            languageCode: language.code,
            system: system,
          ),
        );
        continue;
      }
      switch (token) {
        case '+':
          parts.add(vocabulary.plus);
        case '-':
          parts.add(vocabulary.minus);
        case '*':
          parts.add(vocabulary.times);
        case '/':
          parts.add(vocabulary.divide);
        case '^':
          parts.add(vocabulary.power);
        case '%':
          parts.add(vocabulary.percent);
        case '!':
          parts.add(vocabulary.factorial);
        case 'sqrt':
          parts.add(vocabulary.squareRoot);
        case 'mod':
          parts.add(vocabulary.modulo);
        case 'pi':
          parts.add(vocabulary.pi);
        case 'e':
          parts.add(vocabulary.e);
        case '(':
          parts.add(vocabulary.openBracket);
        case ')':
          parts.add(vocabulary.closeBracket);
      }
    }
    return parts.where((part) => part.trim().isNotEmpty).join(' ');
  }

  /// Full sentence: expression, "equals", result.
  String calculationSentence(
    String expression,
    num value,
    AppLanguage language, {
    NumberSystem system = NumberSystem.indian,
  }) {
    final vocabulary = _speakVocabulary[language.code] ?? _speakVocabulary['en']!;
    final left = expressionWords(expression, language, system: system);
    final right = resultWords(value, language, system: system);
    return '$left ${vocabulary.equals} $right';
  }

  static const Map<String, _SpeakVocabulary> _speakVocabulary = {
    'en': _SpeakVocabulary(
      plus: 'plus',
      minus: 'minus',
      times: 'times',
      divide: 'divided by',
      power: 'to the power of',
      percent: 'percent',
      factorial: 'factorial',
      equals: 'equals',
      squareRoot: 'square root of',
      openBracket: 'open bracket',
      closeBracket: 'close bracket',
      modulo: 'modulo',
      pi: 'pi',
      e: 'e',
    ),
    'te': _SpeakVocabulary(
      plus: 'ప్లస్',
      minus: 'మైనస్',
      times: 'గుణించి',
      divide: 'భాగించి',
      power: 'ఘాతం',
      percent: 'శాతం',
      factorial: 'ఫ్యాక్టోరియల్',
      equals: 'సమానం',
      squareRoot: 'వర్గమూలం',
      openBracket: 'ఓపెన్ బ్రాకెట్',
      closeBracket: 'క్లోజ్ బ్రాకెట్',
      modulo: 'శేషం',
      pi: 'పై',
      e: 'ఇ',
    ),
    'hi': _SpeakVocabulary(
      plus: 'प्लस',
      minus: 'माइनस',
      times: 'गुणा',
      divide: 'भाग',
      power: 'घात',
      percent: 'प्रतिशत',
      factorial: 'फैक्टोरियल',
      equals: 'बराबर',
      squareRoot: 'वर्गमूल',
      openBracket: 'कोष्ठक खोलें',
      closeBracket: 'कोष्ठक बंद करें',
      modulo: 'शेष',
      pi: 'पाई',
      e: 'ई',
    ),
    'ta': _SpeakVocabulary(
      plus: 'கூட்டல்',
      minus: 'கழித்தல்',
      times: 'பெருக்கல்',
      divide: 'வகுத்தல்',
      power: 'அடுக்கு',
      percent: 'சதவீதம்',
      factorial: 'பாக்டோரியல்',
      equals: 'சமம்',
      squareRoot: 'வர்க்கமூலம்',
      openBracket: 'திறந்த அடைப்பு',
      closeBracket: 'மூடிய அடைப்பு',
      modulo: 'மீதம்',
      pi: 'பை',
      e: 'இ',
    ),
    'kn': _SpeakVocabulary(
      plus: 'ಪ್ಲಸ್',
      minus: 'ಮೈನಸ್',
      times: 'ಗುಣಿಸು',
      divide: 'ಭಾಗಿಸು',
      power: 'ಘಾತ',
      percent: 'ಶೇಕಡಾ',
      factorial: 'ಫ್ಯಾಕ್ಟೋರಿಯಲ್',
      equals: 'ಸಮ',
      squareRoot: 'ವರ್ಗಮೂಲ',
      openBracket: 'ಆವರಣ ತೆರೆಯಿರಿ',
      closeBracket: 'ಆವರಣ ಮುಚ್ಚಿ',
      modulo: 'ಶೇಷ',
      pi: 'ಪೈ',
      e: 'ಇ',
    ),
    'ml': _SpeakVocabulary(
      plus: 'പ്ലസ്',
      minus: 'മൈനസ്',
      times: 'ഗുണം',
      divide: 'ഹരണം',
      power: 'പവർ',
      percent: 'ശതമാനം',
      factorial: 'ഫാക്ടോറിയൽ',
      equals: 'തുല്യം',
      squareRoot: 'വർഗ്ഗമൂലം',
      openBracket: 'ബ്രാക്കറ്റ് തുറക്കുക',
      closeBracket: 'ബ്രാക്കറ്റ് അടയ്ക്കുക',
      modulo: 'ശിഷ്ടം',
      pi: 'പൈ',
      e: 'ഇ',
    ),
    'mr': _SpeakVocabulary(
      plus: 'प्लस',
      minus: 'वजा',
      times: 'गुणाकार',
      divide: 'भागाकार',
      power: 'घात',
      percent: 'टक्के',
      factorial: 'फॅक्टोरियल',
      equals: 'बरोबर',
      squareRoot: 'वर्गमूळ',
      openBracket: 'कंस उघडा',
      closeBracket: 'कंस बंद',
      modulo: 'बाकी',
      pi: 'पाय',
      e: 'ई',
    ),
    'bn': _SpeakVocabulary(
      plus: 'যোগ',
      minus: 'বিয়োগ',
      times: 'গুণ',
      divide: 'ভাগ',
      power: 'ঘাত',
      percent: 'শতাংশ',
      factorial: 'ফ্যাক্টোরিয়াল',
      equals: 'সমান',
      squareRoot: 'বর্গমূল',
      openBracket: 'বন্ধনী খুলুন',
      closeBracket: 'বন্ধনী বন্ধ',
      modulo: 'ভাগশেষ',
      pi: 'পাই',
      e: 'ই',
    ),
    'gu': _SpeakVocabulary(
      plus: 'વત્તા',
      minus: 'બાદ',
      times: 'ગુણાકાર',
      divide: 'ભાગાકાર',
      power: 'ઘાત',
      percent: 'ટકા',
      factorial: 'ફેક્ટોરિયલ',
      equals: 'બરાબર',
      squareRoot: 'વર્ગમૂળ',
      openBracket: 'કૌંસ ખોલો',
      closeBracket: 'કૌંસ બંધ',
      modulo: 'બાકી',
      pi: 'પાઈ',
      e: 'ઇ',
    ),
    'pa': _SpeakVocabulary(
      plus: 'ਜੋੜ',
      minus: 'ਘਟਾਓ',
      times: 'ਗੁਣਾ',
      divide: 'ਭਾਗ',
      power: 'ਘਾਤ',
      percent: 'ਪ੍ਰਤੀਸ਼ਤ',
      factorial: 'ਫੈਕਟੋਰੀਅਲ',
      equals: 'ਬਰਾਬਰ',
      squareRoot: 'ਵਰਗਮੂਲ',
      openBracket: 'ਬਰੈਕਟ ਖੋਲ੍ਹੋ',
      closeBracket: 'ਬਰੈਕਟ ਬੰਦ',
      modulo: 'ਬਾਕੀ',
      pi: 'ਪਾਈ',
      e: 'ਈ',
    ),
  };
}

class _SpeakVocabulary {
  const _SpeakVocabulary({
    required this.plus,
    required this.minus,
    required this.times,
    required this.divide,
    required this.power,
    required this.percent,
    required this.factorial,
    required this.equals,
    required this.squareRoot,
    required this.openBracket,
    required this.closeBracket,
    required this.modulo,
    required this.pi,
    required this.e,
  });

  final String plus;
  final String minus;
  final String times;
  final String divide;
  final String power;
  final String percent;
  final String factorial;
  final String equals;
  final String squareRoot;
  final String openBracket;
  final String closeBracket;
  final String modulo;
  final String pi;
  final String e;
}
