import '../number_words_language.dart';

/// Malayalam (മലയാളം) number words.
class MalayalamNumberWords extends NumberWordsLanguage {
  const MalayalamNumberWords();

  @override
  String get code => 'ml';

  static const List<String> _belowTwenty = <String>[
    'പൂജ്യം',
    'ഒന്ന്',
    'രണ്ട്',
    'മൂന്ന്',
    'നാല്',
    'അഞ്ച്',
    'ആറ്',
    'ഏഴ്',
    'എട്ട്',
    'ഒമ്പത്',
    'പത്ത്',
    'പതിനൊന്ന്',
    'പന്ത്രണ്ട്',
    'പതിമൂന്ന്',
    'പതിനാല്',
    'പതിനഞ്ച്',
    'പതിനാറ്',
    'പതിനേഴ്',
    'പതിനെട്ട്',
    'പത്തൊമ്പത്',
  ];

  static const List<String> _tensWords = <String>[
    '',
    '',
    'ഇരുപത്',
    'മുപ്പത്',
    'നാൽപ്പത്',
    'അമ്പത്',
    'അറുപത്',
    'എഴുപത്',
    'എൺപത്',
    'തൊണ്ണൂറ്',
  ];

  static const List<String> _tensStems = <String>[
    '',
    '',
    'ഇരുപത്തി',
    'മുപ്പത്തി',
    'നാൽപ്പത്തി',
    'അമ്പത്തി',
    'അറുപത്തി',
    'എഴുപത്തി',
    'എൺപത്തി',
    'തൊണ്ണൂറ്റി',
  ];

  static const Map<String, String> _vowels = <String, String>{
    'അ': '',
    'ആ': 'ാ',
    'ഇ': 'ി',
    'ഈ': 'ീ',
    'ഉ': 'ു',
    'ഊ': 'ൂ',
    'എ': 'െ',
    'ഏ': 'േ',
    'ഐ': 'ൈ',
    'ഒ': 'ൊ',
    'ഓ': 'ോ',
    'ഔ': 'ൗ',
  };

  static final List<String> _words = _build();

  static List<String> _build() {
    final words = <String>[..._belowTwenty];
    const joiner = VowelJoiner(_vowels);
    for (var tens = 2; tens <= 9; tens++) {
      for (var unit = 0; unit <= 9; unit++) {
        if (unit == 0) {
          words.add(_tensWords[tens]);
          continue;
        }
        final unitWord = _belowTwenty[unit];
        final sign = joiner.leadingVowelSign(unitWord);
        words.add(
          sign == null
              ? '${_tensStems[tens]}$unitWord'
              : '${_tensStems[tens]}യ${joiner.applySign(unitWord, sign)}',
        );
      }
    }
    return List<String>.unmodifiable(words);
  }

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'പോയിന്റ്';
  @override
  String get minusWord => 'മൈനസ്';
  @override
  String get hundredWord => 'നൂറ്';
  @override
  String get thousandWord => 'ആയിരം';
  @override
  String get lakhWord => 'ലക്ഷം';
  @override
  String get croreWord => 'കോടി';
  @override
  String get millionWord => 'മില്യൺ';
  @override
  String get billionWord => 'ബില്യൺ';
  @override
  String get trillionWord => 'ട്രില്യൺ';

  @override
  String get currencyUnitSingular => 'രൂപ';
  @override
  String get currencyUnitPlural => 'രൂപ';
  @override
  String get currencySubunitSingular => 'പൈസ';
  @override
  String get currencySubunitPlural => 'പൈസ';
  @override
  String get currencyOnlyWord => 'മാത്രം';
  @override
  bool get pluralizesCurrency => false;

  static const List<String> _hundreds = <String>[
    '',
    'നൂറ്',
    'ഇരുനൂറ്',
    'മുന്നൂറ്',
    'നാനൂറ്',
    'അഞ്ഞൂറ്',
    'അറുനൂറ്',
    'എഴുനൂറ്',
    'എണ്ണൂറ്',
    'തൊള്ളായിരം',
  ];

  static const List<String> _hundredsCombining = <String>[
    '',
    'നൂറ്റി',
    'ഇരുനൂറ്റി',
    'മുന്നൂറ്റി',
    'നാനൂറ്റി',
    'അഞ്ഞൂറ്റി',
    'അറുനൂറ്റി',
    'എഴുനൂറ്റി',
    'എണ്ണൂറ്റി',
    'തൊള്ളായിരത്തി',
  ];

  @override
  Map<String, int> get extraWordValues => const {'നൂറ്റി': 100};

  @override
  String hundredFormFor(int hundreds, int remainder) {
    return remainder == 0 ? _hundreds[hundreds] : _hundredsCombining[hundreds];
  }

  @override
  String scaleFormForCount(
    int count,
    String countWords,
    String scaleWord,
    bool hasRemainder,
  ) {
    if (count == 1) return scaleWord;
    return '$countWords $scaleWord';
  }
}
