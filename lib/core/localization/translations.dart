import 'translations/bn_gu_pa.dart';
import 'translations/en.dart';
import 'translations/hi.dart';
import 'translations/kn.dart';
import 'translations/mr.dart';
import 'translations/ml.dart';
import 'translations/ta.dart';
import 'translations/te.dart';

/// All translation tables keyed by language code.
const Map<String, Map<String, String>> kTranslations = <String, Map<String, String>>{
  'en': enStrings,
  'te': teStrings,
  'hi': hiStrings,
  'ta': taStrings,
  'kn': knStrings,
  'ml': mlStrings,
  'mr': mrStrings,
  'bn': bnStrings,
  'gu': guStrings,
  'pa': paStrings,
};
