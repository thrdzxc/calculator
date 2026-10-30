import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_glass_calculator/main.dart';
import 'package:aurora_glass_calculator/widgets/glass_key.dart';

void main() {
  testWidgets('calculator shows readable controls and computes', (tester) async {
    await tester.pumpWidget(const AuroraCalculatorApp());
    expect(find.text('AURORA'), findsOneWidget);
    expect(find.text('GLASS CALCULATOR'), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    // Buttons are interactive and the expression engine is wired to the UI.
    Finder key(String label) => find.byWidgetPredicate(
          (widget) => widget is GlassKey && widget.label == label,
        );
    Future<void> tapKey(String label) async {
      await tester.ensureVisible(key(label));
      await tester.pumpAndSettle();
      await tester.tap(key(label));
      await tester.pumpAndSettle();
    }

    await tapKey('7');
    await tapKey('+');
    await tapKey('3');
    await tapKey('=');
    expect(find.text('10'), findsWidgets);
  });
}
