import '../number_words_language.dart';

/// Telugu (తెలుగు) number words.
class TeluguNumberWords extends NumberWordsLanguage {
  const TeluguNumberWords();

  @override
  String get code => 'te';

  static const List<String> _belowTwenty = <String>[
    'సున్నా', 'ఒకటి', 'రెండు', 'మూడు', 'నాలుగు', 'ఐదు', 'ఆరు', 'ఏడు',
    'ఎనిమిది', 'తొమ్మిది', 'పది', 'పదకొండు', 'పన్నెండు', 'పదమూడు',
    'పద్నాలుగు', 'పదిహేను', 'పదహారు', 'పదిహేడు', 'పద్దెనిమిది', 'పంతొమ్మిది',
  ];

  static const List<String> _tens = <String>[
    '', '', 'ఇరవై', 'ముప్పై', 'నలభై', 'యాభై', 'అరవై', 'డెబ్బై', 'ఎనభై', 'తొంభై',
  ];

  static final List<String> _words = _build();

  static List<String> _build() {
    final words = <String>[..._belowTwenty];
    for (var tens = 2; tens <= 9; tens++) {
      for (var unit = 0; unit <= 9; unit++) {
        words.add(unit == 0 ? _tens[tens] : '${_tens[tens]} ${_belowTwenty[unit]}');
      }
    }
    return List<String>.unmodifiable(words);
  }

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'పాయింట్';
  @override
  String get minusWord => 'మైనస్';
  @override
  String get hundredWord => 'వంద';
  @override
  String get thousandWord => 'వెయ్యి';
  @override
  String get lakhWord => 'లక్ష';
  @override
  String get croreWord => 'కోటి';
  @override
  String get millionWord => 'మిలియన్';
  @override
  String get billionWord => 'బిలియన్';
  @override
  String get trillionWord => 'ట్రిలియన్';

  @override
  String get currencyUnitSingular => 'రూపాయి';
  @override
  String get currencyUnitPlural => 'రూపాయలు';
  @override
  String get currencySubunitSingular => 'పైసా';
  @override
  String get currencySubunitPlural => 'పైసలు';
  @override
  String get currencyOnlyWord => 'మాత్రమే';

  @override
  Map<String, int> get extraWordValues => const {
    'వందలు': 100,
    'వందల': 100,
    'నూట': 100,
    'వేలు': 1000,
    'వేల': 1000,
    'లక్షలు': 100000,
    'లక్షల': 100000,
    'కోట్లు': 10000000,
    'కోట్ల': 10000000,
  };

  @override
  String hundredFormFor(int hundreds, int remainder) {
    if (hundreds == 1) {
      return remainder > 0 ? 'నూట' : 'వంద';
    }
    return '${unitWord(hundreds)} ${remainder > 0 ? 'వందల' : 'వందలు'}';
  }

  @override
  String scaleFormForCount(
    int count,
    String countWords,
    String scaleWord,
    bool hasRemainder,
  ) {
    if (scaleWord == thousandWord) {
      if (count == 1) return 'వెయ్యి';
      return '$countWords ${hasRemainder ? 'వేల' : 'వేలు'}';
    }
    if (scaleWord == lakhWord) {
      if (count == 1) return 'లక్ష';
      return '$countWords ${hasRemainder ? 'లక్షల' : 'లక్షలు'}';
    }
    if (scaleWord == croreWord) {
      if (count == 1) return 'కోటి';
      return '$countWords ${hasRemainder ? 'కోట్ల' : 'కోట్లు'}';
    }
    if (count == 1) return scaleWord;
    return '$countWords $scaleWord';
  }
}
