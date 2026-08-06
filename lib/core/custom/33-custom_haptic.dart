import 'package:get/get.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

export 'package:grc_module/core/theme/haptic_controller.dart' show HapticController;

/// Global, app-wide access to the [HapticController].
///
/// Instead of writing
/// `final HapticController hapticController = Get.put(HapticController());`
/// in every widget, just import this file and call:
///
/// ```dart
/// import 'package:grc_module/core/custom/33-custom_haptic.dart';
///
/// hapticController.triggerHapticFeedback();
/// ```
///
/// The controller is created lazily the first time it is accessed and reused
/// afterwards.
HapticController get hapticController => Get.isRegistered<HapticController>()
    ? Get.find<HapticController>()
    : Get.put(HapticController());
