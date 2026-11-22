import '../number_words_language.dart';

/// English number words with Indian and international grouping.
class EnglishNumberWords extends NumberWordsLanguage {
  const EnglishNumberWords();

  @override
  String get code => 'en';

  static const List<String> _belowTwenty = <String>[
    'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
  ];

  static const List<String> _tens = <String>[
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
    'Eighty', 'Ninety',
  ];

  static final List<String> _words = _build();

  static List<String> _build() {
    final words = <String>[..._belowTwenty];
    for (var tens = 2; tens <= 9; tens++) {
      for (var unit = 0; unit <= 9; unit++) {
        words.add(
          unit == 0 ? _tens[tens] : '${_tens[tens]}-${_belowTwenty[unit]}',
        );
      }
    }
    return List<String>.unmodifiable(words);
  }

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'Point';
  @override
  String get minusWord => 'Minus';
  @override
  String get hundredWord => 'Hundred';
  @override
  String get thousandWord => 'Thousand';
  @override
  String get lakhWord => 'Lakh';
  @override
  String get croreWord => 'Crore';
  @override
  String get millionWord => 'Million';
  @override
  String get billionWord => 'Billion';
  @override
  String get trillionWord => 'Trillion';

  @override
  String get currencyUnitSingular => 'Rupee';
  @override
  String get currencyUnitPlural => 'Rupees';
  @override
  String get currencySubunitSingular => 'Paisa';
  @override
  String get currencySubunitPlural => 'Paise';
  @override
  String get currencyOnlyWord => 'Only';

  @override
  String hundredForm(int hundreds) => '${unitWord(hundreds)} $hundredWord';
}
