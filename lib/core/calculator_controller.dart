import 'package:flutter/foundation.dart';

import 'calculator_engine.dart';

class CalculationEntry {
  const CalculationEntry({
    required this.expression,
    required this.result,
    required this.createdAt,
  });

  final String expression;
  final String result;
  final DateTime createdAt;
}

/// Owns all input behavior, and does not depend on presentation widgets.
class CalculatorController extends ChangeNotifier {
  CalculatorController({CalculatorEngine? engine})
      : _engine = engine ?? const CalculatorEngine();

  final CalculatorEngine _engine;
  final List<CalculationEntry> _history = <CalculationEntry>[];
  String _expression = '0';
  String _preview = '';
  String? _error;
  bool _justEvaluated = false;

  String get expression => _expression;
  String get preview => _preview;
  String? get error => _error;
  List<CalculationEntry> get history => List.unmodifiable(_history);
  bool get justEvaluated => _justEvaluated;

  void press(String key) {
    _error = null;
    switch (key) {
      case 'AC':
        _expression = '0';
        _preview = '';
        _justEvaluated = false;
        notifyListeners();
        return;
      case '⌫':
        _backspace();
        break;
      case '=':
        _calculate();
        return;
      case '±':
        _toggleSign();
        break;
      case '%':
        _percent();
        break;
      case '(':
        _openParenthesis();
        break;
      case ')':
        _closeParenthesis();
        break;
      case '.':
        _decimal();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _operator(key);
        break;
      default:
        if (RegExp(r'^\d$').hasMatch(key)) _digit(key);
    }
    _recalculatePreview();
    notifyListeners();
  }

  void restore(CalculationEntry entry) {
    _expression = entry.expression;
    _justEvaluated = false;
    _error = null;
    _recalculatePreview();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  bool get _endsInValue =>
      _expression.isNotEmpty &&
      RegExp(r'[0-9)%]$').hasMatch(_expression);

  void _digit(String digit) {
    if (_justEvaluated) {
      _expression = digit;
      _justEvaluated = false;
    } else if (_expression == '0') {
      _expression = digit;
    } else if (_expression.endsWith(')') || _expression.endsWith('%')) {
      _expression += '×$digit';
    } else {
      _expression += digit;
    }
  }

  void _decimal() {
    if (_justEvaluated) {
      _expression = '0.';
      _justEvaluated = false;
      return;
    }
    if (_expression.endsWith(')') || _expression.endsWith('%')) {
      _expression += '×0.';
      return;
    }
    final lastNumber = RegExp(r'(\d+(?:\.\d*)?|\.\d*)$')
        .firstMatch(_expression)?.group(0);
    if (lastNumber?.contains('.') == true) return;
    if (_expression == '0') {
      _expression = '0.';
    } else if (!_endsInValue) {
      _expression += '0.';
    } else {
      _expression += '.';
    }
  }

  void _operator(String op) {
    _justEvaluated = false;
    if (_expression == '0' && op == '-') {
      _expression = '-';
      return;
    }
    if (_endsInValue) {
      _expression += op;
    } else if (_expression.isNotEmpty &&
        '+-×÷'.contains(_expression[_expression.length - 1])) {
      // Replace the previous operator, except after an opening minus.
      if (_expression == '-') return;
      _expression = _expression.substring(0, _expression.length - 1) + op;
    }
  }

  void _openParenthesis() {
    if (_justEvaluated) {
      _expression = '(';
      _justEvaluated = false;
    } else if (_expression == '0') {
      _expression = '(';
    } else if (_endsInValue) {
      _expression += '×(';
    } else {
      _expression += '(';
    }
  }

  void _closeParenthesis() {
    final opens = '('.allMatches(_expression).length;
    final closes = ')'.allMatches(_expression).length;
    if (opens > closes && _endsInValue) _expression += ')';
    _justEvaluated = false;
  }

  void _percent() {
    if (_endsInValue && !_expression.endsWith('%')) _expression += '%';
    _justEvaluated = false;
  }

  void _toggleSign() {
    if (_expression == '0') return;
    _justEvaluated = false;
    final negative = RegExp(r'\(-((?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)\)(%)?$')
        .firstMatch(_expression);
    if (negative != null) {
      _expression = _expression.substring(0, negative.start) +
          negative.group(1)! + (negative.group(2) ?? '');
      return;
    }
    final match = RegExp(r'((?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)(%)?$')
        .firstMatch(_expression);
    if (match != null) {
      _expression = _expression.substring(0, match.start) +
          '(-${match.group(1)!})${match.group(2) ?? ''}';
    }
  }

  void _backspace() {
    _justEvaluated = false;
    if (_expression.length <= 1) {
      _expression = '0';
    } else {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_expression.isEmpty || _expression == '-') _expression = '0';
    }
  }

  void _calculate() {
    try {
      final value = _engine.evaluate(_expression);
      final result = _engine.format(value);
      _history.insert(0, CalculationEntry(
        expression: _expression,
        result: result,
        createdAt: DateTime.now(),
      ));
      if (_history.length > 30) _history.removeLast();
      _expression = result;
      _preview = '';
      _justEvaluated = true;
    } on CalculatorException catch (e) {
      _error = e.message;
      _preview = '';
    } catch (_) {
      _error = 'Invalid expression';
      _preview = '';
    }
    notifyListeners();
  }

  void _recalculatePreview() {
    _preview = '';
    try {
      // Avoid showing a redundant preview before the user starts typing.
      if (_expression == '0' || _expression == '-') return;
      _preview = _engine.format(_engine.evaluate(_expression));
    } on CalculatorException {
      // A partially entered expression is normal; wait for more input.
    } catch (_) {
      // Keep the interface responsive while the expression is incomplete.
    }
  }
}
