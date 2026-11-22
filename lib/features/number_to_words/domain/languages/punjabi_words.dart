import '../number_words_language.dart';

/// Punjabi (ਪੰਜਾਬੀ) number words.
class PunjabiNumberWords extends NumberWordsLanguage {
  const PunjabiNumberWords();

  @override
  String get code => 'pa';

  static const List<String> _words = <String>[
    'ਸਿਫ਼ਰ', 'ਇੱਕ', 'ਦੋ', 'ਤਿੰਨ', 'ਚਾਰ', 'ਪੰਜ', 'ਛੇ', 'ਸੱਤ', 'ਅੱਠ', 'ਨੌਂ',
    'ਦਸ', 'ਗਿਆਰਾਂ', 'ਬਾਰਾਂ', 'ਤੇਰਾਂ', 'ਚੌਦਾਂ', 'ਪੰਦਰਾਂ', 'ਸੋਲਾਂ', 'ਸਤਾਰਾਂ',
    'ਅਠਾਰਾਂ', 'ਉੱਨੀ',
    'ਵੀਹ', 'ਇੱਕੀ', 'ਬਾਈ', 'ਤੇਈ', 'ਚੌਵੀ', 'ਪੱਚੀ', 'ਛੱਬੀ', 'ਸਤਾਈ', 'ਅਠਾਈ',
    'ਉਨੱਤੀ',
    'ਤੀਹ', 'ਇਕੱਤੀ', 'ਬੱਤੀ', 'ਤੇਤੀ', 'ਚੌਂਤੀ', 'ਪੈਂਤੀ', 'ਛੱਤੀ', 'ਸੈਂਤੀ',
    'ਅਠੱਤੀ', 'ਉਨਤਾਲੀ',
    'ਚਾਲੀ', 'ਇਕਤਾਲੀ', 'ਬਤਾਲੀ', 'ਤਰਤਾਲੀ', 'ਚੁਤਾਲੀ', 'ਪੰਤਾਲੀ', 'ਛਿਆਲੀ',
    'ਸੰਤਾਲੀ', 'ਅਠਤਾਲੀ', 'ਉਨੰਜਾ',
    'ਪੰਜਾਹ', 'ਇਕਵੰਜਾ', 'ਬਵੰਜਾ', 'ਤਰਵੰਜਾ', 'ਚੁਰੰਜਾ', 'ਪਚਵੰਜਾ', 'ਛਪੰਜਾ',
    'ਸਤਵੰਜਾ', 'ਅਠਵੰਜਾ', 'ਉਨਾਹਠ',
    'ਸੱਠ', 'ਇਕਾਹਠ', 'ਬਾਹਠ', 'ਤਰੇਹਠ', 'ਚੌਂਹਠ', 'ਪੈਂਹਠ', 'ਛਿਆਹਠ', 'ਸਤਾਹਠ',
    'ਅਠਾਹਠ', 'ਉਨੱਤਰ',
    'ਸੱਤਰ', 'ਇਕਹੱਤਰ', 'ਬਹੱਤਰ', 'ਤਿਹੱਤਰ', 'ਚੌਹੱਤਰ', 'ਪੰਝੱਤਰ', 'ਛਿਹੱਤਰ',
    'ਸਤੱਹਤਰ', 'ਅਠੱਹਤਰ', 'ਉਨਾਸੀ',
    'ਅੱਸੀ', 'ਇਕਾਸੀ', 'ਬਿਆਸੀ', 'ਤਿਰਾਸੀ', 'ਚੌਰਾਸੀ', 'ਪਚਾਸੀ', 'ਛਿਆਸੀ',
    'ਸਤਾਸੀ', 'ਅਠਾਸੀ', 'ਉਨਾਨਵੇਂ',
    'ਨੱਬੇ', 'ਇਕਾਨਵੇਂ', 'ਬਾਨਵੇਂ', 'ਤਿਰਾਨਵੇਂ', 'ਚੌਰਾਨਵੇਂ', 'ਪਚਾਨਵੇਂ', 'ਛਿਆਨਵੇਂ',
    'ਸਤਾਨਵੇਂ', 'ਅਠਾਨਵੇਂ', 'ਨੜਿਨਵੇਂ',
  ];

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'ਦਸ਼ਮਲਵ';
  @override
  String get minusWord => 'ਘਟਾਓ';
  @override
  String get hundredWord => 'ਸੌ';
  @override
  String get thousandWord => 'ਹਜ਼ਾਰ';
  @override
  String get lakhWord => 'ਲੱਖ';
  @override
  String get croreWord => 'ਕਰੋੜ';
  @override
  String get millionWord => 'ਮਿਲੀਅਨ';
  @override
  String get billionWord => 'ਬਿਲੀਅਨ';
  @override
  String get trillionWord => 'ਟ੍ਰਿਲੀਅਨ';

  @override
  String get currencyUnitSingular => 'ਰੁਪਇਆ';
  @override
  String get currencyUnitPlural => 'ਰੁਪਏ';
  @override
  String get currencySubunitSingular => 'ਪੈਸਾ';
  @override
  String get currencySubunitPlural => 'ਪੈਸੇ';
  @override
  String get currencyOnlyWord => 'ਸਿਰਫ਼';

  @override
  String hundredForm(int hundreds) => '${unitWord(hundreds)} $hundredWord';
}
