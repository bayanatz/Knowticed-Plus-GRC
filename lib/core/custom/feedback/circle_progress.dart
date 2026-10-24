/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: circle_progress_master.dart
/// Description: Declares `CircleProgressMaster` and the app's modal loading
///          overlay — the ONE home for "something is in progress".
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 10/9/2026 - Absorbed `83-loading.dart`, which is deleted.
///
/// WHY THERE IS ONLY ONE OF THESE NOW
/// `83-loading.dart` held a second spinner widget, `CircleProgress`, and the
/// two `showLoadingIndicator` / `hideLoadingIndicator` helpers. The two widgets
/// were the same control drawn differently — `CircleProgress` in
/// `secondaryPrimary` at whatever size its parent happened to give it,
/// `CircleProgressMaster` in `lightPrimary` at a fixed fraction of the screen —
/// so which spinner a screen showed came down to which file its author had
/// imported. Every `CircleProgress` is a `CircleProgressMaster` now.
///
/// The two overlay helpers moved here UNCHANGED. They are not built on
/// `CircleProgressMaster`: the modal draws a deliberately larger 70pt ring, and
/// rebuilding it on the inline widget would have silently shrunk every loading
/// dialog in the app.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

/// The visible height of the phone page frame's scroll area, published by
/// SideFrameMasterServices so a loader can centre itself on the screen.
class SideFrameViewport extends InheritedWidget {
  const SideFrameViewport({
    super.key,
    required this.height,
    required super.child,
  });

  final double height;

  static double? heightOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SideFrameViewport>()?.height;

  @override
  bool updateShouldNotify(SideFrameViewport old) => old.height != height;
}

// date:April/30/2024
// by:MohamedFouad
// lastUpdate:April/30/2024
// This class is used to create a circular progress indicator with a light primary color.
// It is used to indicate that an operation is in progress.
class CircleProgressMaster extends StatelessWidget {
  /// The app's standard loader: centred, sized for the screen.
  const CircleProgressMaster({super.key})
      : _inline = false,
        value = null,
        color = null,
        valueColor = null,
        backgroundColor = null,
        strokeWidth = null;

  /// The SAME spinner, drawn in place of a `CircularProgressIndicator`: it
  /// fills whatever box its parent gives it (buttons, small slots, upload
  /// progress). Takes the same arguments as `CircularProgressIndicator`;
  /// anything left out falls back to the app's standard look.
  ///
  /// Every circle progress in the app goes through this file — do not use
  /// `CircularProgressIndicator` directly.
  const CircleProgressMaster.inline({
    super.key,
    this.value,
    this.color,
    this.valueColor,
    this.backgroundColor,
    this.strokeWidth,
  }) : _inline = true;

  final bool _inline;

  /// Null = spinning; 0..1 = determinate progress (e.g. an upload).
  final double? value;
  final Color? color;
  final Animation<Color?>? valueColor;
  final Color? backgroundColor;
  final double? strokeWidth;

  Widget _indicator() {
    final bool customColor = color != null || valueColor != null;
    return CircularProgressIndicator(
      value: value,
      color: valueColor == null ? (color ?? AppColors.lightPrimary) : null,
      valueColor: valueColor,
      backgroundColor: backgroundColor ??
          (customColor ? null : AppColors.white.withValues(alpha: 0.6)),
      strokeWidth: strokeWidth ?? 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_inline) return _indicator();
    // Owner 22/10/2026 ("when something is reloading it's in the center"):
    // inside the phone page frame the body scrolls, so a plain Center only
    // centres sideways and the spinner sat at the top. The frame publishes
    // its visible height (SideFrameViewport); the loader fills it and sits
    // in the middle of the screen.
    //
    // Only a PAGE-level loader does this — one as wide as the frame's content
    // (the screen minus the frame's 15 inset each side). A loader inside a
    // card is narrower and keeps its own small size; otherwise it would
    // stretch a card to the screen's height (Home cards on the phone).
    final double? viewport = SideFrameViewport.heightOf(context);
    if (viewport != null) {
      final double pageWidth = MediaQuery.sizeOf(context).width - 30.sp;
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) =>
            box.hasBoundedHeight || box.maxWidth < pageWidth - 1
                ? _sized(context)
                : SizedBox(height: viewport, child: _sized(context)),
      );
    }
    return _sized(context);
  }

  Widget _sized(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Center(
      child: SizedBox(
        width: isTablet
            ? orientation
                ? .045.h
                : .06.h
            : .045.h,
        height: isTablet
            ? orientation
                ? .045.h
                : .06.h
            : .045.h,
        child: _indicator(),
      ),
    );
  }
}

/// Full-screen modal loading overlay.
///
/// Canonical home for the app's loading indicator: every feature calls these
/// two instead of rolling its own overlay.
///
/// MOVED 10/9/2026 from `83-loading.dart`, byte for byte — see the file header.
Future showLoadingIndicator() {
  double size = 70;
  return Get.dialog(
    Scaffold(
      backgroundColor: AppColors.transparent,
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: const CircleProgressMaster.inline(),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 700),
  );
}

void hideLoadingIndicator() {
  Get.back();
}
