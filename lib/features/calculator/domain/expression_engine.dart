import 'dart:math' as math;

import 'calculator_error.dart';
import 'evaluation_result.dart';

/// A safe, dependency-free mathematical expression parser and evaluator.
///
/// Supports `+ - * /`, modulus (`mod`), exponentiation (`^`), unary signs,
/// parentheses, postfix factorial (`!`) and percentage (`%`), constants
/// (`pi`, `e`) and single-argument functions such as `sqrt`.
class ExpressionEngine {
  const ExpressionEngine();

  /// Evaluates [input] and never throws: failures are returned as a result.
  EvaluationResult evaluate(String input) {
    final normalized = _normalize(input);
    if (normalized.trim().isEmpty) {
      return const EvaluationResult.failure(CalcError.empty);
    }
    try {
      final tokens = _Lexer(normalized).tokenize();
      final ast = _Parser(tokens).parse();
      final value = _Evaluator().evaluate(ast);
      if (value.isNaN) {
        return const EvaluationResult.failure(CalcError.domain);
      }
      if (!value.isFinite) {
        return const EvaluationResult.failure(CalcError.overflow);
      }
      return EvaluationResult.success(value);
    } on _CalcFailure catch (failure) {
      return EvaluationResult.failure(failure.code, detail: failure.detail);
    } catch (error) {
      return EvaluationResult.failure(CalcError.invalid, detail: error.toString());
    }
  }

  /// Returns the numeric value or `null` when the expression is invalid.
  double? tryEvaluate(String input) {
    final result = evaluate(input);
    return result.isSuccess ? result.value : null;
  }

  static const Map<String, String> _unicodeDigits = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '०': '0', '१': '1', '२': '2', '३': '3', '४': '4',
    '५': '5', '६': '6', '७': '7', '८': '8', '९': '9',
    '౦': '0', '౧': '1', '౨': '2', '౩': '3', '౪': '4',
    '౫': '5', '౬': '6', '౭': '7', '౮': '8', '౯': '9',
    '௦': '0', '௧': '1', '௨': '2', '௩': '3', '௪': '4',
    '௫': '5', '௬': '6', '௭': '7', '௮': '8', '௯': '9',
    '೦': '0', '೧': '1', '೨': '2', '೩': '3', '೪': '4',
    '೫': '5', '೬': '6', '೭': '7', '೮': '8', '೯': '9',
    '൦': '0', '൧': '1', '൨': '2', '൩': '3', '൪': '4',
    '൫': '5', '൬': '6', '൭': '7', '൮': '8', '൯': '9',
    '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4',
    '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9',
    '૦': '0', '૧': '1', '૨': '2', '૩': '3', '૪': '4',
    '૫': '5', '૬': '6', '૭': '7', '૮': '8', '૯': '9',
    '੦': '0', '੧': '1', '੨': '2', '੩': '3', '੪': '4',
    '੫': '5', '੬': '6', '੭': '7', '੮': '8', '੯': '9',
  };

  static String _normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_unicodeDigits[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll('×', '*')
        .replaceAll('✕', '*')
        .replaceAll('·', '*')
        .replaceAll('÷', '/')
        .replaceAll('∕', '/')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi')
        .replaceAll(',', '')
        .replaceAll(' ', '');
  }
}

class _CalcFailure implements Exception {
  const _CalcFailure(this.code, {this.detail});

  final String code;
  final String? detail;
}

enum _TokenType { number, identifier, operator, lparen, rparen, eof }

class _Token {
  const _Token(this.type, this.text, {this.position = 0});

  final _TokenType type;
  final String text;
  final int position;

  @override
  String toString() => '$_TokenType($text)';
}

class _Lexer {
  _Lexer(this.source);

  final String source;
  int _index = 0;

  List<_Token> tokenize() {
    final tokens = <_Token>[];
    while (_index < source.length) {
      final char = source[_index];
      if (_isSpace(char)) {
        _index++;
        continue;
      }
      if (_isDigit(char) || char == '.') {
        tokens.add(_readNumber());
        continue;
      }
      if (_isLetter(char)) {
        tokens.add(_readIdentifier());
        continue;
      }
      switch (char) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '^':
        case '!':
        case '%':
          tokens.add(_Token(_TokenType.operator, char, position: _index));
          _index++;
          break;
        case '(':
          tokens.add(_Token(_TokenType.lparen, char, position: _index));
          _index++;
          break;
        case ')':
          tokens.add(_Token(_TokenType.rparen, char, position: _index));
          _index++;
          break;
        default:
          throw _CalcFailure(CalcError.invalid, detail: 'Unexpected "$char"');
      }
    }
    tokens.add(const _Token(_TokenType.eof, ''));
    return tokens;
  }

  _Token _readNumber() {
    final start = _index;
    var seenDot = false;
    while (_index < source.length) {
      final char = source[_index];
      if (_isDigit(char)) {
        _index++;
      } else if (char == '.' && !seenDot) {
        seenDot = true;
        _index++;
      } else {
        break;
      }
    }
    final text = source.substring(start, _index);
    if (text == '.' || double.tryParse(text) == null) {
      throw _CalcFailure(CalcError.invalid, detail: 'Invalid number "$text"');
    }
    return _Token(_TokenType.number, text, position: start);
  }

  _Token _readIdentifier() {
    final start = _index;
    while (_index < source.length && _isLetter(source[_index])) {
      _index++;
    }
    return _Token(
      _TokenType.identifier,
      source.substring(start, _index).toLowerCase(),
      position: start,
    );
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  static bool _isLetter(String char) => RegExp(r'[a-zA-Zπ]').hasMatch(char);

  static bool _isSpace(String char) =>
      char == ' ' || char == '\t' || char == '\n';
}

sealed class _Expr {
  const _Expr();
}

class _NumberExpr extends _Expr {
  const _NumberExpr(this.value);
  final double value;
}

class _ConstantExpr extends _Expr {
  const _ConstantExpr(this.name, this.value);
  final String name;
  final double value;
}

class _UnaryExpr extends _Expr {
  const _UnaryExpr(this.operator, this.operand);
  final String operator;
  final _Expr operand;
}

class _BinaryExpr extends _Expr {
  const _BinaryExpr(this.operator, this.left, this.right);
  final String operator;
  final _Expr left;
  final _Expr right;
}

class _PercentExpr extends _Expr {
  const _PercentExpr(this.operand);
  final _Expr operand;
}

class _FactorialExpr extends _Expr {
  const _FactorialExpr(this.operand);
  final _Expr operand;
}

class _FunctionExpr extends _Expr {
  const _FunctionExpr(this.name, this.argument);
  final String name;
  final _Expr argument;
}

class _Parser {
  _Parser(this.tokens);

  final List<_Token> tokens;
  int _index = 0;

  static const Map<String, double> _constants = {
    'pi': math.pi,
    'e': math.e,
  };

  static const Set<String> _functions = {
    'sqrt', 'cbrt', 'abs', 'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
    'log', 'ln', 'exp', 'round', 'floor', 'ceil', 'fact',
  };

  _Expr parse() {
    final expression = _parseAdditive();
    if (!_check(_TokenType.eof)) {
      throw _CalcFailure(
        CalcError.invalid,
        detail: 'Unexpected "${_peek.text}"',
      );
    }
    return expression;
  }

  _Expr _parseAdditive() {
    var left = _parseMultiplicative();
    while (_checkOperator('+') || _checkOperator('-')) {
      final operator = _advance().text;
      final right = _parseMultiplicative();
      if (right is _PercentExpr) {
        // Calculator semantics: "200 + 10%" means 200 + 10% of 200.
        final delta = _BinaryExpr(
          '*',
          left,
          _BinaryExpr('/', right.operand, const _NumberExpr(100)),
        );
        left = _BinaryExpr(operator, left, delta);
      } else {
        left = _BinaryExpr(operator, left, right);
      }
    }
    return left;
  }

  _Expr _parseMultiplicative() {
    var left = _parseUnary();
    while (true) {
      if (_checkOperator('*') || _checkOperator('/')) {
        final operator = _advance().text;
        left = _BinaryExpr(operator, left, _parseUnary());
      } else if (_checkIdentifier('mod')) {
        _advance();
        left = _BinaryExpr('mod', left, _parseUnary());
      } else if (_check(_TokenType.lparen) || _check(_TokenType.identifier)) {
        // Implicit multiplication: 2(3+4), 2pi, 3sqrt(9).
        left = _BinaryExpr('*', left, _parseUnary());
      } else {
        break;
      }
    }
    return left;
  }

  _Expr _parseUnary() {
    if (_checkOperator('-')) {
      _advance();
      return _UnaryExpr('-', _parseUnary());
    }
    if (_checkOperator('+')) {
      _advance();
      return _parseUnary();
    }
    return _parsePower();
  }

  _Expr _parsePower() {
    final base = _parsePostfix();
    if (_checkOperator('^')) {
      _advance();
      return _BinaryExpr('^', base, _parseUnary());
    }
    return base;
  }

  _Expr _parsePostfix() {
    var expression = _parsePrimary();
    while (true) {
      if (_checkOperator('!')) {
        _advance();
        expression = _FactorialExpr(expression);
      } else if (_checkOperator('%')) {
        _advance();
        expression = _PercentExpr(expression);
      } else {
        break;
      }
    }
    return expression;
  }

  _Expr _parsePrimary() {
    if (_check(_TokenType.number)) {
      return _NumberExpr(double.parse(_advance().text));
    }
    if (_check(_TokenType.lparen)) {
      _advance();
      final expression = _parseAdditive();
      if (!_check(_TokenType.rparen)) {
        throw const _CalcFailure(CalcError.unbalanced);
      }
      _advance();
      return expression;
    }
    if (_check(_TokenType.identifier)) {
      final token = _advance();
      final name = token.text;
      if (_check(_TokenType.lparen)) {
        if (!_functions.contains(name)) {
          throw _CalcFailure(
            CalcError.invalid,
            detail: 'Unknown function "$name"',
          );
        }
        _advance();
        final argument = _parseAdditive();
        if (!_check(_TokenType.rparen)) {
          throw const _CalcFailure(CalcError.unbalanced);
        }
        _advance();
        return _FunctionExpr(name, argument);
      }
      if (_functions.contains(name)) {
        // Functions may be written without parentheses, e.g. "sqrt 144".
        return _FunctionExpr(name, _parseUnary());
      }
      final constant = _constants[name];
      if (constant == null) {
        throw _CalcFailure(CalcError.invalid, detail: 'Unknown symbol "$name"');
      }
      return _ConstantExpr(name, constant);
    }
    if (_check(_TokenType.rparen)) {
      throw const _CalcFailure(CalcError.unbalanced);
    }
    throw const _CalcFailure(CalcError.invalid);
  }

  _Token _advance() {
    if (_index < tokens.length - 1) _index++;
    return tokens[_index - 1];
  }

  _Token get _peek => tokens[_index];

  bool _check(_TokenType type) => _peek.type == type;

  bool _checkOperator(String operator) =>
      _peek.type == _TokenType.operator && _peek.text == operator;

  bool _checkIdentifier(String name) =>
      _peek.type == _TokenType.identifier && _peek.text == name;
}

class _Evaluator {
  double evaluate(_Expr expression) {
    switch (expression) {
      case _NumberExpr(:final value):
        return value;
      case _ConstantExpr(:final value):
        return value;
      case _UnaryExpr(:final operator, :final operand):
        final value = evaluate(operand);
        return operator == '-' ? -value : value;
      case _PercentExpr(:final operand):
        return evaluate(operand) / 100;
      case _FactorialExpr(:final operand):
        return _factorial(evaluate(operand));
      case _FunctionExpr(:final name, :final argument):
        return _apply(name, evaluate(argument));
      case _BinaryExpr(:final operator, :final left, :final right):
        final a = evaluate(left);
        final b = evaluate(right);
        switch (operator) {
          case '+':
            return _guard(a + b);
          case '-':
            return _guard(a - b);
          case '*':
            return _guard(a * b);
          case '/':
            if (b == 0) throw const _CalcFailure(CalcError.divideByZero);
            return _guard(a / b);
          case 'mod':
            if (b == 0) throw const _CalcFailure(CalcError.divideByZero);
            return _guard(a % b);
          case '^':
            if (a == 0 && b < 0) {
              throw const _CalcFailure(CalcError.divideByZero);
            }
            final result = math.pow(a, b).toDouble();
            if (result.isNaN) throw const _CalcFailure(CalcError.domain);
            return _guard(result);
        }
    }
    throw const _CalcFailure(CalcError.invalid);
  }

  double _guard(double value) {
    if (value.isNaN) throw const _CalcFailure(CalcError.domain);
    if (!value.isFinite) throw const _CalcFailure(CalcError.overflow);
    return value;
  }

  double _factorial(double value) {
    if (value < 0 || value != value.roundToDouble()) {
      throw const _CalcFailure(CalcError.factorial);
    }
    if (value > 170) throw const _CalcFailure(CalcError.overflow);
    var result = 1.0;
    for (var i = 2; i <= value.round(); i++) {
      result *= i;
    }
    return result;
  }

  double _apply(String name, double value) {
    switch (name) {
      case 'sqrt':
        if (value < 0) throw const _CalcFailure(CalcError.domain);
        return math.sqrt(value);
      case 'cbrt':
        return value < 0
            ? -math.pow(-value, 1 / 3).toDouble()
            : math.pow(value, 1 / 3).toDouble();
      case 'abs':
        return value.abs();
      case 'sin':
        return math.sin(value);
      case 'cos':
        return math.cos(value);
      case 'tan':
        return math.tan(value);
      case 'asin':
        if (value < -1 || value > 1) {
          throw const _CalcFailure(CalcError.domain);
        }
        return math.asin(value);
      case 'acos':
        if (value < -1 || value > 1) {
          throw const _CalcFailure(CalcError.domain);
        }
        return math.acos(value);
      case 'atan':
        return math.atan(value);
      case 'log':
        if (value <= 0) throw const _CalcFailure(CalcError.domain);
        return math.log(value) / math.ln10;
      case 'ln':
        if (value <= 0) throw const _CalcFailure(CalcError.domain);
        return math.log(value);
      case 'exp':
        return _guard(math.exp(value));
      case 'round':
        return value.roundToDouble();
      case 'floor':
        return value.floorToDouble();
      case 'ceil':
        return value.ceilToDouble();
      case 'fact':
        return _factorial(value);
      default:
        throw _CalcFailure(CalcError.invalid, detail: 'Unknown function "$name"');
    }
  }
}
