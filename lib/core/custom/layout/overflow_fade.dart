/// Module: core/custom/layout
/// Description: Fades the start / end edge of a sideways-scrolling row while
///              more content hides there, and scrolls the selected item into
///              view. MOVED 17/10/2026 from the Time Tracker (TtOverflowFade)
///              so every module uses one component (K-30); D-89 rows (counter
///              tabs, module chips) use it on iPad portrait and the phone.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';

/// Wraps a [child] that holds ONE horizontal scroll view (core `CustomTabs`,
/// `StatusChipFilter`, …): fades the edge(s) that hide more content and
/// scrolls the `Text` reading [revealText] fully into view whenever it
/// changes. Nothing happens while the content fits.
class OverflowFade extends StatefulWidget {
  const OverflowFade(
      {super.key,
      required this.child,
      this.revealText,
      this.axis = Axis.horizontal});

  /// ADDED 17/10/2026 (macOS resize test): `Axis.vertical` fades the top /
  /// bottom edge of a column that scrolls (the sidebar in a short window),
  /// so hidden items read as "more". Horizontal keeps every existing use.
  final Axis axis;

  final Widget child;

  /// Text of the selected item (unique inside [child]); null = no reveal.
  final String? revealText;

  @override
  State<OverflowFade> createState() => _OverflowFadeState();
}

class _OverflowFadeState extends State<OverflowFade> {
  /// More content hidden before (start side) / after (end side).
  bool _moreBefore = false;
  bool _moreAfter = false;

  @override
  void initState() {
    super.initState();
    _reveal(animate: false);
  }

  @override
  void didUpdateWidget(OverflowFade old) {
    super.didUpdateWidget(old);
    if (old.revealText != widget.revealText) _reveal(animate: true);
  }

  /// Function Name: [_reveal]
  ///
  /// Purpose: After the frame, scroll just enough for the selected item to
  /// be fully visible (+ a margin), never past the ends.
  ///
  /// Return type: [void]
  void _reveal({required bool animate}) {
    final String? text = widget.revealText;
    if (text == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? target = _findText(context, text);
      final RenderObject? box = target?.findRenderObject();
      final ScrollableState? scrollable =
          target == null ? null : Scrollable.maybeOf(target);
      if (box == null || scrollable == null || !box.attached) return;
      final ScrollPosition position = scrollable.position;
      if (!position.hasContentDimensions || position.maxScrollExtent <= 0) {
        return;
      }
      final RenderAbstractViewport viewport = RenderAbstractViewport.of(box);
      final double margin = 32.w;
      final double atStart = viewport.getOffsetToReveal(box, 0).offset - margin;
      final double atEnd = viewport.getOffsetToReveal(box, 1).offset + margin;
      final double kept = position.pixels
          .clamp(math.min(atStart, atEnd), math.max(atStart, atEnd));
      final double to =
          kept.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((to - position.pixels).abs() < 0.5) return;
      if (animate) {
        position.animateTo(to,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } else {
        position.jumpTo(to);
      }
    });
  }

  /// The element of the `Text` showing [text] under [root].
  BuildContext? _findText(BuildContext root, String text) {
    BuildContext? found;
    void visit(Element e) {
      if (found != null) return;
      final Widget w = e.widget;
      if (w is Text && w.data == text) {
        found = e;
        return;
      }
      e.visitChildElements(visit);
    }

    root.visitChildElements(visit);
    return found;
  }

  bool _onMetrics(ScrollMetrics m) {
    if (m.axis != widget.axis) return false;
    final bool before = m.extentBefore > 0.5;
    final bool after = m.extentAfter > 0.5;
    if (before != _moreBefore || after != _moreAfter) {
      // Metrics notifications arrive after layout; repaint on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _moreBefore = before;
          _moreAfter = after;
        });
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection dir = Directionality.of(context);
    final double fade = 32.w;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification n) =>
          n.depth == 0 && _onMetrics(n.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification n) =>
            n.depth == 0 && _onMetrics(n.metrics),
        // Always behind the mask (fully opaque when nothing overflows) so
        // the scroll view below keeps its state when a fade appears.
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect r) {
            final bool vertical = widget.axis == Axis.vertical;
            final double length = vertical ? r.height : r.width;
            final double f = length <= 0 ? 0 : (fade / length).clamp(0.0, 0.5);
            return LinearGradient(
              begin: vertical
                  ? Alignment.topCenter
                  : AlignmentDirectional.centerStart.resolve(dir),
              end: vertical
                  ? Alignment.bottomCenter
                  : AlignmentDirectional.centerEnd.resolve(dir),
              colors: <Color>[
                _moreBefore ? AppColors.transparent : AppColors.white,
                AppColors.white,
                AppColors.white,
                _moreAfter ? AppColors.transparent : AppColors.white,
              ],
              stops: <double>[0, f, 1 - f, 1],
            ).createShader(r);
          },
          child: widget.child,
        ),
      ),
    );
  }
}
