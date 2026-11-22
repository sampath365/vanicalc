import '../number_words_language.dart';

/// Gujarati (ગુજરાતી) number words.
class GujaratiNumberWords extends NumberWordsLanguage {
  const GujaratiNumberWords();

  @override
  String get code => 'gu';

  static const List<String> _words = <String>[
    'શૂન્ય',
    'એક',
    'બે',
    'ત્રણ',
    'ચાર',
    'પાંચ',
    'છ',
    'સાત',
    'આઠ',
    'નવ',
    'દસ',
    'અગિયાર',
    'બાર',
    'તેર',
    'ચૌદ',
    'પંદર',
    'સોળ',
    'સત્તર',
    'અઢાર',
    'ઓગણીસ',
    'વીસ',
    'એકવીસ',
    'બાવીસ',
    'તેવીસ',
    'ચોવીસ',
    'પચ્ચીસ',
    'છવ્વીસ',
    'સત્તાવીસ',
    'અઠ્ઠાવીસ',
    'ઓગણત્રીસ',
    'ત્રીસ',
    'એકત્રીસ',
    'બત્રીસ',
    'તેત્રીસ',
    'ચોત્રીસ',
    'પાંત્રીસ',
    'છત્રીસ',
    'સાડત્રીસ',
    'આડત્રીસ',
    'ઓગણચાલીસ',
    'ચાલીસ',
    'એકતાલીસ',
    'બેતાલીસ',
    'તેતાલીસ',
    'ચુંમાલીસ',
    'પિસ્તાલીસ',
    'છેતાલીસ',
    'સુડતાલીસ',
    'અડતાલીસ',
    'ઓગણપચાસ',
    'પચાસ',
    'એકાવન',
    'બાવન',
    'ત્રેપન',
    'ચોપન',
    'પંચાવન',
    'છપ્પન',
    'સત્તાવન',
    'અઠ્ઠાવન',
    'ઓગણસાઠ',
    'સાઠ',
    'એકસઠ',
    'બાસઠ',
    'ત્રેસઠ',
    'ચોસઠ',
    'પાંસઠ',
    'છાસઠ',
    'સડસઠ',
    'અડસઠ',
    'અગણોસિત્તેર',
    'સિત્તેર',
    'એકોતેર',
    'બોતેર',
    'તોતેર',
    'ચુમોતેર',
    'પંચોતેર',
    'છોતેર',
    'સિત્યોતેર',
    'ઇઠ્યોતેર',
    'ઓગણાએંસી',
    'એંસી',
    'એક્યાસી',
    'બ્યાસી',
    'ત્યાસી',
    'ચોર્યાસી',
    'પંચાસી',
    'છ્યાસી',
    'સિત્યાસી',
    'ઈઠ્યાસી',
    'નેવ્યાસી',
    'નેવું',
    'એકાણું',
    'બાણું',
    'ત્રાણું',
    'ચોરાણું',
    'પંચાણું',
    'છન્નું',
    'સત્તાણું',
    'અઠ્ઠાણું',
    'નવ્વાણું',
  ];

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'દશાંશ';
  @override
  String get minusWord => 'માઈનસ';
  @override
  String get hundredWord => 'સો';
  @override
  String get thousandWord => 'હજાર';
  @override
  String get lakhWord => 'લાખ';
  @override
  String get croreWord => 'કરોડ';
  @override
  String get millionWord => 'મિલિયન';
  @override
  String get billionWord => 'બિલિયન';
  @override
  String get trillionWord => 'ટ્રિલિયન';

  @override
  String get currencyUnitSingular => 'રૂપિયો';
  @override
  String get currencyUnitPlural => 'રૂપિયા';
  @override
  String get currencySubunitSingular => 'પૈસો';
  @override
  String get currencySubunitPlural => 'પૈસા';
  @override
  String get currencyOnlyWord => 'માત્ર';

  static const List<String> _hundreds = <String>[
    '',
    'એકસો',
    'બેસો',
    'ત્રણસો',
    'ચારસો',
    'પાંચસો',
    'છસો',
    'સાતસો',
    'આઠસો',
    'નવસો',
  ];

  @override
  String hundredForm(int hundreds) => _hundreds[hundreds];
}
