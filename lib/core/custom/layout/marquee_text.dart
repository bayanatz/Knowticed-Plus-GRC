/// Module: core / custom / layout
///
///*************************** FILE INFO ****************************///
/// File Name: marquee_text.dart
/// Description: One line of text that scrolls only when it is wider than
///              its box (Org Chart cards: long job titles).
/// Author: Moataz Handousa
/// Created at: 18/10/2026 (restored from the Org Chart card, commit 8a26c091)
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/layout/overflow_fade.dart';

// Marquee Text Widget for horizontal scrolling animation - Single line only.
// REWORKED 18/10/2026 (Moataz: "Project Manager" lost the "g" descender and
// names were cut at the card edges while standing still):
// - the fit check runs in a LayoutBuilder against the real width, with the
//   style the Text really renders with (DefaultTextStyle merged, text
//   scale), so a name that fits is never judged "too long" or vice versa,
//   and a new width (rotation / window resize) re-checks;
// - text that fits is shown fully and centred, nothing clipped;
// - only text wider than the card scrolls, inside the core OverflowFade;
// - both paths get the same small vertical inset so descenders never touch
//   the fade mask's edge and every card line has the same height.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;

  /// Centre the text when it fits (stacked cards); false = start-aligned.
  final bool center;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.velocity = 30.0,
    this.center = true,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  /// Room above / below the line for descenders (the "g" in "Manager").
  static const double _verticalInset = 2;

  /// Side inset inside the scroll view so the first letter is not cut.
  static const double _sideInset = 2;

  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;

  double _textWidth = -1;
  double _containerWidth = -1;
  bool _needsScrolling = false;
  bool _restartScheduled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _textWidth = -1; // force a new measurement in the next build
    }
  }

  bool get _isRtl {
    if (widget.text.isEmpty) return false;
    final int firstChar = widget.text.codeUnitAt(0);
    return firstChar >= 0x0590 && firstChar <= 0x06FF;
  }

  double _measure(BuildContext context) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: DefaultTextStyle.of(context).style.merge(widget.style),
      ),
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }

  void _scheduleRestart() {
    if (_restartScheduled) return;
    _restartScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartScheduled = false;
      if (!mounted) return;
      _animationController.stop();
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      if (!_needsScrolling) return;
      final double distance = _textWidth + _containerWidth;
      _animationController.duration =
          Duration(milliseconds: (distance / widget.velocity * 1000).toInt());
      _animationController.forward(from: 0);
    });
  }

  void _onTick() {
    if (!mounted || !_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    final double offset =
        _animationController.value * (_textWidth + _containerWidth);
    _scrollController.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _needsScrolling) _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Text _line() => Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 0;
        final double textWidth = _measure(context);
        final bool needsScrolling = width > 0 && textWidth > width;
        if (width != _containerWidth ||
            textWidth != _textWidth ||
            needsScrolling != _needsScrolling) {
          _containerWidth = width;
          _textWidth = textWidth;
          _needsScrolling = needsScrolling;
          _scheduleRestart();
        }

        if (!needsScrolling) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: _verticalInset),
            child: Align(
              alignment: widget.center
                  ? Alignment.center
                  : AlignmentDirectional.centerStart,
              child: Text(
                widget.text,
                style: widget.style,
                textAlign: widget.center ? TextAlign.center : TextAlign.start,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          );
        }

        // OverflowFade (core custom): the edge where the long name runs on
        // fades out instead of cutting a letter in half.
        return OverflowFade(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: _sideInset, vertical: _verticalInset),
            child: Row(
              children: [
                _line(),
                SizedBox(width: width),
                _line(),
              ],
            ),
          ),
        );
      },
    );
  }
}
