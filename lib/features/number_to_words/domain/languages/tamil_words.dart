import '../number_words_language.dart';

/// Tamil (தமிழ்) number words.
class TamilNumberWords extends NumberWordsLanguage {
  const TamilNumberWords();

  @override
  String get code => 'ta';

  static const List<String> _belowTwenty = <String>[
    'பூஜ்ஜியம்',
    'ஒன்று',
    'இரண்டு',
    'மூன்று',
    'நான்கு',
    'ஐந்து',
    'ஆறு',
    'ஏழு',
    'எட்டு',
    'ஒன்பது',
    'பத்து',
    'பதினொன்று',
    'பன்னிரண்டு',
    'பதிமூன்று',
    'பதிநான்கு',
    'பதினைந்து',
    'பதினாறு',
    'பதினேழு',
    'பதினெட்டு',
    'பத்தொன்பது',
  ];

  static const List<String> _tensWords = <String>[
    '',
    '',
    'இருபது',
    'முப்பது',
    'நாற்பது',
    'ஐம்பது',
    'அறுபது',
    'எழுபது',
    'எண்பது',
    'தொண்ணூறு',
  ];

  static const List<String> _tensStems = <String>[
    '',
    '',
    'இருபத்து',
    'முப்பத்து',
    'நாற்பத்து',
    'ஐம்பத்து',
    'அறுபத்து',
    'எழுபத்து',
    'எண்பத்து',
    'தொண்ணூற்று',
  ];

  static const Map<String, String> _vowels = <String, String>{
    'அ': '',
    'ஆ': 'ா',
    'இ': 'ி',
    'ஈ': 'ீ',
    'உ': 'ு',
    'ஊ': 'ூ',
    'எ': 'ெ',
    'ஏ': 'ே',
    'ஐ': 'ை',
    'ஒ': 'ொ',
    'ஓ': 'ோ',
    'ஔ': 'ௌ',
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
              ? '${_tensStems[tens]} $unitWord'
              : '${_tensStems[tens].substring(0, _tensStems[tens].length - 1)}'
                    '${joiner.applySign(unitWord, sign)}',
        );
      }
    }
    return List<String>.unmodifiable(words);
  }

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'புள்ளி';
  @override
  String get minusWord => 'மைனஸ்';
  @override
  String get hundredWord => 'நூறு';
  @override
  String get thousandWord => 'ஆயிரம்';
  @override
  String get lakhWord => 'லட்சம்';
  @override
  String get croreWord => 'கோடி';
  @override
  String get millionWord => 'மில்லியன்';
  @override
  String get billionWord => 'பில்லியன்';
  @override
  String get trillionWord => 'டிரில்லியன்';

  @override
  String get currencyUnitSingular => 'ரூபாய்';
  @override
  String get currencyUnitPlural => 'ரூபாய்';
  @override
  String get currencySubunitSingular => 'பைசா';
  @override
  String get currencySubunitPlural => 'பைசா';
  @override
  String get currencyOnlyWord => 'மட்டும்';
  @override
  bool get pluralizesCurrency => false;

  static const List<String> _hundreds = <String>[
    '',
    'நூறு',
    'இருநூறு',
    'முந்நூறு',
    'நானூறு',
    'ஐந்நூறு',
    'அறுநூறு',
    'எழுநூறு',
    'எண்ணூறு',
    'தொள்ளாயிரம்',
  ];

  static const List<String> _hundredsCombining = <String>[
    '',
    'நூற்று',
    'இருநூற்று',
    'முந்நூற்று',
    'நானூற்று',
    'ஐந்நூற்று',
    'அறுநூற்று',
    'எழுநூற்று',
    'எண்ணூற்று',
    'தொள்ளாயிரத்து',
  ];

  @override
  Map<String, int> get extraWordValues => const {'நூற்று': 100};

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
