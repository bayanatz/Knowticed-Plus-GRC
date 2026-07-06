import 'package:get/get.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

export 'package:demo_app/core/haptic/haptic_controller.dart' show HapticController;

/// Global, app-wide access to the [HapticController].
///
/// Instead of writing
/// `final HapticController hapticController = Get.put(HapticController());`
/// in every widget, just import this file and call:
///
/// ```dart
/// import 'package:demo_app/core/custom/33-custom_haptic.dart';
///
/// hapticController.triggerHapticFeedback();
/// ```
///
/// The controller is created lazily the first time it is accessed and reused
/// afterwards.
HapticController get hapticController => Get.isRegistered<HapticController>()
    ? Get.find<HapticController>()
    : Get.put(HapticController());
