import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const GlitchText(this.text, {super.key, this.style});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rng = Random();
  double _offsetX1 = 0;
  double _offsetX2 = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addListener(() {
      if (_controller.value < 0.6) {
        setState(() {
          _offsetX1 = (_rng.nextDouble() - 0.5) * 4;
          _offsetX2 = (_rng.nextDouble() - 0.5) * 4;
        });
      } else {
        setState(() {
          _offsetX1 = 0;
          _offsetX2 = 0;
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _defaultStyle = TextStyle(
    fontFamily: 'SpaceMono',
    color: AppColors.fgPrimary,
    fontSize: 18,
    letterSpacing: 4,
  );

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? _defaultStyle;

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(_offsetX1, 0),
          child: Text(
            widget.text,
            style: style.copyWith(
                color: AppColors.phosphor.withValues(alpha: 0.5)),
          ),
        ),
        Transform.translate(
          offset: Offset(_offsetX2, 0),
          child: Text(
            widget.text,
            style: style.copyWith(
                color: AppColors.electricBlue.withValues(alpha: 0.5)),
          ),
        ),
        Text(widget.text, style: style),
      ],
    );
  }
}
