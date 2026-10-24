// ******************* FILE INFO *******************
/// Description: `SlideFrom` enum, `SlideInContent` widget, state and UI of the `SlideInContent` widget and 21 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// File Name: app_animations
// Description: Reusable, drop-in animation widgets used across the app.
//              These wrappers are PURELY visual. They never change business
//              logic: they wrap an existing `child` and animate it.
//
// Mapping (as requested):
//   • Slide  -> page components (content slides in when a page opens)
//   • Bounce -> switching the main screen view (list <-> grid)
//   • Shake  -> "are you sure" dialogs (delete/remove + logout + login errors),
//               shakes ONCE only (not continuous, to avoid being annoying)
//   • Scale  -> all other dialog boxes (except delete/remove)
//   • Size   -> tables (animate size changes)
//   • Yellow buttons -> shrink (get smaller) on press
//   • Implicit Animation -> expand/collapse with a button
//
// Module: core/animation
// *************************************************

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// ============================================================================
// 1. SLIDE  ->  PAGE COMPONENTS
// ----------------------------------------------------------------------------
// Wrap a page's body (or any section) with [SlideInContent]. When the widget
// is first built (i.e. the page opens) the child slides into place while
// fading in. Direction and timing are configurable.
// ============================================================================

/// The house motion values (X-72, shared with SpaCareTime). Every wrapper in
/// this file takes its default curve from here.
abstract final class KpMotion {
  /// Everything except bounce and scale: `cubic-bezier(.22,.85,.30,1)`.
  static const Curve ease = Cubic(0.22, 0.85, 0.30, 1.0);

  /// List ↔ Grid bounce: `cubic-bezier(.30,1.40,.50,1)`.
  static const Curve bounce = Cubic(0.30, 1.40, 0.50, 1.0);

  /// Dialog scale-in: `cubic-bezier(.20,.90,.28,1.06)`.
  static const Curve scale = Cubic(0.20, 0.90, 0.28, 1.06);

  /// Page slide.
  static const Duration page = Duration(milliseconds: 400);
}

/// The ONE page transition (X-15 / X-72): every route slides in over 400 ms.
/// Set as `ThemeData.pageTransitionsTheme`, so every `MaterialPageRoute` in
/// the app inherits it; `appSlideRoute` and GetX routes use the same values.
///
/// On iOS the native Cupertino slide is kept (only its timing changes) so the
/// swipe-from-the-edge back gesture still works; elsewhere the content slides
/// a little from the reading side while it fades in.
class KpPageTransitionsBuilder extends PageTransitionsBuilder {
  const KpPageTransitionsBuilder();

  @override
  Duration get transitionDuration => KpMotion.page;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return const CupertinoPageTransitionsBuilder().buildTransitions(
          route, context, animation, secondaryAnimation, child);
    }
    return kpSlideFade(context, animation, child);
  }
}

/// Slide + fade used by [KpPageTransitionsBuilder] and `appSlideRoute`.
Widget kpSlideFade(
  BuildContext context,
  Animation<double> animation,
  Widget child,
) {
  final bool rtl = Directionality.of(context) == TextDirection.rtl;
  final Animation<double> curved =
      CurvedAnimation(parent: animation, curve: KpMotion.ease);
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(rtl ? -0.15 : 0.15, 0),
      end: Offset.zero,
    ).animate(curved),
    child: FadeTransition(opacity: curved, child: child),
  );
}

/// The page transition for every platform, for `ThemeData`.
const PageTransitionsTheme kpPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: KpPageTransitionsBuilder(),
    TargetPlatform.iOS: KpPageTransitionsBuilder(),
    TargetPlatform.macOS: KpPageTransitionsBuilder(),
    TargetPlatform.windows: KpPageTransitionsBuilder(),
    TargetPlatform.linux: KpPageTransitionsBuilder(),
    TargetPlatform.fuchsia: KpPageTransitionsBuilder(),
  },
);

enum SlideFrom { left, right, top, bottom }

class SlideInContent extends StatefulWidget {
  final Widget child;
  final SlideFrom from;
  final Duration duration;
  final Duration delay;
  final double offset; // distance to travel, as a fraction of the child size
  final Curve curve;
  final bool fade;

  const SlideInContent({
    super.key,
    required this.child,
    this.from = SlideFrom.bottom,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offset = 0.25,
    this.curve = KpMotion.ease,
    this.fade = true,
  });

  @override
  State<SlideInContent> createState() => _SlideInContentState();
}

class _SlideInContentState extends State<SlideInContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  Offset get _beginOffset {
    switch (widget.from) {
      case SlideFrom.left:
        return Offset(-widget.offset, 0);
      case SlideFrom.right:
        return Offset(widget.offset, 0);
      case SlideFrom.top:
        return Offset(0, -widget.offset);
      case SlideFrom.bottom:
        return Offset(0, widget.offset);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slide = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SlideTransition(position: _slide, child: widget.child);
    return widget.fade
        ? FadeTransition(opacity: _fade, child: content)
        : content;
  }
}

// ============================================================================
// 2. BOUNCE  ->  LIST / GRID VIEW SWITCH
// ----------------------------------------------------------------------------
// Wrap the area that switches between list and grid. Whenever [triggerValue]
// changes (e.g. isGridView toggles), the child bounces in.
// ============================================================================

class BounceSwitcher extends StatefulWidget {
  final Widget child;

  /// Any value that changes when the view is toggled (e.g. isGridView).
  final Object? triggerValue;
  final Duration duration;

  const BounceSwitcher({
    super.key,
    required this.child,
    required this.triggerValue,
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  State<BounceSwitcher> createState() => _BounceSwitcherState();
}

class _BounceSwitcherState extends State<BounceSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _bounce = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: KpMotion.bounce));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BounceSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerValue != widget.triggerValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _bounce, child: widget.child);
  }
}

/// Small helper that bounces an icon/button when tapped (for the toggle icons
/// themselves). It does NOT consume the tap — it just adds a bounce reaction.
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap == null ? null : _play,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ============================================================================
// 3. SHAKE  ->  "ARE YOU SURE" DIALOGS / LOGIN ERRORS  (SHAKES ONCE)
// ----------------------------------------------------------------------------
// Wrap the confirm-dialog content (delete / remove / logout) with [ShakeOnce].
// By default it shakes a single time when shown. To trigger a shake on demand
// (e.g. a login error), give it a GlobalKey<ShakeOnceState> and call
// `key.currentState?.shake()`.
// ============================================================================

class ShakeOnce extends StatefulWidget {
  final Widget child;

  /// Shake one time automatically when first shown.
  final bool autoPlay;
  final Duration duration;
  final double magnitude; // max horizontal travel in logical pixels

  const ShakeOnce({
    super.key,
    required this.child,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 520),
    this.magnitude = 9.0, // X-72: ±9 px, damped, one pass
  });

  @override
  State<ShakeOnce> createState() => ShakeOnceState();
}

class ShakeOnceState extends State<ShakeOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) shake();
      });
    }
  }

  /// Trigger a single shake. Safe to call multiple times.
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 3 oscillations that decay to zero -> "shake once" feel.
        final dx = math.sin(_controller.value * math.pi * 3) *
            widget.magnitude *
            (1 - _controller.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

// ============================================================================
// 4. SCALE  ->  ALL OTHER DIALOGS (except delete/remove)
// ----------------------------------------------------------------------------
// Wrap the dialog content with [ScaleInContent]; it scales up + fades in when shown.
// You can also use [showScaleDialog] as a drop-in for showDialog when you want
// the scale entrance handled by the route transition.
// ============================================================================

class ScaleInContent extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final Curve curve;
  final bool fade;

  const ScaleInContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.beginScale = 0.84,
    this.curve = KpMotion.scale,
    this.fade = true,
  });

  @override
  State<ScaleInContent> createState() => _ScaleInContentState();
}

class _ScaleInContentState extends State<ScaleInContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaled = ScaleTransition(scale: _scale, child: widget.child);
    return widget.fade ? FadeTransition(opacity: _fade, child: scaled) : scaled;
  }
}

/// Drop-in replacement for showDialog that adds a scale + fade entrance.
/// Use for non-destructive dialogs. Keeps the same return type as showDialog.
Future<T?> showScaleDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: duration,
    pageBuilder: (ctx, a1, a2) => builder(ctx),
    transitionBuilder: (ctx, anim, secondary, child) {
      final curved = CurvedAnimation(parent: anim, curve: KpMotion.scale);
      return Transform.scale(
        scale: Tween<double>(begin: 0.84, end: 1.0).evaluate(curved),
        child: Opacity(opacity: anim.value.clamp(0.0, 1.0), child: child),
      );
    },
  );
}

// ============================================================================
// 5. SIZE  ->  TABLES
// ----------------------------------------------------------------------------
// Wrap a table with [AnimatedSizeWrap] so that whenever its size changes
// (rows added/removed, expand/collapse) the change is animated smoothly.
// ============================================================================

class AnimatedSizeWrap extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const AnimatedSizeWrap({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 340),
    this.curve = KpMotion.ease,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      // Do not cut card shadows / borders around the table.
      clipBehavior: Clip.none,
      child: child,
    );
  }
}

// ============================================================================
// 6. YELLOW BUTTONS  ->  SHRINK ON PRESS
// ----------------------------------------------------------------------------
// Wrap a yellow button with [ShrinkOnTap]. It scales the button down slightly
// while pressed, then springs back. It uses Listener (pointer events) so it
// does NOT consume the button's own onTap/onPressed — the underlying button
// still works exactly as before.
// ============================================================================

class ShrinkOnTap extends StatefulWidget {
  final Widget child;
  final double scale; // pressed scale (e.g. 0.92 = 8% smaller)
  final Duration duration;

  const ShrinkOnTap({
    super.key,
    required this.child,
    this.scale = 0.90,
    this.duration = const Duration(milliseconds: 130),
  });

  @override
  State<ShrinkOnTap> createState() => _ShrinkOnTapState();
}

class _ShrinkOnTapState extends State<ShrinkOnTap> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: KpMotion.ease,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// 7. IMPLICIT ANIMATION  ->  BUTTON EXPAND
// ----------------------------------------------------------------------------
// Wrap collapsible content with [ImplicitExpand] and flip [expanded] from a
// button to expand/collapse it with a smooth implicit size+fade animation.
// ============================================================================

class ImplicitExpand extends StatelessWidget {
  final bool expanded;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const ImplicitExpand({
    super.key,
    required this.expanded,
    required this.child,
    this.duration = const Duration(milliseconds: 340),
    this.curve = KpMotion.ease,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: AnimatedOpacity(
        duration: duration,
        opacity: expanded ? 1.0 : 0.0,
        child: expanded
            ? child
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}

// ============================================================================
// 8. DIALOG HELPER  ->  SCALE (normal dialogs) / SHAKE ONCE (destructive)
// ----------------------------------------------------------------------------
// Drop-in for showDialog. Normal dialogs scale in; "are you sure" dialogs
// (delete / remove / log out) shake ONCE instead. Opening a dialog is SILENT
// (X-105): the tap that opened it already fired its own haptic — except a
// login-error style [ErrorFeedbackDialog], which fires HIGH with its shake.
// A dialog widget is destructive when it implements [DestructiveDialog] or
// when `destructive: true` is passed.
// ============================================================================

/// Marker for "are you sure" dialogs (delete / remove / log out). Dialogs
/// that implement it shake once (no scale) when shown with [showAppDialog].
abstract class DestructiveDialog {
  bool get isDestructive;
}

/// Marker for an error-status dialog (e.g. `ResponseDialog` with the error
/// Lottie). Shown with `destructive: true` it is a LOGIN-ERROR style alert:
/// it shakes AND fires the one tap-less haptic, HIGH (X-105).
abstract class ErrorFeedbackDialog {
  bool get isErrorFeedback;
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  bool? destructive,
}) {
  bool errorHapticDone = false;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    builder: (ctx) {
      final Widget child = builder(ctx);
      final bool isDestructive = destructive ??
          (child is DestructiveDialog
              ? (child as DestructiveDialog).isDestructive
              : child is ShakeOnce);
      // X-105: an error dialog the caller marked destructive (a login error)
      // is the one tap-less haptic — HIGH once, with the shake.
      if (destructive == true &&
          child is ErrorFeedbackDialog &&
          (child as ErrorFeedbackDialog).isErrorFeedback &&
          !errorHapticDone) {
        errorHapticDone = true;
        HapticController.error();
      }
      if (child is ShakeOnce || child is ScaleInContent) return child;
      return isDestructive
          ? ShakeOnce(child: child)
          : ScaleInContent(child: child);
    },
  );
}

// ============================================================================
// 9. BUTTON STANDARD  ->  yellow buttons shrink while pressed
// ============================================================================

/// True when [color] is the app's yellow (primary) button colour.
bool isYellowButton(Color? color) =>
    color == null ||
    color == AppColors.primary ||
    color == AppColors.secondaryPrimary;

/// Wraps a button so that, when it is yellow, it gets smaller while pressed.
Widget appPressFeedback({required Color? color, required Widget child}) =>
    isYellowButton(color) ? ShrinkOnTap(child: child) : child;

/// Gives a LOW haptic and returns [value] — used for widget toggles such as
/// the list / grid switch: `isGridView = withLowHaptic(true)`.
T withLowHaptic<T>(T value) {
  HapticController.low();
  return value;
}

/// SLIDE for page components that switch in place (e.g. the module shown
/// next to the drawer): whenever [triggerValue] changes, the child slides in
/// again — without being re-created, so the page keeps its state.
class SlideSwitcher extends StatefulWidget {
  final Widget child;
  final Object? triggerValue;
  final Duration duration;
  final double offset;

  const SlideSwitcher({
    super.key,
    required this.child,
    required this.triggerValue,
    this.duration = const Duration(milliseconds: 400),
    this.offset = 0.06,
  });

  @override
  State<SlideSwitcher> createState() => _SlideSwitcherState();
}

class _SlideSwitcherState extends State<SlideSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  )..value = 1;
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: KpMotion.ease,
  );

  @override
  void didUpdateWidget(covariant SlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerValue != widget.triggerValue) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, widget.offset),
        end: Offset.zero,
      ).animate(_curve),
      child: FadeTransition(opacity: _curve, child: widget.child),
    );
  }
}

/// Wraps a tap callback with a standard haptic (default LOW: widgets/cards).
/// Returns null when [callback] is null so disabled widgets stay disabled.
void Function()? withHaptic(
  void Function()? callback, [
  HapticLevel level = HapticLevel.low,
]) {
  if (callback == null) return null;
  return () {
    HapticController.level(level);
    callback();
  };
}

/// Finger-down haptic (X-104) for a tappable whose tap callback is passed in:
///   `onTapDown: hapticDown(widget.onTap, HapticLevel.medium), onTap: widget.onTap`
/// Returns null when [callback] is null, so a disabled control stays silent.
GestureTapDownCallback? hapticDown(
  Object? callback, [
  HapticLevel level = HapticLevel.low,
]) =>
    callback == null ? null : (_) => HapticController.level(level);
