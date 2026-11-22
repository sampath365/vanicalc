import '../number_words_language.dart';

/// Hindi (हिन्दी) number words.
class HindiNumberWords extends NumberWordsLanguage {
  const HindiNumberWords();

  @override
  String get code => 'hi';

  static const List<String> _words = <String>[
    'शून्य', 'एक', 'दो', 'तीन', 'चार', 'पाँच', 'छह', 'सात', 'आठ', 'नौ',
    'दस', 'ग्यारह', 'बारह', 'तेरह', 'चौदह', 'पंद्रह', 'सोलह', 'सत्रह', 'अठारह',
    'उन्नीस',
    'बीस', 'इक्कीस', 'बाईस', 'तेईस', 'चौबीस', 'पच्चीस', 'छब्बीस', 'सत्ताईस',
    'अट्ठाईस', 'उनतीस',
    'तीस', 'इकतीस', 'बत्तीस', 'तैंतीस', 'चौंतीस', 'पैंतीस', 'छत्तीस',
    'सैंतीस', 'अड़तीस', 'उनतालीस',
    'चालीस', 'इकतालीस', 'बयालीस', 'तैंतालीस', 'चवालीस', 'पैंतालीस',
    'छियालीस', 'सैंतालीस', 'अड़तालीस', 'उनचास',
    'पचास', 'इक्यावन', 'बावन', 'तिरेपन', 'चौवन', 'पचपन', 'छप्पन', 'सत्तावन',
    'अट्ठावन', 'उनसठ',
    'साठ', 'इकसठ', 'बासठ', 'तिरसठ', 'चौंसठ', 'पैंसठ', 'छियासठ', 'सड़सठ',
    'अड़सठ', 'उनहत्तर',
    'सत्तर', 'इकहत्तर', 'बहत्तर', 'तिहत्तर', 'चौहत्तर', 'पचहत्तर', 'छिहत्तर',
    'सतहत्तर', 'अठहत्तर', 'उन्नासी',
    'अस्सी', 'इक्यासी', 'बयासी', 'तिरासी', 'चौरासी', 'पचासी', 'छियासी',
    'सत्तासी', 'अट्ठासी', 'नवासी',
    'नब्बे', 'इक्यानवे', 'बानवे', 'तिरानवे', 'चौरानवे', 'पचानवे', 'छियानवे',
    'सत्तानवे', 'अट्ठानवे', 'निन्यानवे',
  ];

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'दशमलव';
  @override
  String get minusWord => 'माइनस';
  @override
  String get hundredWord => 'सौ';
  @override
  String get thousandWord => 'हज़ार';
  @override
  String get lakhWord => 'लाख';
  @override
  String get croreWord => 'करोड़';
  @override
  String get millionWord => 'मिलियन';
  @override
  String get billionWord => 'बिलियन';
  @override
  String get trillionWord => 'ट्रिलियन';

  @override
  String get currencyUnitSingular => 'रुपया';
  @override
  String get currencyUnitPlural => 'रुपये';
  @override
  String get currencySubunitSingular => 'पैसा';
  @override
  String get currencySubunitPlural => 'पैसे';
  @override
  String get currencyOnlyWord => 'केवल';

  @override
  String hundredForm(int hundreds) => '${unitWord(hundreds)} $hundredWord';
}
