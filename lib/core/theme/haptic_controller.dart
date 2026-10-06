/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: haptic_controller.dart
/// Purpose: Declares `HapticController`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';


final storage = GetStorage();

class HapticController extends GetxController {
  // Define a variable to hold the haptic feedback status
  RxBool isHapticEnabled =
      storage.read('haptic') == true ? true.obs : false.obs;

  // Method to toggle the haptic feedback status
  void toggleHapticFeedback(bool value) {
    isHapticEnabled.value = value;
    storage.write('haptic', value);
    update();
  }

  Future<void> triggerHapticFeedback({
    VibrateType vibration = VibrateType.lightImpact,
    Function() hapticFeedback = HapticFeedback.mediumImpact,
  }) async {
// ✅ Add this

    if (isHapticEnabled.value) {
      if (Platform.isAndroid) {
        Vibration.vibrate(
          duration: vibration == VibrateType.lightImpact
              ? 50
              : vibration == VibrateType.mediumImpact
              ? 70
              : 90,
        );
      } else {
        hapticFeedback();
      }
    }
  }

  // ── Semantic convenience triggers (moved from the retired AppHaptics) ──
  //   low()    → widgets & cards, skip/cancel in dialogs, top page navigation
  //   medium() → yellow buttons: assign, add, create, discard, edit
  //   high()   → destructive: remove, delete, cancel, reject, log out, confirms
  // Routed through the singleton controller so the global toggle still applies.
  static HapticController get _instance => Get.isRegistered<HapticController>()
      ? Get.find<HapticController>()
      : Get.put(HapticController());

  // Time of the last haptic, so an automatic "low" (navigation, card tap)
  // right after a button's own haptic does not vibrate twice.
  static DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  static void _mark() => _last = DateTime.now();
  static bool get _recent =>
      DateTime.now().difference(_last) < const Duration(milliseconds: 250);

  /// LOW: widgets & cards, skip / cancel buttons in dialogs, navigation at
  /// the top of each page.
  static void low() {
    if (_recent) return;
    _mark();
    _instance.triggerHapticFeedback(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
  }

  /// MEDIUM: yellow (primary) buttons, assign, add, create, discard, edit.
  static void medium() {
    _mark();
    _instance.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );
  }

  /// HIGH: remove, delete, cancel, reject, log out, "are you sure" dialogs.
  static void high() {
    _mark();
    _instance.triggerHapticFeedback(
      vibration: VibrateType.heavyImpact,
      hapticFeedback: HapticFeedback.heavyImpact,
    );
  }

  static void level(HapticLevel level) {
    switch (level) {
      case HapticLevel.low:
        low();
        break;
      case HapticLevel.medium:
        medium();
        break;
      case HapticLevel.high:
        high();
        break;
    }
  }

  /// Picks the standard level from a button's text, e.g.
  ///   "Delete", "Remove", "Reject", "Log out", "Cancel order" -> high
  ///   "Cancel", "Skip", "Close", "No", "Back"                 -> low
  ///   "Add", "Create", "Assign", "Edit", "Discard", "Save"    -> medium
  /// Otherwise [fallback].
  static HapticLevel levelForLabel(String? label,
      {HapticLevel fallback = HapticLevel.medium}) {
    final t = (label ?? '').trim().toLowerCase();
    if (t.isEmpty) return fallback;
    const dismiss = {
      'cancel', 'skip', 'close', 'no', 'back', 'not now', 'later',
      'إلغاء', 'الغاء', 'تخطي', 'إغلاق', 'اغلاق', 'لا', 'رجوع',
    };
    if (dismiss.contains(t)) return HapticLevel.low;
    const high = [
      'delete', 'remove', 'cancel', 'reject', 'log out', 'logout',
      'sign out', 'signout', 'deactivate', 'terminate', 'yes',
      'حذف', 'إزالة', 'ازالة', 'إلغاء', 'الغاء', 'رفض', 'خروج', 'نعم',
    ];
    if (high.any(t.contains)) return HapticLevel.high;
    const medium = [
      'assign', 'add', 'create', 'discard', 'edit', 'save', 'submit',
      'confirm', 'update', 'upload', 'new', 'approve', 'send', 'apply',
      'إضافة', 'اضافة', 'إنشاء', 'انشاء', 'تعيين', 'تعديل', 'حفظ',
      'تأكيد', 'إرسال', 'ارسال', 'تحديث', 'رفع', 'موافقة',
    ];
    if (medium.any(t.contains)) return HapticLevel.medium;
    return fallback;
  }

  static void forLabel(String? label,
          {HapticLevel fallback = HapticLevel.medium}) =>
      level(levelForLabel(label, fallback: fallback));

  /// True for destructive "are you sure" wording (delete/remove/log out...).
  static bool isDestructiveText(String? text) {
    final t = (text ?? '').toLowerCase();
    const words = [
      'delete', 'remove', 'log out', 'logout', 'sign out',
      'حذف', 'إزالة', 'ازالة', 'تسجيل الخروج',
    ];
    return words.any(t.contains);
  }
}

/// Standard haptic strengths (see [HapticController.low/medium/high]).
enum HapticLevel { low, medium, high }

/// Haptic strength used by [HapticController.triggerHapticFeedback].
/// Relocated from lib/core/enums/enum.dart, which was retired.
enum VibrateType {
  lightImpact,
  mediumImpact,
  heavyImpact,
}
