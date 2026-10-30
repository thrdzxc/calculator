import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_glass_calculator/core/calculator_engine.dart';

void main() {
  const engine = CalculatorEngine();

  group('CalculatorEngine', () {
    test('respects multiplication and division precedence', () {
      expect(engine.evaluate('2+3×4'), 14);
      expect(engine.evaluate('20÷5+2'), 6);
      expect(engine.evaluate('7-2×3'), 1);
    });

    test('supports parentheses and unary negatives', () {
      expect(engine.evaluate('(2+3)×4'), 20);
      expect(engine.evaluate('8-(-5)'), 13);
      expect(engine.evaluate('(-12)÷3'), -4);
      expect(engine.evaluate('2×(3+4)'), 14);
    });

    test('supports decimal arithmetic', () {
      expect(engine.evaluate('2.5+0.25'), closeTo(2.75, 1e-10));
      expect(engine.evaluate('.5×8'), 4);
    });

    test('supports percentage as divide by 100', () {
      expect(engine.evaluate('50%'), 0.5);
      expect(engine.evaluate('200×10%'), 20);
    });

    test('supports scientific notation in reusable results', () {
      expect(engine.evaluate('1e-8×2'), closeTo(2e-8, 1e-15));
    });

    test('rejects divide by zero', () {
      expect(
        () => engine.evaluate('8÷0'),
        throwsA(isA<CalculatorException>()),
      );
    });

    test('rejects incomplete and invalid expressions', () {
      expect(() => engine.evaluate('3+'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate('(2+3'), throwsA(isA<CalculatorException>()));
      expect(() => engine.evaluate(''), throwsA(isA<CalculatorException>()));
    });

    test('formats regular values without unnecessary trailing zeros', () {
      expect(engine.format(3), '3');
      expect(engine.format(2.5), '2.5');
      expect(engine.format(0), '0');
      expect(engine.format(-0.0), '0');
      expect(engine.format(0.3333333333333), '0.333333333');
    });
  });
}
