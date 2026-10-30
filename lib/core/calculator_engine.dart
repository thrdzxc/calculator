/// A dependency-free calculator parser that respects operator precedence.
/// Supported tokens: 0–9, decimal point, +, -, ×, ÷, (, ), and postfix %.
class CalculatorException implements Exception {
  const CalculatorException(this.message);
  final String message;

  @override
  String toString() => message;
}

class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(String expression) {
    if (expression.trim().isEmpty) {
      throw const CalculatorException('Enter a calculation');
    }
    final parser = _ExpressionParser(expression.replaceAll(' ', ''));
    final result = parser.parse();
    if (!result.isFinite) {
      throw const CalculatorException('Result is too large');
    }
    return result == 0 ? 0.0 : result; // Prevent a visible negative zero.
  }

  String format(double value) {
    if (!value.isFinite) {
      throw const CalculatorException('Invalid result');
    }
    if (value == 0) return '0';

    final magnitude = value.abs();
    if (magnitude >= 1e12 || magnitude < 1e-7) {
      final raw = value.toStringAsPrecision(10);
      final parts = raw.split('e');
      final mantissa = parts.first.contains('.')
          ? parts.first.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
          : parts.first;
      return parts.length == 2 ? '${mantissa}e${parts[1]}' : mantissa;
    }

    final raw = value.toStringAsFixed(9);
    return raw.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _ExpressionParser {
  _ExpressionParser(this.source);

  final String source;
  int _index = 0;

  double parse() {
    final result = _expression();
    if (_index != source.length) {
      throw const CalculatorException('Invalid expression');
    }
    return result;
  }

  double _expression() {
    var left = _term();
    while (true) {
      if (_consume('+')) {
        left += _term();
      } else if (_consume('-') || _consume('−')) {
        left -= _term();
      } else {
        return _check(left);
      }
    }
  }

  double _term() {
    var left = _unary();
    while (true) {
      if (_consume('×') || _consume('*')) {
        left *= _unary();
      } else if (_consume('÷') || _consume('/')) {
        final divisor = _unary();
        if (divisor == 0) {
          throw const CalculatorException('Cannot divide by zero');
        }
        left /= divisor;
      } else {
        return _check(left);
      }
    }
  }

  double _unary() {
    if (_consume('+')) return _unary();
    if (_consume('-') || _consume('−')) return -_unary();
    return _postfix();
  }

  double _postfix() {
    var result = _primary();
    while (_consume('%')) {
      result /= 100;
    }
    return _check(result);
  }

  double _primary() {
    if (_consume('(')) {
      final result = _expression();
      if (!_consume(')')) {
        throw const CalculatorException('Missing closing parenthesis');
      }
      return result;
    }
    return _number();
  }

  double _number() {
    final start = _index;
    var hasDigit = false;
    while (_index < source.length && _digit(source[_index])) {
      _index++;
      hasDigit = true;
    }
    if (_consume('.')) {
      while (_index < source.length && _digit(source[_index])) {
        _index++;
        hasDigit = true;
      }
    }
    if (!hasDigit) {
      throw const CalculatorException('Incomplete expression');
    }

    // Scientific notation is useful when a very small or large result is reused.
    if (_index < source.length &&
        (source[_index] == 'e' || source[_index] == 'E')) {
      final exponentStart = _index;
      _index++;
      if (_index < source.length &&
          (source[_index] == '+' || source[_index] == '-')) {
        _index++;
      }
      final digitsStart = _index;
      while (_index < source.length && _digit(source[_index])) {
        _index++;
      }
      if (_index == digitsStart) _index = exponentStart;
    }

    final result = double.tryParse(source.substring(start, _index));
    if (result == null) {
      throw const CalculatorException('Invalid number');
    }
    return _check(result);
  }

  bool _consume(String token) {
    if (source.startsWith(token, _index)) {
      _index += token.length;
      return true;
    }
    return false;
  }

  bool _digit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

  double _check(double value) {
    if (!value.isFinite) {
      throw const CalculatorException('Result is too large');
    }
    return value;
  }
}
