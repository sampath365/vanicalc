import '../../../core/constants/number_system.dart';
import 'languages/bengali_words.dart';
import 'languages/english_words.dart';
import 'languages/gujarati_words.dart';
import 'languages/hindi_words.dart';
import 'languages/kannada_words.dart';
import 'languages/malayalam_words.dart';
import 'languages/marathi_words.dart';
import 'languages/punjabi_words.dart';
import 'languages/tamil_words.dart';
import 'languages/telugu_words.dart';
import 'number_words_language.dart';

/// Registry of all locally supported number-to-words languages.
class NumberToWordsEngine {
  const NumberToWordsEngine();

  static const Map<String, NumberWordsLanguage> _languages = {
    'en': EnglishNumberWords(),
    'te': TeluguNumberWords(),
    'hi': HindiNumberWords(),
    'ta': TamilNumberWords(),
    'kn': KannadaNumberWords(),
    'ml': MalayalamNumberWords(),
    'mr': MarathiNumberWords(),
    'bn': BengaliNumberWords(),
    'gu': GujaratiNumberWords(),
    'pa': PunjabiNumberWords(),
  };

  static List<String> get supportedCodes =>
      _languages.keys.toList(growable: false);

  static List<NumberWordsLanguage> get all =>
      _languages.values.toList(growable: false);

  NumberWordsLanguage languageFor(String code) {
    return _languages[code] ?? _languages['en']!;
  }

  String convert(
    num value, {
    required String languageCode,
    NumberSystem system = NumberSystem.indian,
    bool currency = false,
  }) {
    return languageFor(languageCode)
        .convert(value, system: system, currency: currency);
  }

  String fromString(
    String raw, {
    required String languageCode,
    NumberSystem system = NumberSystem.indian,
    bool currency = false,
  }) {
    return languageFor(languageCode)
        .fromString(raw, system: system, currency: currency);
  }
}

/// Reverse lookup of number words, used by the speech parser to turn spoken
/// words into numeric values without any network call.
class NumberWordDictionary {
  NumberWordDictionary(this.language);

  final NumberWordsLanguage language;

  static final Map<String, NumberWordDictionary> _cache = {};

  factory NumberWordDictionary.forLanguage(NumberWordsLanguage language) {
    return _cache.putIfAbsent(
      language.code,
      () => NumberWordDictionary(language),
    );
  }

  late final Map<String, int> values = _build();

  Map<String, int> _build() {
    final map = <String, int>{};
    for (var i = 0; i < language.words0To99.length; i++) {
      map[_normalize(language.words0To99[i])] = i;
    }
    map[_normalize(language.hundredWord)] = 100;
    map[_normalize(language.thousandWord)] = 1000;
    map[_normalize(language.lakhWord)] = 100000;
    map[_normalize(language.croreWord)] = 10000000;
    map[_normalize(language.millionWord)] = 1000000;
    map[_normalize(language.billionWord)] = 1000000000;
    map[_normalize(language.trillionWord)] = 1000000000000;
    language.extraWordValues.forEach((word, value) {
      map[_normalize(word)] = value;
    });
    return map;
  }

  /// Longest word first, so greedy matching prefers "ninety" over "nine".
  late final List<String> keysByLength = values.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  bool get isEmpty => values.isEmpty;

  int? valueOf(String word) => values[_normalize(word)];

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-_,.]'), '')
        .replaceAll('\u200d', '');
  }

  static bool isScale(int value) => const {
    100,
    1000,
    100000,
    1000000,
    10000000,
    1000000000,
    1000000000000,
  }.contains(value);

  /// Parses a sequence of number words into a single integer.
  ///
  /// Returns `null` when no word was recognised. Unknown words are ignored so
  /// that filler such as "what is" does not break the conversion.
  int? parseWords(List<String> words) {
    var total = 0;
    var current = 0;
    var matched = false;
    for (final rawWord in words) {
      final value = values[_normalize(rawWord)];
      if (value == null) continue;
      matched = true;
      if (value < 100) {
        current += value;
      } else if (value == 100) {
        current = (current == 0 ? 1 : current) * 100;
      } else {
        total += (current == 0 ? 1 : current) * value;
        current = 0;
      }
    }
    if (!matched) return null;
    return total + current;
  }
}
