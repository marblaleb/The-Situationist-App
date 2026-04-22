import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;
  late AnimationController _cursorController;
  late Animation<double> _cursorOpacity;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _cursorOpacity =
        _cursorController.drive(CurveTween(curve: Curves.easeInOut));
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      setState(() {
        _displayed = '';
        _index = 0;
      });
      _startTyping();
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.charDelay, (_) {
      if (!mounted) return;
      if (_index < widget.text.length) {
        setState(() {
          _displayed += widget.text[_index];
          _index++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  bool get _isComplete => _index >= widget.text.length;

  static const _defaultStyle = TextStyle(
    fontFamily: 'Inter',
    color: AppColors.fgPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.6,
  );

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? _defaultStyle;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: _displayed, style: style),
          if (!_isComplete)
            WidgetSpan(
              child: AnimatedBuilder(
                animation: _cursorOpacity,
                builder: (_, __) => Opacity(
                  opacity: _cursorOpacity.value,
                  child: Text(
                    '_',
                    style: style.copyWith(color: AppColors.phosphor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
