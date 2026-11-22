import '../../../core/constants/number_system.dart';

/// Local, offline number-to-words engine for a single language.
///
/// Subclasses provide the 0–99 vocabulary and scale words; the shared
/// algorithm handles grouping (Indian or international), decimals, negatives
/// and currency output. No network access is ever required.
abstract class NumberWordsLanguage {
  const NumberWordsLanguage();

  String get code;

  /// Exactly 100 entries, index 0 → "zero".
  List<String> get words0To99;

  String get pointWord;
  String get minusWord;
  String get hundredWord;
  String get thousandWord;
  String get lakhWord;
  String get croreWord;
  String get millionWord;
  String get billionWord;
  String get trillionWord;

  /// Joiner inserted before the final segment (English "and"), usually empty.
  String get andWord => '';

  String get currencyUnitSingular;
  String get currencyUnitPlural;
  String get currencySubunitSingular;
  String get currencySubunitPlural;
  String get currencyOnlyWord;

  /// Whether currency units are pluralised for counts other than one.
  bool get pluralizesCurrency => true;

  /// Additional spoken variants of scale words (plural or combining forms).
  Map<String, int> get extraWordValues => const {};

  String get zeroWord => words0To99[0];

  String unitWord(int value) {
    assert(value >= 0 && value < 100, 'unitWord expects 0..99');
    return words0To99[value];
  }

  /// Words for a hundreds group, e.g. `300` → "Three Hundred".
  String hundredForm(int hundreds) {
    if (hundreds == 1) return hundredWord;
    return '${unitWord(hundreds)} $hundredWord';
  }

  /// Words for `count × scale`, e.g. `2` + "Thousand" → "Two Thousand".
  String scaleForm(String countWords, String scaleWord) {
    return '$countWords $scaleWord';
  }

  /// Scale hook that also receives the numeric count, so languages with
  /// irregular plurals (Telugu వేలు / లక్షలు) can adapt.
  String scaleFormFor(int count, String countWords, String scaleWord) {
    return scaleForm(countWords, scaleWord);
  }

  /// Like [scaleFormFor] but also tells the language whether another segment
  /// follows (Telugu uses వందల/వేల/లక్షల before a remainder).
  String scaleFormForCount(
    int count,
    String countWords,
    String scaleWord,
    bool hasRemainder,
  ) {
    return scaleFormFor(count, countWords, scaleWord);
  }

  /// Hundreds hook that knows whether a remainder follows, which several
  /// Indian languages use to pick a combining form (Telugu నూట, Tamil நூற்று).
  String hundredFormFor(int hundreds, int remainder) {
    return hundredForm(hundreds);
  }

  String joinParts(List<String> parts) {
    final cleaned = parts.where((part) => part.trim().isNotEmpty).toList();
    return cleaned.join(' ');
  }

  /// Converts [value] into words. Currency output appends the local currency
  /// words and the "only" suffix used on invoices and receipts.
  String convert(
    num value, {
    NumberSystem system = NumberSystem.indian,
    bool currency = false,
  }) {
    return fromString(
      _numToPlainString(value),
      system: system,
      currency: currency,
    );
  }

  /// Converts a user supplied numeric string, preserving typed decimals.
  String fromString(
    String raw, {
    NumberSystem system = NumberSystem.indian,
    bool currency = false,
  }) {
    var text = raw.trim().replaceAll(',', '').replaceAll(' ', '');
    if (text.isEmpty) return '';
    var negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }

    final dot = text.indexOf('.');
    var wholeText = dot == -1 ? text : text.substring(0, dot);
    var fractionText = dot == -1 ? '' : text.substring(dot + 1);
    if (wholeText.isEmpty) wholeText = '0';
    if (!RegExp(r'^\d+$').hasMatch(wholeText)) return '';
    if (fractionText.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fractionText)) {
      return '';
    }
    fractionText = fractionText.replaceFirst(RegExp(r'0+$'), '');
    if (currency) {
      if (fractionText.length > 2) {
        fractionText = fractionText.substring(0, 2);
      }
    }
    if (fractionText.length > 6) {
      fractionText = fractionText.substring(0, 6);
    }

    final whole = int.tryParse(wholeText);
    if (whole == null) return '';

    if (currency) {
      final words = StringBuffer();
      if (negative) words.write('$minusWord ');
      words.write(integerToWords(whole, system));
      words.write(' ');
      words.write(whole == 1 && pluralizesCurrency
          ? currencyUnitSingular
          : currencyUnitPlural);
      if (fractionText.isNotEmpty) {
        final subunits = int.parse(fractionText);
        if (subunits > 0) {
          words.write(' ');
          words.write(integerToWords(subunits, system));
          words.write(' ');
          words.write(subunits == 1 && pluralizesCurrency
              ? currencySubunitSingular
              : currencySubunitPlural);
        }
      }
      words.write(' ');
      words.write(currencyOnlyWord);
      return words.toString().trim();
    }

    final buffer = StringBuffer();
    if (negative) buffer.write('$minusWord ');
    buffer.write(integerToWords(whole, system));
    if (fractionText.isNotEmpty) {
      buffer.write(' $pointWord ');
      buffer.write(fractionText.split('').map((d) => unitWord(int.parse(d))).join(' '));
    }
    return buffer.toString().trim();
  }

  /// Converts a non-negative integer using the requested grouping.
  String integerToWords(int value, [NumberSystem system = NumberSystem.indian]) {
    if (value < 0) {
      return '$minusWord ${integerToWords(-value, system)}';
    }
    if (value == 0) return zeroWord;
    return system == NumberSystem.indian
        ? _indianGrouping(value)
        : _internationalGrouping(value);
  }

  String _indianGrouping(int value) {
    final parts = <String>[];
    var remaining = value;
    if (remaining >= 10000000) {
      final count = remaining ~/ 10000000;
      remaining %= 10000000;
      parts.add(
        _scaled(
          count,
          croreWord,
          NumberSystem.indian,
          hasRemainder: remaining > 0,
        ),
      );
    }
    if (remaining >= 100000) {
      final count = remaining ~/ 100000;
      remaining %= 100000;
      parts.add(
        _scaled(
          count,
          lakhWord,
          NumberSystem.indian,
          hasRemainder: remaining > 0,
        ),
      );
    }
    if (remaining >= 1000) {
      final count = remaining ~/ 1000;
      remaining %= 1000;
      parts.add(
        _scaled(
          count,
          thousandWord,
          NumberSystem.indian,
          hasRemainder: remaining > 0,
        ),
      );
    }
    _appendBelowThousand(parts, remaining, NumberSystem.indian);
    return joinParts(parts);
  }

  String _internationalGrouping(int value) {
    final parts = <String>[];
    var remaining = value;
    const scales = <int>[
      1000000000000,
      1000000000,
      1000000,
      1000,
    ];
    final names = <String>[
      trillionWord,
      billionWord,
      millionWord,
      thousandWord,
    ];
    for (var i = 0; i < scales.length; i++) {
      if (remaining >= scales[i]) {
        final count = remaining ~/ scales[i];
        remaining %= scales[i];
        parts.add(
          _scaled(
            count,
            names[i],
            NumberSystem.international,
            hasRemainder: remaining > 0,
          ),
        );
      }
    }
    _appendBelowThousand(parts, remaining, NumberSystem.international);
    return joinParts(parts);
  }

  String _scaled(
    int count,
    String scale,
    NumberSystem system, {
    bool hasRemainder = false,
  }) {
    final countWords =
        count < 100 ? unitWord(count) : integerToWords(count, system);
    return scaleFormForCount(count, countWords, scale, hasRemainder);
  }

  void _appendBelowThousand(
    List<String> parts,
    int remaining,
    NumberSystem system,
  ) {
    if (remaining >= 100) {
      final hundreds = remaining ~/ 100;
      remaining %= 100;
      parts.add(hundredFormFor(hundreds, remaining));
      if (remaining > 0 && andWord.isNotEmpty) parts.add(andWord);
    }
    if (remaining > 0) {
      parts.add(unitWord(remaining));
    }
  }

  static String _numToPlainString(num value) {
    if (value is int) return value.toString();
    final doubleValue = value.toDouble();
    if (doubleValue == doubleValue.roundToDouble() &&
        doubleValue.abs() < 1e15) {
      return doubleValue.toInt().toString();
    }
    return doubleValue.toString();
  }
}

/// Helper that joins a tens stem with a unit using a script's dependent
/// vowel signs, which is how Dravidian numerals behave (e.g. Kannada
/// ಇಪ್ಪತ್ತು + ಒಂದು → ಇಪ್ಪತ್ತೊಂದು).
class VowelJoiner {
  const VowelJoiner(this.independentToDependent);

  final Map<String, String> independentToDependent;

  /// Returns the dependent form of the leading vowel, or `null` when the word
  /// starts with a consonant.
  String? leadingVowelSign(String word) {
    if (word.isEmpty) return null;
    final first = word.substring(0, 1);
    return independentToDependent[first];
  }

  /// Applies the vowel sign to the rest of the word.
  String applySign(String word, String sign) {
    return '$sign${word.substring(1)}';
  }
}
