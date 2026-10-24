/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_navigate.dart
/// Description: Widget used by the feature's screens.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Page route used by every navigation helper: the new page's components
/// SLIDE in (from the reading-direction end) while fading in, with a LOW
/// haptic for the navigation (cards / top-of-page navigation).
// CHANGED 17/10/2026 (X-72): the house page transition — 400 ms with the
// house curve, the same values as the theme's KpPageTransitionsBuilder.
Route<T> appSlideRoute<T>(Widget widget) => PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          kpSlideFade(context, animation, child),
      transitionDuration: KpMotion.page,
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );

void navigateTo(BuildContext context, Widget widget) {
  HapticController.low();
  Navigator.push(context, appSlideRoute(widget));
}

Future<T?> navigateToAsync<T>(BuildContext context, Widget widget) {
  HapticController.low();
  return Navigator.push<T>(context, appSlideRoute<T>(widget));
}

void navigateAndFinish(BuildContext context, Widget widget) {
  HapticController.low();
  Navigator.pushAndRemoveUntil(
    context,
    appSlideRoute(widget),
    (route) => false,
  );
}
