/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: dialog_lottie.dart
/// Purpose: Declares `DialogLottie` — the animation at the top of a dialog or
///          status screen, sized inside the layout so it can never spill out.
/// Created at: 24/10/2026 (Moataz: "in portrait the Lottie is too expanded, it
///          goes out of the dialog").
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A Lottie in a square box of [size], never wider than [maxShare] of the room
/// it is given.
///
/// Why this exists: dialogs used `Transform.scale` (1.5×, 2×, 2.5× in
/// portrait) around a small Lottie. A transform changes only how the picture is
/// drawn, not the room it takes, so the animation grew past the top and sides
/// of the dialog. Here the box itself is the size, so the dialog grows to hold
/// it, and a cap keeps it inside a narrow dialog.
class DialogLottie extends StatelessWidget {
  const DialogLottie({
    super.key,
    required this.asset,
    required this.size,
    this.maxShare = 0.5,
    this.repeat = true,
  });

  final String asset;

  /// The size you would like, in logical pixels.
  final double size;

  /// The most of the available width the animation may take (0..1).
  final double maxShare;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double room =
            box.maxWidth.isFinite ? box.maxWidth * maxShare : size;
        final double side = math.min(size, room);
        return SizedBox(
          width: side,
          height: side,
          child: Lottie.asset(asset, fit: BoxFit.contain, repeat: repeat),
        );
      },
    );
  }
}
