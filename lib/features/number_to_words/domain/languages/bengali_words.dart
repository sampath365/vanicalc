import '../number_words_language.dart';

/// Bengali (বাংলা) number words.
class BengaliNumberWords extends NumberWordsLanguage {
  const BengaliNumberWords();

  @override
  String get code => 'bn';

  static const List<String> _words = <String>[
    'শূন্য', 'এক', 'দুই', 'তিন', 'চার', 'পাঁচ', 'ছয়', 'সাত', 'আট', 'নয়',
    'দশ', 'এগারো', 'বারো', 'তেরো', 'চৌদ্দ', 'পনেরো', 'ষোলো', 'সতেরো',
    'আঠারো', 'উনিশ',
    'বিশ', 'একুশ', 'বাইশ', 'তেইশ', 'চব্বিশ', 'পঁচিশ', 'ছাব্বিশ', 'সাতাশ',
    'আটাশ', 'ঊনত্রিশ',
    'ত্রিশ', 'একত্রিশ', 'বত্রিশ', 'তেত্রিশ', 'চৌত্রিশ', 'পঁয়ত্রিশ', 'ছত্রিশ',
    'সাঁইত্রিশ', 'আটত্রিশ', 'ঊনচল্লিশ',
    'চল্লিশ', 'একচল্লিশ', 'বিয়াল্লিশ', 'তেতাল্লিশ', 'চুয়াল্লিশ', 'পঁয়তাল্লিশ',
    'ছেচল্লিশ', 'সাতচল্লিশ', 'আটচল্লিশ', 'ঊনপঞ্চাশ',
    'পঞ্চাশ', 'একান্ন', 'বায়ান্ন', 'তিপ্পান্ন', 'চুয়ান্ন', 'পঞ্চান্ন',
    'ছাপ্পান্ন', 'সাতান্ন', 'আটান্ন', 'ঊনষাট',
    'ষাট', 'একষট্টি', 'বাষট্টি', 'তেষট্টি', 'চৌষট্টি', 'পঁয়ষট্টি', 'ছেষট্টি',
    'সাতষট্টি', 'আটষট্টি', 'ঊনসত্তর',
    'সত্তর', 'একাত্তর', 'বাহাত্তর', 'তিয়াত্তর', 'চুয়াত্তর', 'পঁচাত্তর',
    'ছিয়াত্তর', 'সাতাত্তর', 'আটাত্তর', 'ঊনআশি',
    'আশি', 'একাশি', 'বিরাশি', 'তিরাশি', 'চুরাশি', 'পঁচাশি', 'ছিয়াশি',
    'সাতাশি', 'আটাশি', 'ঊননব্বই',
    'নব্বই', 'একানব্বই', 'বিরানব্বই', 'তিরানব্বই', 'চুরানব্বই', 'পঁচানব্বই',
    'ছিয়ানব্বই', 'সাতানব্বই', 'আটানব্বই', 'নিরানব্বই',
  ];

  @override
  List<String> get words0To99 => _words;

  @override
  String get pointWord => 'দশমিক';
  @override
  String get minusWord => 'বিয়োগ';
  @override
  String get hundredWord => 'শ';
  @override
  String get thousandWord => 'হাজার';
  @override
  String get lakhWord => 'লক্ষ';
  @override
  String get croreWord => 'কোটি';
  @override
  String get millionWord => 'মিলিয়ন';
  @override
  String get billionWord => 'বিলিয়ন';
  @override
  String get trillionWord => 'ট্রিলিয়ন';

  @override
  String get currencyUnitSingular => 'টাকা';
  @override
  String get currencyUnitPlural => 'টাকা';
  @override
  String get currencySubunitSingular => 'পয়সা';
  @override
  String get currencySubunitPlural => 'পয়সা';
  @override
  String get currencyOnlyWord => 'মাত্র';
  @override
  bool get pluralizesCurrency => false;

  @override
  Map<String, int> get extraWordValues => const {'শত': 100, 'একশ': 100};

  static const List<String> _hundreds = <String>[
    '', 'একশ', 'দুইশ', 'তিনশ', 'চারশ', 'পাঁচশ', 'ছশ', 'সাতশ', 'আটশ', 'নয়শ',
  ];

  @override
  String hundredForm(int hundreds) => _hundreds[hundreds];
}
