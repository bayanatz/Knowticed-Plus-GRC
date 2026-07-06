// ******************* FILE INFO *******************
// File Name: app_haptics.dart
// Description: Centralized haptic feedback helper.
//   Three semantic intensity levels are exposed:
//     • low()    -> widgets & cards, skip / cancel buttons in dialogs,
//                   top-of-page navigation
//     • medium() -> yellow buttons: assign, add, create, discard, edit
//     • high()   -> destructive actions: remove, delete, cancel, reject,
//                   log out, "are you sure" confirmation dialogs
//
//   All feedback is routed through [HapticController], so it can be turned
//   on/off globally from a single place (the haptic toggle stored by
//   HapticController). If the global toggle is off, these calls are no-ops.
// *************************************************

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

class AppHaptics {
  AppHaptics._();

  static HapticController get _controller => Get.isRegistered<HapticController>()
      ? Get.find<HapticController>()
      : Get.put(HapticController());

  /// Low intensity — widgets & cards, skip/cancel in dialogs, top page navigation.
  static void low() => _controller.triggerHapticFeedback(
        vibration: VibrateType.lightImpact,
        hapticFeedback: HapticFeedback.lightImpact,
      );

  /// Medium intensity — yellow buttons: assign, add, create, discard, edit.
  static void medium() => _controller.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

  /// High intensity — remove, delete, cancel, reject, log out, "are you sure" dialogs.
  static void high() => _controller.triggerHapticFeedback(
        vibration: VibrateType.heavyImpact,
        hapticFeedback: HapticFeedback.heavyImpact,
      );
}
