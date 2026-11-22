/// A single saved calculation.
class CalculationRecord {
  const CalculationRecord({
    required this.id,
    required this.expression,
    required this.result,
    required this.type,
    required this.languageCode,
    required this.createdAt,
    this.value,
    this.favorite = false,
  });

  final String id;
  final String expression;
  final String result;
  final double? value;
  final String type;
  final String languageCode;
  final DateTime createdAt;
  final bool favorite;

  CalculationRecord copyWith({bool? favorite}) {
    return CalculationRecord(
      id: id,
      expression: expression,
      result: result,
      value: value,
      type: type,
      languageCode: languageCode,
      createdAt: createdAt,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'expression': expression,
        'result': result,
        'value': value,
        'type': type,
        'languageCode': languageCode,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'favorite': favorite,
      };

  static CalculationRecord? fromMap(Map<dynamic, dynamic> map) {
    final id = map['id'];
    final expression = map['expression'];
    final result = map['result'];
    final createdAt = map['createdAt'];
    if (id is! String || expression is! String || result is! String) {
      return null;
    }
    return CalculationRecord(
      id: id,
      expression: expression,
      result: result,
      value: (map['value'] as num?)?.toDouble(),
      type: map['type'] as String? ?? CalculationType.standard,
      languageCode: map['languageCode'] as String? ?? 'en',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAt is int ? createdAt : DateTime.now().millisecondsSinceEpoch,
      ),
      favorite: map['favorite'] as bool? ?? false,
    );
  }
}

/// Calculation types shown in history filters and analytics.
class CalculationType {
  const CalculationType._();

  static const String standard = 'standard';
  static const String scientific = 'scientific';
  static const String voice = 'voice';
  static const String words = 'words';
  static const String gst = 'gst';
  static const String tool = 'tool';
  static const String converter = 'converter';
}
