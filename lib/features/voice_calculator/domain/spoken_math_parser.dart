import '../../../core/localization/app_language.dart';
import '../../number_to_words/domain/number_to_words_engine.dart';
import '../../calculator/domain/calculator_error.dart';
import '../../calculator/domain/expression_engine.dart';

/// Actions a spoken phrase can trigger instead of a calculation.
enum VoiceCommandType {
  clear,
  deleteLast,
  repeatAnswer,
  showHistory,
  openScientific,
  setLanguage,
  speakInLanguage,
}

class VoiceCommand {
  const VoiceCommand(this.type, {this.language});

  final VoiceCommandType type;
  final AppLanguage? language;
}

/// Outcome of interpreting a spoken phrase.
class SpokenParseResult {
  const SpokenParseResult({
    required this.raw,
    required this.expression,
    this.command,
    this.errorCode,
    this.ambiguous = false,
    this.confidence = 0,
    this.unknownWords = const [],
  });

  final String raw;
  final String expression;
  final VoiceCommand? command;
  final String? errorCode;
  final bool ambiguous;
  final double confidence;
  final List<String> unknownWords;

  bool get isCommand => command != null;

  bool get isCalculation => !isCommand && expression.isNotEmpty && errorCode == null;
}

/// Interprets natural spoken mathematics in ten languages and converts it into
/// an expression understood by [ExpressionEngine].
///
/// Everything runs locally: number words come from [NumberToWordsEngine], so
/// the parser works without network access.
class SpokenMathParser {
  const SpokenMathParser({
    this.engine = const ExpressionEngine(),
    this.numberEngine = const NumberToWordsEngine(),
  });

  final ExpressionEngine engine;
  final NumberToWordsEngine numberEngine;

  SpokenParseResult parse(String input, AppLanguage language) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return const SpokenParseResult(raw: '', expression: '');
    }
    final normalized = _normalize(raw);
    final command = _detectCommand(normalized);
    if (command != null) {
      return SpokenParseResult(
        raw: raw,
        expression: '',
        command: command,
        confidence: 1,
      );
    }

    final vocabulary = _vocabulary[language.code] ?? _vocabulary['en']!;
    final english = _vocabulary['en']!;

    var text = _convertNumberWords(normalized, language);
    text = _applyStructuralPatterns(text, vocabulary, english);
    text = _applyOperatorWords(text, vocabulary, english);
    text = _stripFillers(text, vocabulary, english);
    text = _wrapFunctions(text);
    final expression = _cleanExpression(text);

    if (expression.isEmpty) {
      return SpokenParseResult(
        raw: raw,
        expression: '',
        errorCode: CalcError.invalid,
        ambiguous: true,
        confidence: 0,
      );
    }

    final hasOperator = RegExp(r'[+\-*/^%!]').hasMatch(expression);
    final evaluation = engine.evaluate(expression);
    final unknown = _unknownWords(normalized, language, vocabulary, english);

    return SpokenParseResult(
      raw: raw,
      expression: expression,
      errorCode: evaluation.isSuccess ? null : evaluation.errorCode,
      ambiguous: !hasOperator,
      confidence: _confidence(normalized, unknown.length),
      unknownWords: unknown,
    );
  }

  // ---------------------------------------------------------------- commands

  VoiceCommand? _detectCommand(String text) {
    final language = _languageInText(text);
    if (language != null) {
      final speakWords = _speakWords.expand((entry) => entry).toList();
      final asksToSpeak = speakWords.any(text.contains);
      return VoiceCommand(
        asksToSpeak
            ? VoiceCommandType.speakInLanguage
            : VoiceCommandType.setLanguage,
        language: language,
      );
    }
    for (final entry in _commandWords.entries) {
      for (final phrase in entry.value) {
        if (text.contains(phrase)) {
          return VoiceCommand(entry.key);
        }
      }
    }
    return null;
  }

  AppLanguage? _languageInText(String text) {
    for (final language in AppLanguage.values) {
      final names = <String>{
        language.englishName.toLowerCase(),
        language.nativeName.toLowerCase(),
        language.code,
      };
      for (final name in names) {
        if (name.length > 2 && text.contains(name)) return language;
        if (name.length == 2 &&
            RegExp('(^|\\s)$name(\\s|\$)').hasMatch(text)) {
          return language;
        }
      }
    }
    return null;
  }

  // ------------------------------------------------------------ number words

  String _convertNumberWords(String text, AppLanguage language) {
    final dictionaries = <NumberWordDictionary>[
      NumberWordDictionary.forLanguage(numberEngine.languageFor(language.code)),
      NumberWordDictionary.forLanguage(numberEngine.languageFor('en')),
    ];
    final vocabulary = _vocabulary[language.code] ?? _vocabulary['en']!;
    final tokens = text.split(' ');
    final output = <String>[];
    var index = 0;

    while (index < tokens.length) {
      final token = tokens[index];
      if (!_isNumberToken(token, dictionaries, vocabulary)) {
        output.add(token);
        index++;
        continue;
      }
      final phrase = <String>[token];
      index++;
      while (index < tokens.length) {
        final next = tokens[index];
        if (_isNumberToken(next, dictionaries, vocabulary)) {
          phrase.add(next);
          index++;
          continue;
        }
        if (vocabulary.andWords.contains(next) &&
            index + 1 < tokens.length &&
            _isNumberToken(tokens[index + 1], dictionaries, vocabulary)) {
          phrase.add(next);
          index++;
          continue;
        }
        break;
      }
      final number = _phraseToNumber(phrase, dictionaries, vocabulary);
      output.add(number ?? phrase.join(' '));
    }
    return output.join(' ');
  }

  bool _isNumberToken(
    String token,
    List<NumberWordDictionary> dictionaries,
    _Vocabulary vocabulary,
  ) {
    return _lookup(token, dictionaries) != null ||
        vocabulary.pointWords.contains(token) ||
        vocabulary.minusWords.contains(token);
  }

  int? _lookup(String token, List<NumberWordDictionary> dictionaries) {
    for (final dictionary in dictionaries) {
      final direct = dictionary.valueOf(token);
      if (direct != null) return direct;
      // Speech often appends case suffixes ("వందలలో"). Try shrinking the
      // token until a known word matches.
      for (var end = token.length - 1; end >= 2; end--) {
        final value = dictionary.valueOf(token.substring(0, end));
        if (value != null) return value;
      }
    }
    return null;
  }

  String? _phraseToNumber(
    List<String> phrase,
    List<NumberWordDictionary> dictionaries,
    _Vocabulary vocabulary,
  ) {
    if (phrase.isEmpty) return null;
    var negative = false;
    var words = List<String>.from(phrase);
    if (vocabulary.minusWords.contains(words.first)) {
      negative = true;
      words = words.sublist(1);
    }
    if (words.isEmpty) return null;

    final pointIndex = words.indexWhere(vocabulary.pointWords.contains);
    final wholeWords =
        pointIndex == -1 ? words : words.sublist(0, pointIndex);
    final fractionWords =
        pointIndex == -1 ? <String>[] : words.sublist(pointIndex + 1);

    final whole = _integerFromWords(wholeWords, dictionaries);
    if (whole == null) return null;

    final buffer = StringBuffer(whole.toString());
    if (fractionWords.isNotEmpty) {
      final digits = <String>[];
      for (final word in fractionWords) {
        final value = _lookup(word, dictionaries);
        if (value == null || value < 0 || value > 9) return null;
        digits.add('$value');
      }
      buffer.write('.${digits.join()}');
    }
    final sign = negative ? '-' : '';
    return '$sign$buffer';
  }

  int? _integerFromWords(
    List<String> words,
    List<NumberWordDictionary> dictionaries,
  ) {
    var total = 0;
    var current = 0;
    var matched = false;
    for (final word in words) {
      final value = _lookup(word, dictionaries);
      if (value == null) continue;
      matched = true;
      if (value < 100) {
        current += value;
      } else if (value == 100) {
        current = (current == 0 ? 1 : current) * 100;
      } else {
        total += (current == 0 ? 1 : current) * value;
        current = 0;
      }
    }
    if (!matched) return null;
    return total + current;
  }

  // -------------------------------------------------------------- operators

  String _applyStructuralPatterns(
    String text,
    _Vocabulary vocabulary,
    _Vocabulary english,
  ) {
    var result = text;

    for (final word in [...vocabulary.addWords, ...english.addWords]) {
      final pattern = RegExp('^${RegExp.escape(word)}\\s+(.*)\$');
      final match = pattern.firstMatch(result);
      if (match != null) {
        var rest = match.group(1)!;
        rest = rest.replaceAll(',', ' + ');
        rest = rest.replaceAll(RegExp(r'\s+and\s+'), ' + ');
        for (final andWord in vocabulary.andWords) {
          rest = rest.replaceAll(' $andWord ', ' + ');
        }
        result = rest;
        break;
      }
    }

    result = _replacePattern(
      result,
      r'^(?:subtract|minus)\s+([0-9.]+)\s+from\s+([0-9.]+)$',
      (m) => '${m[2]} - ${m[1]}',
    );
    result = _replacePattern(
      result,
      r'^multiply\s+([0-9.]+)\s+by\s+([0-9.]+)$',
      (m) => '${m[1]} * ${m[2]}',
    );
    result = _replacePattern(
      result,
      r'^divide\s+([0-9.]+)\s+by\s+([0-9.]+)$',
      (m) => '${m[1]} / ${m[2]}',
    );
    result = _replacePattern(
      result,
      r'^([0-9.]+)\s+percent\s+of\s+([0-9.]+)$',
      (m) => '${m[1]} % * ${m[2]}',
    );
    result = _replacePattern(
      result,
      r'^square\s+of\s+([0-9.]+)$',
      (m) => '${m[1]} ^ 2',
    );
    result = _replacePattern(
      result,
      r'^cube\s+of\s+([0-9.]+)$',
      (m) => '${m[1]} ^ 3',
    );
    return result;
  }

  String _replacePattern(
    String input,
    String pattern,
    String Function(RegExpMatch match) replace,
  ) {
    final match = RegExp(pattern, caseSensitive: false).firstMatch(input);
    if (match == null) return input;
    return replace(match);
  }

  String _applyOperatorWords(
    String text,
    _Vocabulary vocabulary,
    _Vocabulary english,
  ) {
    final rules = <_Rule>[];
    void addRules(List<String> words, String replacement) {
      for (final word in words) {
        if (word.trim().isEmpty) continue;
        rules.add(_Rule(word, replacement));
      }
    }

    for (final vocab in [vocabulary, english]) {
      addRules(vocab.plusWords, ' + ');
      addRules(vocab.minusWords, ' - ');
      addRules(vocab.timesWords, ' * ');
      addRules(vocab.divideWords, ' / ');
      addRules(vocab.percentOfWords, ' % * ');
      addRules(vocab.percentWords, ' % ');
      addRules(vocab.sqrtWords, ' sqrt ');
      addRules(vocab.squaredWords, ' ^ 2 ');
      addRules(vocab.cubedWords, ' ^ 3 ');
      addRules(vocab.factorialWords, ' ! ');
      addRules(vocab.equalsWords, ' ');
      addRules(vocab.piWords, ' pi ');
    }
    rules.sort((a, b) => b.phrase.length.compareTo(a.phrase.length));

    var result = ' $text ';
    for (final rule in rules) {
      result = result.replaceAll(' ${rule.phrase} ', rule.replacement);
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _stripFillers(
    String text,
    _Vocabulary vocabulary,
    _Vocabulary english,
  ) {
    var result = text;
    final fillers = <String>{
      ...vocabulary.fillers,
      ...english.fillers,
    }..removeWhere((word) => word.trim().isEmpty);
    final ordered = fillers.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final filler in ordered) {
      result = result.replaceAll(' $filler ', ' ');
      if (result.startsWith('$filler ')) {
        result = result.substring(filler.length + 1);
      }
      if (result.endsWith(' $filler')) {
        result = result.substring(0, result.length - filler.length - 1);
      }
    }
    return result;
  }

  String _wrapFunctions(String text) {
    var result = text;
    final pattern = RegExp(r'sqrt\s*\(?([0-9.]+)\)?');
    result = result.replaceAllMapped(pattern, (match) => 'sqrt(${match[1]})');
    return result;
  }

  String _cleanExpression(String text) {
    final tokens = text.split(RegExp(r'\s+'));
    const allowedWords = {'sqrt', 'pi', 'e', 'mod'};
    final kept = <String>[];
    for (final token in tokens) {
      if (token.isEmpty) continue;
      if (allowedWords.contains(token)) {
        kept.add(token);
        continue;
      }
      if (token.startsWith('sqrt')) {
        final rest = token
            .substring(4)
            .replaceAll(RegExp(r'[^0-9+\-*/^%!().]'), '');
        kept.add('sqrt$rest');
        continue;
      }
      final cleaned = token.replaceAll(RegExp(r'[^0-9+\-*/^%!().]'), '');
      if (cleaned.isNotEmpty) kept.add(cleaned);
    }
    return kept.join().replaceAll(RegExp(r'[+\-*/^%]+$'), '');
  }

  List<String> _unknownWords(
    String text,
    AppLanguage language,
    _Vocabulary vocabulary,
    _Vocabulary english,
  ) {
    final dictionaries = <NumberWordDictionary>[
      NumberWordDictionary.forLanguage(numberEngine.languageFor(language.code)),
      NumberWordDictionary.forLanguage(numberEngine.languageFor('en')),
    ];
    final known = <String>{
      ...vocabulary.allWords,
      ...english.allWords,
      ...vocabulary.fillers,
      ...english.fillers,
    };
    final unknown = <String>[];
    for (final token in text.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      if (known.contains(token)) continue;
      if (_lookup(token, dictionaries) != null) continue;
      if (RegExp(r'^[0-9.+\-*/^%!()]+$').hasMatch(token)) continue;
      unknown.add(token);
    }
    return unknown;
  }

  double _confidence(String text, int unknownCount) {
    final tokens = text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).length;
    if (tokens == 0) return 0;
    return ((tokens - unknownCount) / tokens).clamp(0.0, 1.0);
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAllMapped(
          RegExp(r'(?<!\d)\.|\.(?!\d)'),
          (_) => ' ',
        )
        .replaceAll('?', ' ')
        .replaceAll('!', ' ! ')
        .replaceAll('=', ' ')
        .replaceAll('×', ' * ')
        .replaceAll('÷', ' / ')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('√', ' sqrt ')
        .replaceAll('π', ' pi ')
        .replaceAll(RegExp(r'[,\u060C\u3001]'), ' , ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ------------------------------------------------------------- vocabulary

  static const Map<String, _Vocabulary> _vocabulary = {
    'en': _Vocabulary(
      plusWords: ['plus', 'add', 'added to', 'sum of', 'increased by'],
      addWords: ['add', 'sum', 'sum of'],
      minusWords: ['minus', 'negative'],
      timesWords: ['multiplied by', 'multiply', 'times', 'into'],
      divideWords: ['divided by', 'divide', 'divided', 'over'],
      percentWords: ['percent', 'percentage', '%'],
      percentOfWords: ['percent of', 'percentage of'],
      sqrtWords: ['square root of', 'square root', 'root of', 'sqrt'],
      squaredWords: ['squared', 'square of'],
      cubedWords: ['cubed', 'cube of'],
      factorialWords: ['factorial'],
      pointWords: ['point', 'decimal'],
      equalsWords: ['equals', 'equal to', 'is equal to', 'is', 'makes', 'gives'],
      piWords: ['pi'],
      andWords: ['and'],
      fillers: [
        'what', 'whats', 'calculate', 'how', 'much', 'the', 'please', 'of',
        'result', 'answer', 'tell', 'me', 'can', 'you', 'do',
      ],
    ),
    'te': _Vocabulary(
      plusWords: ['ప్లస్', 'కలపండి', 'కలుపు', 'జోడించు', 'కూడా'],
      addWords: ['కలపండి', 'కలుపు', 'జోడించు'],
      minusWords: ['మైనస్', 'తీసివేయి', 'తీసివేయండి'],
      timesWords: ['గుణించు', 'గుణించండి', 'గుణకారం', 'టైమ్స్'],
      divideWords: ['భాగించు', 'భాగించండి', 'భాగాహారం', 'డివైడ్'],
      percentWords: ['శాతం', 'పర్సెంట్'],
      percentOfWords: ['శాతం లో', 'లో శాతం'],
      sqrtWords: ['వర్గమూలం', 'వర్గ మూలం', 'రూట్'],
      squaredWords: ['వర్గం', 'స్క్వేర్'],
      cubedWords: ['ఘనం'],
      factorialWords: ['ఫ్యాక్టోరియల్'],
      pointWords: ['పాయింట్', 'దశాంశం'],
      equalsWords: ['సమానం', 'ఎంత', 'ఇస్తుంది'],
      piWords: ['పై'],
      andWords: ['మరియు', 'ఇంకా'],
      fillers: ['ఏమిటి', 'ఎంత', 'లెక్కించు', 'చెప్పు', 'దయచేసి', 'ఫలితం'],
    ),
    'hi': _Vocabulary(
      plusWords: ['प्लस', 'जोड़', 'जमा', 'जोड़ो', 'जोड़ें'],
      addWords: ['जोड़', 'जोड़ो', 'जोड़ें', 'योग'],
      minusWords: ['माइनस', 'घटा', 'घटाओ', 'घटाएँ'],
      timesWords: ['गुणा', 'गुणे', 'गुणा करो', 'इनटू'],
      divideWords: ['भाग', 'बटा', 'भाग दो', 'डिवाइड'],
      percentWords: ['प्रतिशत', 'फीसदी'],
      percentOfWords: ['प्रतिशत', 'का प्रतिशत'],
      sqrtWords: ['वर्गमूल', 'वर्ग मूल', 'रूट'],
      squaredWords: ['वर्ग', 'स्क्वायर'],
      cubedWords: ['घन'],
      factorialWords: ['फैक्टोरियल'],
      pointWords: ['दशमलव', 'पॉइंट'],
      equalsWords: ['बराबर', 'कितना', 'होता है'],
      piWords: ['पाई'],
      andWords: ['और'],
      fillers: ['क्या', 'कितना', 'गणना', 'करो', 'बताओ', 'परिणाम', 'कृपया'],
    ),
    'ta': _Vocabulary(
      plusWords: ['ப்ளஸ்', 'கூட்டல்', 'கூட்டு', 'கூட்ட'],
      addWords: ['கூட்டு', 'கூட்டல்', 'கூட்ட'],
      minusWords: ['மைனஸ்', 'கழித்தல்', 'கழி'],
      timesWords: ['பெருக்கல்', 'பெருக்கு', 'டைம்ஸ்'],
      divideWords: ['வகுத்தல்', 'வகு', 'டிவைட்'],
      percentWords: ['சதவீதம்', 'சதவிகிதம்'],
      percentOfWords: ['சதவீதம்'],
      sqrtWords: ['வர்க்கமூலம்', 'வர்க்க மூலம்', 'ரூட்'],
      squaredWords: ['வர்க்கம்'],
      cubedWords: ['கனம்'],
      factorialWords: ['பாக்டோரியல்'],
      pointWords: ['புள்ளி'],
      equalsWords: ['சமம்', 'எவ்வளவு'],
      piWords: ['பை'],
      andWords: ['மற்றும்'],
      fillers: ['என்ன', 'கணக்கிடு', 'சொல்', 'முடிவு', 'தயவுசெய்து'],
    ),
    'kn': _Vocabulary(
      plusWords: ['ಪ್ಲಸ್', 'ಕೂಡಿಸು', 'ಸೇರಿಸು', 'ಮೊತ್ತ'],
      addWords: ['ಕೂಡಿಸು', 'ಸೇರಿಸು'],
      minusWords: ['ಮೈನಸ್', 'ಕಳೆ', 'ಕಳೆಯಿರಿ'],
      timesWords: ['ಗುಣಿಸು', 'ಗುಣಾಕಾರ', 'ಟೈಮ್ಸ್'],
      divideWords: ['ಭಾಗಿಸು', 'ಭಾಗಾಕಾರ', 'ಡಿವೈಡ್'],
      percentWords: ['ಶೇಕಡಾ', 'ಪ್ರತಿಶತ'],
      percentOfWords: ['ಶೇಕಡಾ'],
      sqrtWords: ['ವರ್ಗಮೂಲ', 'ರೂಟ್'],
      squaredWords: ['ವರ್ಗ'],
      cubedWords: ['ಘನ'],
      factorialWords: ['ಫ್ಯಾಕ್ಟೋರಿಯಲ್'],
      pointWords: ['ಪಾಯಿಂಟ್', 'ದಶಮಾಂಶ'],
      equalsWords: ['ಸಮ', 'ಎಷ್ಟು'],
      piWords: ['ಪೈ'],
      andWords: ['ಮತ್ತು'],
      fillers: ['ಏನು', 'ಲೆಕ್ಕಿಸು', 'ಹೇಳು', 'ಫಲಿತಾಂಶ', 'ದಯವಿಟ್ಟು'],
    ),
    'ml': _Vocabulary(
      plusWords: ['പ്ലസ്', 'കൂട്ടുക', 'കൂട്ടി', 'സങ്കലനം'],
      addWords: ['കൂട്ടുക', 'കൂട്ടി'],
      minusWords: ['മൈനസ്', 'കുറയ്ക്കുക', 'കുറച്ച്'],
      timesWords: ['ഗുണിക്കുക', 'ഗുണനം', 'ടൈംസ്'],
      divideWords: ['ഹരിക്കുക', 'ഹരണം', 'ഡിവൈഡ്'],
      percentWords: ['ശതമാനം', 'പെർസെന്റ്'],
      percentOfWords: ['ശതമാനം'],
      sqrtWords: ['വർഗ്ഗമൂലം', 'റൂട്ട്'],
      squaredWords: ['വർഗ്ഗം'],
      cubedWords: ['ഘനം'],
      factorialWords: ['ഫാക്ടോറിയൽ'],
      pointWords: ['പോയിന്റ്', 'ദശാംശം'],
      equalsWords: ['തുല്യം', 'എത്ര'],
      piWords: ['പൈ'],
      andWords: ['കൂടാതെ'],
      fillers: ['എന്ത്', 'കണക്കാക്കുക', 'പറയുക', 'ഫലം', 'ദയവായി'],
    ),
    'mr': _Vocabulary(
      plusWords: ['प्लस', 'बेरीज', 'जोडा', 'अधिक'],
      addWords: ['बेरीज', 'जोडा'],
      minusWords: ['वजा', 'माइनस', 'वजाबाकी'],
      timesWords: ['गुणाकार', 'गुणा'],
      divideWords: ['भागाकार', 'भाग', 'भागा'],
      percentWords: ['टक्के', 'टक्केवारी', 'प्रतिशत'],
      percentOfWords: ['टक्के'],
      sqrtWords: ['वर्गमूळ', 'रूट'],
      squaredWords: ['वर्ग'],
      cubedWords: ['घन'],
      factorialWords: ['फॅक्टोरियल'],
      pointWords: ['दशांश', 'पॉइंट'],
      equalsWords: ['बरोबर', 'किती'],
      piWords: ['पाय'],
      andWords: ['आणि'],
      fillers: ['काय', 'गणना', 'करा', 'सांगा', 'निकाल', 'कृपया'],
    ),
    'bn': _Vocabulary(
      plusWords: ['প্লাস', 'যোগ', 'যোগ করুন'],
      addWords: ['যোগ', 'যোগ করুন'],
      minusWords: ['মাইনাস', 'বিয়োগ'],
      timesWords: ['গুণ', 'গুণ করুন', 'টাইমস'],
      divideWords: ['ভাগ', 'ভাগ করুন', 'ডিভাইড'],
      percentWords: ['শতাংশ', 'পার্সেন্ট'],
      percentOfWords: ['শতাংশ'],
      sqrtWords: ['বর্গমূল', 'রুট'],
      squaredWords: ['বর্গ'],
      cubedWords: ['ঘন'],
      factorialWords: ['ফ্যাক্টোরিয়াল'],
      pointWords: ['দশমিক', 'পয়েন্ট'],
      equalsWords: ['সমান', 'কত'],
      piWords: ['পাই'],
      andWords: ['এবং'],
      fillers: ['কি', 'হিসাব', 'করুন', 'বলুন', 'ফলাফল', 'দয়া করে'],
    ),
    'gu': _Vocabulary(
      plusWords: ['પ્લસ', 'સરવાળો', 'ઉમેરો', 'વત્તા'],
      addWords: ['સરવાળો', 'ઉમેરો'],
      minusWords: ['માઈનસ', 'બાદબાકી', 'બાદ'],
      timesWords: ['ગુણાકાર', 'ગુણો', 'ટાઈમ્સ'],
      divideWords: ['ભાગાકાર', 'ભાગો', 'ડિવાઇડ'],
      percentWords: ['ટકા', 'ટકાવારી', 'પ્રતિશત'],
      percentOfWords: ['ટકા'],
      sqrtWords: ['વર્ગમૂળ', 'રૂટ'],
      squaredWords: ['વર્ગ'],
      cubedWords: ['ઘન'],
      factorialWords: ['ફેક્ટોરિયલ'],
      pointWords: ['દશાંશ', 'પોઈન્ટ'],
      equalsWords: ['બરાબર', 'કેટલું'],
      piWords: ['પાઈ'],
      andWords: ['અને'],
      fillers: ['શું', 'ગણતરી', 'કરો', 'કહો', 'પરિણામ', 'કૃપા કરીને'],
    ),
    'pa': _Vocabulary(
      plusWords: ['ਪਲੱਸ', 'ਜੋੜ', 'ਜੋੜੋ'],
      addWords: ['ਜੋੜ', 'ਜੋੜੋ'],
      minusWords: ['ਮਾਈਨਸ', 'ਘਟਾਓ', 'ਘਟਾ'],
      timesWords: ['ਗੁਣਾ', 'ਗੁਣਾ ਕਰੋ', 'ਟਾਈਮਜ਼'],
      divideWords: ['ਭਾਗ', 'ਭਾਗ ਕਰੋ', 'ਡਿਵਾਈਡ'],
      percentWords: ['ਪ੍ਰਤੀਸ਼ਤ', 'ਫੀਸਦੀ'],
      percentOfWords: ['ਪ੍ਰਤੀਸ਼ਤ'],
      sqrtWords: ['ਵਰਗਮੂਲ', 'ਰੂਟ'],
      squaredWords: ['ਵਰਗ'],
      cubedWords: ['ਘਣ'],
      factorialWords: ['ਫੈਕਟੋਰੀਅਲ'],
      pointWords: ['ਦਸ਼ਮਲਵ', 'ਪੁਆਇੰਟ'],
      equalsWords: ['ਬਰਾਬਰ', 'ਕਿੰਨਾ'],
      piWords: ['ਪਾਈ'],
      andWords: ['ਅਤੇ'],
      fillers: ['ਕੀ', 'ਗਣਨਾ', 'ਕਰੋ', 'ਦੱਸੋ', 'ਨਤੀਜਾ', 'ਕਿਰਪਾ ਕਰਕੇ'],
    ),
  };

  static const Map<VoiceCommandType, List<String>> _commandWords = {
    VoiceCommandType.clear: [
      'clear calculator', 'clear all', 'clear the calculator', 'reset calculator',
      'క్లియర్', 'సాఫ్ చెయ్యి', 'शून्य करो', 'साफ करो', 'साफ़ करो',
      'அழி', 'ತೆರವು', 'മായ്ക്കുക', 'সব মুছুন', 'સાફ કરો', 'ਸਾਫ਼ ਕਰੋ',
    ],
    VoiceCommandType.deleteLast: [
      'delete last number', 'delete last digit', 'backspace', 'remove last digit',
      'చివరి అంకె తొలగించు', 'आखिरी अंक हटाओ', 'काढून टाका', 'கடைசி இலக்கத்தை நீக்கு',
    ],
    VoiceCommandType.repeatAnswer: [
      'repeat answer', 'repeat the answer', 'say again', 'speak again',
      'మళ్లీ చెప్పు', 'दोहराओ', 'फिर से बोलो', 'மீண்டும் சொல்', 'ಮತ್ತೆ ಹೇಳು',
      'വീണ്ടും പറയുക', 'पुन्हा सांगा', 'আবার বলুন', 'ફરી બોલો', 'ਦੁਬਾਰਾ ਬੋਲੋ',
    ],
    VoiceCommandType.showHistory: [
      'show history', 'open history', 'calculation history',
      'చరిత్ర చూపించు', 'इतिहास दिखाओ', 'வரலாறு காட்டு', 'ಇತಿಹಾಸ ತೋರಿಸು',
      'ചരിത്രം കാണിക്കുക', 'इतिहास दाखवा', 'ইতিহাস দেখান', 'ઇતિહાસ બતાવો',
    ],
    VoiceCommandType.openScientific: [
      'scientific calculator', 'switch to scientific', 'open scientific',
      'సైంటిఫిక్ కాలిక్యులేటర్', 'वैज्ञानिक कैलकुलेटर', 'அறிவியல் கணிப்பான்',
      'ವೈಜ್ಞಾನಿಕ ಕ್ಯಾಲ್ಕುಲೇಟರ್', 'ശാസ്ത്രീയ കാൽക്കുലേറ്റർ',
    ],
  };

  static const List<List<String>> _speakWords = [
    ['read', 'speak', 'say', 'voice'],
    ['చెప్పు', 'చదువు', 'వినిపించు'],
    ['बोलो', 'सुनाओ', 'पढ़ो'],
    ['பேசு', 'சொல்'],
    ['ಹೇಳು', 'ಓದು'],
    ['പറയുക', 'വായിക്കുക'],
    ['बोला', 'वाचा'],
    ['বলুন', 'পড়ুন'],
    ['બોલો', 'વાંચો'],
    ['ਬੋਲੋ', 'ਪੜ੍ਹੋ'],
  ];
}

class _Vocabulary {
  const _Vocabulary({
    required this.plusWords,
    required this.addWords,
    required this.minusWords,
    required this.timesWords,
    required this.divideWords,
    required this.percentWords,
    required this.percentOfWords,
    required this.sqrtWords,
    required this.squaredWords,
    required this.cubedWords,
    required this.factorialWords,
    required this.pointWords,
    required this.equalsWords,
    required this.piWords,
    required this.andWords,
    required this.fillers,
  });

  final List<String> plusWords;
  final List<String> addWords;
  final List<String> minusWords;
  final List<String> timesWords;
  final List<String> divideWords;
  final List<String> percentWords;
  final List<String> percentOfWords;
  final List<String> sqrtWords;
  final List<String> squaredWords;
  final List<String> cubedWords;
  final List<String> factorialWords;
  final List<String> pointWords;
  final List<String> equalsWords;
  final List<String> piWords;
  final List<String> andWords;
  final List<String> fillers;

  List<String> get allWords => [
        ...plusWords,
        ...addWords,
        ...minusWords,
        ...timesWords,
        ...divideWords,
        ...percentWords,
        ...percentOfWords,
        ...sqrtWords,
        ...squaredWords,
        ...cubedWords,
        ...factorialWords,
        ...pointWords,
        ...equalsWords,
        ...piWords,
        ...andWords,
      ];
}

class _Rule {
  const _Rule(this.phrase, this.replacement);

  final String phrase;
  final String replacement;
}
