import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
  // alias used by some widgets
  bool get isTablett => MediaQuery.of(this).size.shortestSide >= 600;
  bool get isArabic => Get.locale.toString().toLowerCase().contains('ar');
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPhone => MediaQuery.of(this).size.shortestSide < 600;

  /// Wide-and-landscape layout check.
  ///
  /// NOTE: this deliberately keys off `width >= 600`, NOT `isTablet`
  /// (`shortestSide >= 600`). They are not equivalent — a phone held in
  /// landscape (e.g. 812x375) has width 812 but shortestSide 375, so it counts
  /// as `isTabletLandscape` while failing `isTablet`. This preserves the exact
  /// behaviour of the per-file `isTabletLandscape(context)` helpers that are
  /// duplicated across the services, roles and settings modules.
  bool get isTabletLandscape => screenWidth >= 600 && isLandscape;

  /// Pops the nearest navigator, optionally returning [result].
  ///
  /// Ported from the form_builder project, whose module calls `context.pop()`
  /// and `context.popToFirst()` instead of using [Navigator] directly.
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop<T>(result);

  /// Pops the nearest navigator until the first route.
  void popToFirst() => Navigator.of(this).popUntil((route) => route.isFirst);
}

/// Navigation helper used across the form builder module.
///
/// Pushes a named route onto the nearest [Navigator] — the form module's
/// nested navigator when called from inside it — matching the call style
/// `context.FormNavigateTo(Routes.someScreen, arguments: model)`.
///
/// Ported from the form_builder project. The capitalised method name is not
/// Dart convention but is kept so the module's call sites are unchanged.
// ignore_for_file: non_constant_identifier_names
extension FormNavigationExtension on BuildContext {
  Future<T?> FormNavigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
}

