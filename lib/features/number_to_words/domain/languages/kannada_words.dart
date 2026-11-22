import '../number_words_language.dart';

/// Kannada (ಕನ್ನಡ) number words.
class KannadaNumberWords extends NumberWordsLanguage {
  const KannadaNumberWords();

  @override
  String get code => 'kn';

  static const List<String> _belowTwenty = <String>[
    'ಶೂನ್ಯ',
    'ಒಂದು',
    'ಎರಡು',
    'ಮೂರು',
    'ನಾಲ್ಕು',
    'ಐದು',
    'ಆರು',
    'ಏಳು',
    'ಎಂಟು',
    'ಒಂಬತ್ತು',
    'ಹತ್ತು',
    'ಹನ್ನೊಂದು',
    'ಹನ್ನೆರಡು',
    'ಹದಿಮೂರು',
    'ಹದಿನಾಲ್ಕು',
    'ಹದಿನೈದು',
    'ಹದಿನಾರು',
    'ಹದಿನೇಳು',
    'ಹದಿನೆಂಟು',
    'ಹತ್ತೊಂಬತ್ತು',
  ];

  static const List<String> _tensWords = <String>[
    '',
    '',
    'ಇಪ್ಪತ್ತು',
    'ಮೂವತ್ತು',
    'ನಲವತ್ತು',
    'ಐವತ್ತು',
    'ಅರವತ್ತು',
    'ಎಪ್ಪತ್ತು',
    'ಎಂಬತ್ತು',
    'ತೊಂಬತ್ತು',
  ];

  static const Map<String, String> _vowels = <String, String>{
    'ಅ': '',
    'ಆ': 'ಾ',
    'ಇ': 'ಿ',
    'ಈ': 'ೀ',
    'ಉ': 'ು',
    'ಊ': 'ೂ',
    'ಋ': 'ೃ',
    'ಎ': 'ೆ',
    'ಏ': 'ೇ',
    'ಐ': 'ೈ',
    'ಒ': 'ೊ',
    'ಓ': 'ೋ',
    'ಔ': 'ೌ',
  };

  static final List<String> _words = _build();

  static List<String> _build() {
    final words = <String>[..._belowTwenty];
    const joiner = VowelJoiner(_vowels);
    for (var tens = 2; tens <= 9; tens++) {
      final stem = _tensWords[tens].substring(0, _tensWords[tens].length - 1);
      for (var unit = 0; unit <= 9; unit++) {
        if (unit == 0) {
          words.add(_tensWords[tens]);
          continue;
        }
        final unitWord = _belowTwenty[unit];
        final sign = joiner.leadingVowelSign(unitWord);
        words.add(
          sign == null
              ? '$stem$unitWord'
              : '$stem${joiner.applySign(unitWord, sign)}',
        );
      }
    }
    return List<String>.unmodifiable(words);
  }

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'ಪಾಯಿಂಟ್';
  @override
  String get minusWord => 'ಮೈನಸ್';
  @override
  String get hundredWord => 'ನೂರು';
  @override
  String get thousandWord => 'ಸಾವಿರ';
  @override
  String get lakhWord => 'ಲಕ್ಷ';
  @override
  String get croreWord => 'ಕೋಟಿ';
  @override
  String get millionWord => 'ಮಿಲಿಯನ್';
  @override
  String get billionWord => 'ಬಿಲಿಯನ್';
  @override
  String get trillionWord => 'ಟ್ರಿಲಿಯನ್';

  @override
  String get currencyUnitSingular => 'ರೂಪಾಯಿ';
  @override
  String get currencyUnitPlural => 'ರೂಪಾಯಿ';
  @override
  String get currencySubunitSingular => 'ಪೈಸೆ';
  @override
  String get currencySubunitPlural => 'ಪೈಸೆ';
  @override
  String get currencyOnlyWord => 'ಮಾತ್ರ';
  @override
  bool get pluralizesCurrency => false;

  static const List<String> _hundreds = <String>[
    '',
    'ನೂರು',
    'ಇನ್ನೂರು',
    'ಮುನ್ನೂರು',
    'ನಾನೂರು',
    'ಐನೂರು',
    'ಆರುನೂರು',
    'ಏಳುನೂರು',
    'ಎಂಟುನೂರು',
    'ಒಂಬೈನೂರು',
  ];

  @override
  Map<String, int> get extraWordValues => const {'ನೂರ': 100};

  @override
  String hundredFormFor(int hundreds, int remainder) {
    final word = _hundreds[hundreds];
    if (remainder == 0) return word;
    return word.substring(0, word.length - 1);
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
