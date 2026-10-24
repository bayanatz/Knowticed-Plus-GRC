/// Module: messaging / m1_chat / bubbles
///
///*************************** FILE INFO ****************************///
/// File Name: bubble_width.dart
/// Description: Responsive bubble width — a share of the CHAT PANEL.
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Bubbles were a fixed 186 wide (min AND max): on a desktop chat panel a
/// sentence wrapped into a narrow column beside a wide empty area. A short
/// message now hugs its text up to a max that is a share of the chat panel.
///
/// CHANGED 18/10/2026 (D-184 — "bubbles never cross the middle"): the max was
/// 34% of the SCREEN, but the chat panel is only part of the screen (rail +
/// chat list beside it), so 34% of the screen was ~60% of the panel and mine
/// and theirs overlapped the middle. MessageListView now publishes the panel
/// width ([KpChatPanelWidth]); on tablet / desktop a bubble PLUS whatever sits
/// beside it (sender avatar, selection tick — [reserve]) stays under half the
/// panel. Phone keeps 72% of the panel (D-182).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// The width of the message list the bubbles are laid out in.
class KpChatPanelWidth extends InheritedWidget {
  const KpChatPanelWidth({
    super.key,
    required this.width,
    required super.child,
  });

  final double width;

  static double? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<KpChatPanelWidth>()?.width;

  @override
  bool updateShouldNotify(KpChatPanelWidth oldWidget) =>
      oldWidget.width != width;
}

/// [reserve] = the width of what sits beside the bubble in its half of the
/// panel (sender avatar + gap, selection tick).
BoxConstraints kpBubbleConstraints(BuildContext context, {double reserve = 0}) {
  final double panel =
      KpChatPanelWidth.maybeOf(context) ?? MediaQuery.sizeOf(context).width;
  final double maxW = kpIsPhoneLayout(context)
      ? panel * 0.72
      // 8 short of the middle so the two sides never touch.
      : panel / 2 - 8 - reserve;
  final double minW = math.min(110.w, maxW);
  return BoxConstraints(
    minHeight: 41.h,
    minWidth: minW,
    maxWidth: math.max(minW, maxW),
  );
}
