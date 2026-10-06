/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_navigate.dart
/// Purpose: Widget used by the feature's screens.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';

import '../theme/haptic_controller.dart';

/// Page route used by every navigation helper: the new page's components
/// SLIDE in (from the reading-direction end) while fading in, with a LOW
/// haptic for the navigation (cards / top-of-page navigation).
Route<T> appSlideRoute<T>(Widget widget) => PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bool rtl = Directionality.of(context) == TextDirection.rtl;
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(rtl ? -0.15 : 0.15, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );

void navigateTo(context, widget) {
  HapticController.low();
  Navigator.push(context, appSlideRoute(widget));
}

Future<T?> navigateToAsync<T>(BuildContext context, Widget widget) {
  HapticController.low();
  return Navigator.push<T>(context, appSlideRoute<T>(widget));
}

void navigateAndFinish(context, widget) {
  HapticController.low();
  Navigator.pushAndRemoveUntil(
      context, appSlideRoute(widget), (route) => false);
}
