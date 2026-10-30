import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_glass_calculator/core/calculator_controller.dart';

void main() {
  late CalculatorController calculator;

  setUp(() => calculator = CalculatorController());
  tearDown(() => calculator.dispose());

  void input(String keys) {
    for (final key in keys.split('')) {
      calculator.press(key);
    }
  }

  test('initial state shows zero', () {
    expect(calculator.expression, '0');
    expect(calculator.history, isEmpty);
  });

  test('calculates expressions with correct precedence', () {
    input('7+3×2');
    calculator.press('=');
    expect(calculator.expression, '13');
    expect(calculator.history.single.expression, '7+3×2');
    expect(calculator.history.single.result, '13');
  });

  test('calculating new digits starts a fresh expression', () {
    input('2+3');
    calculator.press('=');
    calculator.press('7');
    expect(calculator.expression, '7');
  });

  test('operator after equals continues using result', () {
    input('2+3');
    calculator.press('=');
    calculator.press('×');
    calculator.press('4');
    calculator.press('=');
    expect(calculator.expression, '20');
  });

  test('backspace and all clear work', () {
    input('456');
    calculator.press('⌫');
    expect(calculator.expression, '45');
    calculator.press('AC');
    expect(calculator.expression, '0');
  });

  test('operators are replaced if two tapped in sequence', () {
    input('9+');
    calculator.press('×');
    expect(calculator.expression, '9×');
  });

  test('decimal button does not create two points in one number', () {
    input('3.');
    calculator.press('.');
    calculator.press('5');
    expect(calculator.expression, '3.5');
  });

  test('change sign toggles back to positive', () {
    calculator.press('4');
    calculator.press('±');
    expect(calculator.expression, '(-4)');
    calculator.press('±');
    expect(calculator.expression, '4');
  });

  test('percentage works with multiplication', () {
    input('200×10');
    calculator.press('%');
    calculator.press('=');
    expect(calculator.expression, '20');
  });

  test('invalid division shows a safe error', () {
    input('1÷0');
    calculator.press('=');
    expect(calculator.error, 'Cannot divide by zero');
    calculator.press('AC');
    expect(calculator.error, isNull);
    expect(calculator.expression, '0');
  });

  test('restoring history and clearing history work', () {
    input('4+6');
    calculator.press('=');
    final first = calculator.history.single;
    calculator.press('AC');
    calculator.restore(first);
    expect(calculator.expression, '4+6');
    calculator.clearHistory();
    expect(calculator.history, isEmpty);
  });
}
