import '../../../core/utils/result_formatter.dart';

/// Outcome of evaluating a mathematical expression.
class EvaluationResult {
  const EvaluationResult.success(this.value)
      : errorCode = null,
        detail = null;

  const EvaluationResult.failure(this.errorCode, {this.detail}) : value = null;

  final double? value;
  final String? errorCode;
  final String? detail;

  bool get isSuccess => errorCode == null && value != null;

  /// Human readable number, already free of floating point noise.
  String get display => isSuccess ? ResultFormatter.format(value!) : '';
}
