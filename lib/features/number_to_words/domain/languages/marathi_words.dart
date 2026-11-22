import '../number_words_language.dart';

/// Marathi (मराठी) number words.
class MarathiNumberWords extends NumberWordsLanguage {
  const MarathiNumberWords();

  @override
  String get code => 'mr';

  static const List<String> _words = <String>[
    'शून्य', 'एक', 'दोन', 'तीन', 'चार', 'पाच', 'सहा', 'सात', 'आठ', 'नऊ',
    'दहा', 'अकरा', 'बारा', 'तेरा', 'चौदा', 'पंधरा', 'सोळा', 'सतरा', 'अठरा',
    'एकोणीस',
    'वीस', 'एकवीस', 'बावीस', 'तेवीस', 'चोवीस', 'पंचवीस', 'सव्वीस', 'सत्तावीस',
    'अठ्ठावीस', 'एकोणतीस',
    'तीस', 'एकतीस', 'बत्तीस', 'तेहतीस', 'चौतीस', 'पस्तीस', 'छत्तीस', 'सदतीस',
    'अडतीस', 'एकोणचाळीस',
    'चाळीस', 'एक्केचाळीस', 'बेचाळीस', 'त्रेचाळीस', 'चव्वेचाळीस', 'पंचेचाळीस',
    'सेहेचाळीस', 'सत्तेचाळीस', 'अठ्ठेचाळीस', 'एकोणपन्नास',
    'पन्नास', 'एक्कावन्न', 'बावन्न', 'त्रेपन्न', 'चोपन्न', 'पंचावन्न', 'छप्पन्न',
    'सत्तावन्न', 'अठ्ठावन्न', 'एकोणसाठ',
    'साठ', 'एकसष्ट', 'बासष्ट', 'त्रेसष्ट', 'चौसष्ट', 'पासष्ट', 'सहासष्ट',
    'सदुसष्ट', 'अडुसष्ट', 'एकोणसत्तर',
    'सत्तर', 'एक्काहत्तर', 'बाहत्तर', 'त्र्याहत्तर', 'चौऱ्याहत्तर', 'पंच्याहत्तर',
    'शहात्तर', 'सत्याहत्तर', 'अठ्ठ्याहत्तर', 'एकोणऐंशी',
    'ऐंशी', 'एक्क्याऐंशी', 'ब्याऐंशी', 'त्र्याऐंशी', 'चौऱ्याऐंशी', 'पंच्याऐंशी',
    'शहाऐंशी', 'सत्त्याऐंशी', 'अठ्ठ्याऐंशी', 'एकोणनव्वद',
    'नव्वद', 'एक्क्याण्णव', 'ब्याण्णव', 'त्र्याण्णव', 'चौऱ्याण्णव', 'पंच्याण्णव',
    'शहाण्णव', 'सत्त्याण्णव', 'अठ्ठ्याण्णव', 'नव्व्याण्णव',
  ];

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'दशांश';
  @override
  String get minusWord => 'वजा';
  @override
  String get hundredWord => 'शे';
  @override
  String get thousandWord => 'हजार';
  @override
  String get lakhWord => 'लाख';
  @override
  String get croreWord => 'कोटी';
  @override
  String get millionWord => 'दशलक्ष';
  @override
  String get billionWord => 'अब्ज';
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
  String get currencyOnlyWord => 'फक्त';

  @override
  Map<String, int> get extraWordValues => const {'शे': 100};

  static const List<String> _hundreds = <String>[
    '', 'एकशे', 'दोनशे', 'तीनशे', 'चारशे', 'पाचशे', 'सहाशे', 'सातशे', 'आठशे',
    'नऊशे',
  ];

  @override
  String hundredForm(int hundreds) => _hundreds[hundreds];
}
