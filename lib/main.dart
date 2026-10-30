import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/calculator_controller.dart';
import 'widgets/glass_key.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuroraCalculatorApp());
}

class AuroraCalculatorApp extends StatefulWidget {
  const AuroraCalculatorApp({super.key});

  @override
  State<AuroraCalculatorApp> createState() => _AuroraCalculatorAppState();
}

class _AuroraCalculatorAppState extends State<AuroraCalculatorApp> {
  bool _dark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Glass Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: _dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Roboto',
      ),
      home: _CalculatorScreen(
        dark: _dark,
        onToggleTheme: () => setState(() => _dark = !_dark),
      ),
    );
  }
}

class _CalculatorScreen extends StatefulWidget {
  const _CalculatorScreen({
    required this.dark,
    required this.onToggleTheme,
  });

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  State<_CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<_CalculatorScreen> {
  final CalculatorController _calculator = CalculatorController();

  @override
  void dispose() {
    _calculator.dispose();
    super.dispose();
  }

  Color get _primaryText => widget.dark
      ? const Color(0xFFF6F9FF)
      : const Color(0xFF152347);

  Color get _mutedText => widget.dark
      ? const Color(0xFFB4BFDA)
      : const Color(0xFF546588);

  void _copyAnswer() {
    final answer = _calculator.preview.isNotEmpty
        ? _calculator.preview
        : _calculator.expression;
    Clipboard.setData(ClipboardData(text: answer));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Value copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.dark
            ? const Color(0xFF343B67)
            : const Color(0xFF5366A1),
      ),
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _calculator.press('=');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _calculator.press('⌫');
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.delete) {
      _calculator.press('AC');
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character == null || character.isEmpty) return KeyEventResult.ignored;
    if (character == '=') {
      _calculator.press('=');
      return KeyEventResult.handled;
    }
    if (RegExp(r'^\d$').hasMatch(character) ||
        const ['+', '-', '.', '%', '(', ')'].contains(character)) {
      _calculator.press(character);
      return KeyEventResult.handled;
    }
    if (character == '*') {
      _calculator.press('×');
      return KeyEventResult.handled;
    }
    if (character == '/') {
      _calculator.press('÷');
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _Atmosphere(dark: widget.dark),
          SafeArea(
            child: Focus(
              autofocus: true,
              onKeyEvent: _handleKey,
              child: LayoutBuilder(
                builder: (context, viewport) {
                  final smallScreen = viewport.maxHeight < 770;
                  final buttonHeight = smallScreen ? 53.0 : 62.0;
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: smallScreen ? 12 : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 465),
                        child: AnimatedBuilder(
                          animation: _calculator,
                          builder: (context, _) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _brandHeader(),
                              const SizedBox(height: 17),
                              _calculatorPanel(buttonHeight, smallScreen),
                              const SizedBox(height: 18),
                              _footer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFF80DFFF), Color(0xFF9F87FA)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8AA7FF).withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              size: 25, color: Color(0xFF141B46)),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AURORA',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.2,
                ),
              ),
              Text(
                'GLASS CALCULATOR',
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _roundAction(
          tooltip: 'Calculation history',
          icon: Icons.history_rounded,
          onTap: _showHistory,
        ),
        const SizedBox(width: 9),
        _roundAction(
          tooltip: widget.dark ? 'Use light theme' : 'Use dark theme',
          icon: widget.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          onTap: widget.onToggleTheme,
        ),
      ],
    );
  }

  Widget _roundAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: widget.dark ? 0.10 : 0.56),
              border: Border.all(
                color: Colors.white.withValues(alpha: widget.dark ? 0.18 : 0.93),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _primaryText, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _calculatorPanel(double buttonHeight, bool compact) {
    return _FrostedPanel(
      dark: widget.dark,
      child: Padding(
        padding: EdgeInsets.all(compact ? 15 : 19),
        child: Column(
          children: [
            _display(compact),
            SizedBox(height: compact ? 16 : 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.white.withValues(alpha: widget.dark ? 0.28 : 0.85),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
            SizedBox(height: compact ? 15 : 19),
            _keypad(buttonHeight),
          ],
        ),
      ),
    );
  }

  Widget _display(bool compact) {
    final error = _calculator.error;
    final result = error ?? (_calculator.preview.isEmpty
        ? (_calculator.justEvaluated ? _calculator.expression : '—')
        : _calculator.preview);
    final hasResult = _calculator.preview.isNotEmpty || _calculator.justEvaluated;
    return SizedBox(
      height: compact ? 148 : 177,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 7,
                    width: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF85E9D6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'LIVE CALCULATION',
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.75,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: 'Copy current value',
                child: IconButton(
                  constraints: const BoxConstraints(minHeight: 34, minWidth: 34),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.content_copy_rounded, size: 17, color: _mutedText),
                  onPressed: _copyAnswer,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: compact ? 46 : 54,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                alignment: Alignment.centerRight,
                fit: BoxFit.scaleDown,
                child: Text(
                  _calculator.expression,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 39,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: _primaryText,
                    letterSpacing: -0.8,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: compact ? 46 : 55,
            child: Row(
              children: [
                if (error == null)
                  Text(
                    '=',
                    style: TextStyle(
                      color: hasResult
                          ? const Color(0xFF8ECAFF)
                          : _mutedText.withValues(alpha: 0.6),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (error == null) const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      alignment: Alignment.centerRight,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        result,
                        maxLines: 1,
                        style: TextStyle(
                          color: error != null
                              ? const Color(0xFFFFA2B3)
                              : hasResult
                                  ? (widget.dark
                                      ? const Color(0xFF91E7FF)
                                      : const Color(0xFF365AB2))
                                  : _mutedText.withValues(alpha: 0.60),
                          fontSize: error != null ? 20 : 36,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _keypad(double height) {
    final rows = <List<_KeySpec>>[
      [
        const _KeySpec('(', GlassKeyKind.utility),
        const _KeySpec(')', GlassKeyKind.utility),
        const _KeySpec('%', GlassKeyKind.utility),
        const _KeySpec('AC', GlassKeyKind.destructive),
      ],
      [
        const _KeySpec('7'), const _KeySpec('8'), const _KeySpec('9'),
        const _KeySpec('÷', GlassKeyKind.operator),
      ],
      [
        const _KeySpec('4'), const _KeySpec('5'), const _KeySpec('6'),
        const _KeySpec('×', GlassKeyKind.operator),
      ],
      [
        const _KeySpec('1'), const _KeySpec('2'), const _KeySpec('3'),
        const _KeySpec('-', GlassKeyKind.operator),
      ],
      [
        const _KeySpec('±', GlassKeyKind.utility), const _KeySpec('0'),
        const _KeySpec('.'), const _KeySpec('+', GlassKeyKind.operator),
      ],
      [
        const _KeySpec('⌫', GlassKeyKind.utility, Icons.backspace_outlined),
        const _KeySpec('=', GlassKeyKind.equal),
      ],
    ];

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex != 0) const SizedBox(height: 10),
          SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < rows[rowIndex].length; i++) ...[
                  if (i != 0) const SizedBox(width: 10),
                  Expanded(
                    child: GlassKey(
                      label: rows[rowIndex][i].label,
                      kind: rows[rowIndex][i].kind,
                      icon: rows[rowIndex][i].icon,
                      dark: widget.dark,
                      onPressed: () => _calculator.press(rows[rowIndex][i].label),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 14, color: _mutedText),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'PRECISE MATH  •  ELEGANT DESIGN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a key or use your physical keyboard',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedText, fontSize: 11),
        ),
      ],
    );
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final entries = _calculator.history;
          return FractionallySizedBox(
            heightFactor: 0.68,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _FrostedPanel(
                  dark: widget.dark,
                  radius: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Container(
                            height: 5,
                            width: 44,
                            decoration: BoxDecoration(
                              color: _mutedText.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(Icons.history_rounded, color: _primaryText),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Calculation history',
                                style: TextStyle(
                                  color: _primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (entries.isNotEmpty)
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Clear'),
                                onPressed: () {
                                  _calculator.clearHistory();
                                  setSheetState(() {});
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: entries.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.receipt_long_rounded,
                                          color: _mutedText, size: 44),
                                      const SizedBox(height: 12),
                                      Text('No calculations yet',
                                          style: TextStyle(color: _primaryText,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 5),
                                      Text('Your completed calculations appear here.',
                                          style: TextStyle(color: _mutedText,
                                              fontSize: 12)),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: entries.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final entry = entries[index];
                                    return Material(
                                      color: Colors.white.withValues(
                                          alpha: widget.dark ? 0.075 : 0.50),
                                      borderRadius: BorderRadius.circular(16),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          _calculator.restore(entry);
                                          Navigator.of(sheetContext).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 13),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(entry.expression,
                                                  style: TextStyle(
                                                      color: _mutedText,
                                                      fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 4),
                                              Text('= ${entry.result}',
                                                  style: TextStyle(
                                                      color: _primaryText,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text('Tap an entry to restore it • Last 30 calculations',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: _mutedText)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KeySpec {
  const _KeySpec(this.label, [this.kind = GlassKeyKind.number, this.icon]);
  final String label;
  final GlassKeyKind kind;
  final IconData? icon;
}

class _FrostedPanel extends StatelessWidget {
  const _FrostedPanel({
    required this.dark,
    required this.child,
    this.radius = 31,
  });
  final bool dark;
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000620).withValues(alpha: dark ? 0.35 : 0.10),
            blurRadius: 45,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        const Color(0xFF37436E).withValues(alpha: 0.63),
                        const Color(0xFF121B3D).withValues(alpha: 0.86),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.86),
                        const Color(0xFFDDE9FF).withValues(alpha: 0.69),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: dark ? 0.28 : 0.94),
                width: 1.3,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF080D22), Color(0xFF141A40), Color(0xFF070F29)]
              : const [Color(0xFFDFE9FC), Color(0xFFEDF5FF), Color(0xFFD9E6FB)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -95,
            child: _glow(
              dark ? const Color(0xFF6555D9) : const Color(0xFF8C98FF),
              370,
            ),
          ),
          Positioned(
            top: 260,
            left: -160,
            child: _glow(
              dark ? const Color(0xFF0089B5) : const Color(0xFF76D0ED),
              390,
            ),
          ),
          Positioned(
            bottom: -175,
            right: -100,
            child: _glow(
              dark ? const Color(0xFF5B368D) : const Color(0xFFB0A7FC),
              390,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: dark ? 0.46 : 0.38),
          ),
        ),
      ),
    );
  }
}
