import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/utils/result_formatter.dart';
import '../../history/domain/calculation_record.dart';
import '../domain/calculator_error.dart';
import '../domain/evaluation_result.dart';

/// Immutable state of the calculator keypad.
class CalculatorState {
  const CalculatorState({
    this.expression = '',
    this.result = '',
    this.preview = '',
    this.errorCode,
    this.value,
    this.memory = 0,
    this.memorySet = false,
    this.evaluated = false,
    this.type = CalculationType.standard,
  });

  final String expression;
  final String result;
  final String preview;
  final String? errorCode;
  final double? value;
  final double memory;
  final bool memorySet;
  final bool evaluated;
  final String type;

  CalculatorState copyWith({
    String? expression,
    String? result,
    String? preview,
    String? errorCode,
    double? value,
    double? memory,
    bool? memorySet,
    bool? evaluated,
    String? type,
    bool clearError = false,
    bool clearValue = false,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      preview: preview ?? this.preview,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      value: clearValue ? null : (value ?? this.value),
      memory: memory ?? this.memory,
      memorySet: memorySet ?? this.memorySet,
      evaluated: evaluated ?? this.evaluated,
      type: type ?? this.type,
    );
  }
}

/// MVVM controller for the standard and scientific keypads.
class CalculatorController extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  static const Set<String> _operators = {'+', '-', '*', '/', '^'};

  void setType(String type) {
    if (state.type == type) return;
    state = state.copyWith(type: type);
  }

  void press(String key) {
    switch (key) {
      case 'AC':
        clear();
        return;
      case 'back':
        backspace();
        return;
      case '=':
        evaluate();
        return;
      case '+/-':
        toggleSign();
        return;
      case 'mc':
        state = state.copyWith(memory: 0, memorySet: false);
        return;
      case 'mr':
        if (!state.memorySet) return;
        _appendToken(ResultFormatter.format(state.memory));
        return;
      case 'm+':
        _memoryAdd(1);
        return;
      case 'm-':
        _memoryAdd(-1);
        return;
      case 'reciprocal':
        _wrapReciprocal();
        return;
      case 'square':
        _appendPostfix('^2');
        return;
      case 'cube':
        _appendPostfix('^3');
        return;
      default:
        _appendToken(key);
    }
  }

  void _memoryAdd(int sign) {
    final current = state.evaluated && state.value != null
        ? state.value!
        : double.tryParse(state.preview);
    if (current == null) return;
    state = state.copyWith(
      memory: state.memory + sign * current,
      memorySet: true,
    );
  }

  void _wrapReciprocal() {
    if (state.expression.isEmpty) {
      state = state.copyWith(expression: '1/', preview: '');
      return;
    }
    final expression = '1/(${state.expression})';
    state = state.copyWith(expression: expression, preview: '');
    _refreshPreview();
  }

  void _appendPostfix(String suffix) {
    if (state.expression.isEmpty) return;
    if (state.evaluated) {
      state = state.copyWith(
        expression: '${state.result}$suffix',
        evaluated: false,
        clearError: true,
      );
      _refreshPreview();
      return;
    }
    final last = state.expression[state.expression.length - 1];
    if (_operators.contains(last) || last == '(') return;
    state = state.copyWith(expression: '${state.expression}$suffix');
    _refreshPreview();
  }

  void _appendToken(String token) {
    if (state.evaluated) {
      final continues =
          _operators.contains(token) ||
          token == ')' ||
          token == '!' ||
          token == '%' ||
          token == '^2' ||
          token == '^3';
      if (continues) {
        state = state.copyWith(
          expression: state.result,
          evaluated: false,
          clearError: true,
          clearValue: true,
        );
      } else {
        state = const CalculatorState(memory: 0).copyWith(
          memory: state.memory,
          memorySet: state.memorySet,
          type: state.type,
        );
      }
    }
    final next = _smartAppend(state.expression, token);
    if (next == state.expression) return;
    state = state.copyWith(expression: next, clearError: true);
    _refreshPreview();
  }

  String _smartAppend(String expression, String token) {
    final last = expression.isEmpty ? '' : expression[expression.length - 1];
    final endsWithOperator = _operators.contains(last);
    final endsWithValue =
        last.isNotEmpty &&
        (RegExp(r'[0-9)!%]').hasMatch(last) ||
            expression.endsWith('pi') ||
            expression.endsWith('e'));

    if (token == '.') {
      final match = RegExp(r'(\d+\.?\d*)$').firstMatch(expression);
      if (match != null && match.group(1)!.contains('.')) return expression;
      if (last.isEmpty || endsWithOperator || last == '(') {
        return '${expression}0.';
      }
      return '$expression.';
    }

    if (RegExp(r'^\d$').hasMatch(token)) {
      if (last == ')' ||
          last == '!' ||
          last == '%' ||
          expression.endsWith('pi')) {
        return '$expression*$token';
      }
      return '$expression$token';
    }

    if (_operators.contains(token)) {
      if (expression.isEmpty) return token == '-' ? '-' : expression;
      if (last == '(') return token == '-' ? '$expression-' : expression;
      if (endsWithOperator) {
        if (token == '-' && (last == '*' || last == '/' || last == '^')) {
          return '$expression-';
        }
        if (last == '-') return expression;
        return '${expression.substring(0, expression.length - 1)}$token';
      }
      return '$expression$token';
    }

    if (token == '(') {
      if (endsWithValue) return '$expression*(';
      return '$expression(';
    }

    if (token == ')') {
      if (_openBrackets(expression) <= _closedBrackets(expression)) {
        return expression;
      }
      if (endsWithOperator || last == '(') return expression;
      return '$expression)';
    }

    if (token == '!' || token == '%') {
      if (expression.isEmpty || endsWithOperator || last == '(') {
        return expression;
      }
      if (last == '!' || last == '%') return expression;
      return '$expression$token';
    }

    if (token == 'pi' || token == 'e') {
      if (endsWithValue) return '$expression*$token';
      return '$expression$token';
    }

    if (token.endsWith('(')) {
      if (endsWithValue) return '$expression*$token';
      return '$expression$token';
    }

    return '$expression$token';
  }

  int _openBrackets(String value) => '('.allMatches(value).length;

  int _closedBrackets(String value) => ')'.allMatches(value).length;

  void toggleSign() {
    final expression = state.expression;
    if (expression.isEmpty) {
      state = state.copyWith(expression: '-', preview: '');
      return;
    }
    final match = RegExp(r'(\d+\.?\d*)$').firstMatch(expression);
    if (match == null) {
      if (expression.startsWith('-(') && expression.endsWith(')')) {
        state = state.copyWith(
          expression: expression.substring(2, expression.length - 1),
        );
        _refreshPreview();
        return;
      }
      state = state.copyWith(expression: '-($expression)');
      _refreshPreview();
      return;
    }
    final start = match.start;
    final before = start == 0 ? '' : expression[start - 1];
    if (before == '-' &&
        (start - 1 == 0 ||
            _operators.contains(expression[start - 2]) ||
            expression[start - 2] == '(')) {
      final next = expression.replaceRange(start - 1, start, '');
      state = state.copyWith(expression: next);
    } else {
      final next = expression.replaceRange(start, start, '-');
      state = state.copyWith(expression: next);
    }
    _refreshPreview();
  }

  void backspace() {
    if (state.expression.isEmpty) return;
    var expression = state.expression;
    final functionSuffix = RegExp(r'(sqrt\(|mod)$');
    final match = functionSuffix.firstMatch(expression);
    expression = match != null
        ? expression.substring(0, expression.length - match.group(0)!.length)
        : expression.substring(0, expression.length - 1);
    state = state.copyWith(
      expression: expression,
      evaluated: false,
      result: '',
      clearError: true,
      clearValue: true,
    );
    _refreshPreview();
  }

  void clear() {
    state = CalculatorState(
      memory: state.memory,
      memorySet: state.memorySet,
      type: state.type,
    );
  }

  void loadExpression(String expression, {bool evaluateImmediately = false}) {
    state = state.copyWith(
      expression: expression,
      evaluated: false,
      result: '',
      clearError: true,
      clearValue: true,
    );
    _refreshPreview();
    if (evaluateImmediately) evaluate();
  }

  void evaluate() {
    if (state.expression.trim().isEmpty) {
      state = state.copyWith(errorCode: CalcError.empty, result: '');
      return;
    }
    final outcome = _evaluate(state.expression);
    if (!outcome.isSuccess) {
      state = state.copyWith(
        errorCode: outcome.errorCode,
        result: '',
        evaluated: false,
        clearValue: true,
      );
      return;
    }
    state = state.copyWith(
      result: outcome.display,
      preview: outcome.display,
      value: outcome.value,
      evaluated: true,
      clearError: true,
    );
    _saveHistory(outcome);
  }

  void _saveHistory(EvaluationResult outcome) {
    final settings = ref.read(settingsControllerProvider);
    ref
        .read(historyControllerProvider.notifier)
        .add(
          expression: state.expression,
          result: outcome.display,
          value: outcome.value,
          type: state.type,
          languageCode: settings.language.code,
        );
  }

  void _refreshPreview() {
    final expression = state.expression;
    if (expression.isEmpty) {
      state = state.copyWith(preview: '');
      return;
    }
    final outcome = _evaluate(expression);
    state = state.copyWith(
      preview: outcome.isSuccess ? outcome.display : '',
      clearError: true,
    );
  }

  EvaluationResult _evaluate(String expression) {
    return ref.read(expressionEngineProvider).evaluate(expression);
  }
}

final calculatorControllerProvider =
    NotifierProvider<CalculatorController, CalculatorState>(
      CalculatorController.new,
    );
