/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: haptic_controller.dart
/// Description: Declares `HapticController`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';

final storage = GetStorage();

class HapticController extends GetxController {
  // Define a variable to hold the haptic feedback status.
  // CHANGED 17/10/2026 (X-116): ON by default for every user — only an
  // explicit "off" saved from the Settings switch turns it off.
  RxBool isHapticEnabled =
      storage.read('haptic') == false ? false.obs : true.obs;

  // Method to toggle the haptic feedback status
  void toggleHapticFeedback(bool value) {
    isHapticEnabled.value = value;
    storage.write('haptic', value);
    update();
  }

  /// Direct haptic used by older screens. CHANGED 17/10/2026 (X-104 "one
  /// tap = one haptic"): skipped when another haptic fired within 250 ms —
  /// e.g. a customButton already ticked on finger-down and its function calls
  /// this again on finger-up.
  Future<void> triggerHapticFeedback({
    VibrateType vibration = VibrateType.lightImpact,
    Function() hapticFeedback = HapticFeedback.mediumImpact,
  }) async {
    if (_recent) return;
    _mark();
    _fire(vibration: vibration, hapticFeedback: hapticFeedback);
  }

  /// The vibration itself, with no same-tap guard.
  void _fire({
    required VibrateType vibration,
    required Function() hapticFeedback,
  }) {
    if (isHapticEnabled.value) {
      if (Platform.isAndroid) {
        Vibration.vibrate(
          // X-72: LOW 10 ms · MEDIUM 25 ms · HIGH 45 ms.
          duration: vibration == VibrateType.lightImpact
              ? 10
              : vibration == VibrateType.mediumImpact
                  ? 25
                  : 45,
        );
      } else {
        hapticFeedback();
      }
    }
  }

  // ── Semantic convenience triggers (moved from the retired AppHaptics) ──
  //   low()    → widgets & cards, tabs, filters, sort, skip, top navigation
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

  // ADDED 17/10/2026 (X-104 "one tap = one haptic"): a MEDIUM / HIGH within
  // 60 ms of another haptic comes from the SAME finger (a control nested in
  // another tappable), so it is dropped. Two separate taps are always > 60 ms
  // apart, so each still gets its own.
  static bool get _sameTap =>
      DateTime.now().difference(_last) < const Duration(milliseconds: 60);

  /// LOW: widgets & cards, tabs, filters, sort, Skip, navigation at the top
  /// of each page.
  static void low() {
    if (_recent) return;
    _mark();
    _instance._fire(
      vibration: VibrateType.lightImpact,
      hapticFeedback: HapticFeedback.lightImpact,
    );
  }

  /// MEDIUM: yellow (primary) buttons, assign, add, create, discard, edit.
  static void medium() {
    if (_sameTap) return;
    _mark();
    _instance._fire(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );
  }

  /// HIGH: remove, delete, cancel, reject, log out, "are you sure" dialogs.
  static void high() {
    if (_sameTap) return;
    _mark();
    _instance._fire(
      vibration: VibrateType.heavyImpact,
      hapticFeedback: HapticFeedback.heavyImpact,
    );
  }

  /// ERROR (X-105): the one haptic that arrives without a tap — a login
  /// error, together with its shake. HIGH, and never dropped by the same-tap
  /// guard (it follows the Sign In tap's own MEDIUM by design).
  static void error() {
    _mark();
    _instance._fire(
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
  ///   "Cancel", "No", "Close" (dismiss buttons)               -> high
  ///   "Skip", "Back", "Later"                                 -> low
  ///   "Add", "Create", "Assign", "Edit", "Discard", "Save"    -> medium
  /// Otherwise [fallback].
  static HapticLevel levelForLabel(
    String? label, {
    HapticLevel fallback = HapticLevel.medium,
  }) {
    final t = (label ?? '').trim().toLowerCase();
    if (t.isEmpty) return fallback;
    // CHANGED 17/10/2026 (X-14 / X-117): every Cancel — and a dialog's No
    // and Close, which are dismiss buttons too — is HIGH. Only Skip / Back /
    // Later stay LOW.
    const dismissHigh = {
      'cancel',
      'no',
      'close',
      'إلغاء',
      'الغاء',
      'إغلاق',
      'اغلاق',
      'لا',
    };
    if (dismissHigh.contains(t)) return HapticLevel.high;
    const dismiss = {
      'skip',
      'back',
      'not now',
      'later',
      'تخطي',
      'رجوع',
    };
    if (dismiss.contains(t)) return HapticLevel.low;
    const high = [
      'delete',
      'remove',
      'cancel',
      'reject',
      'log out',
      'logout',
      'sign out',
      'signout',
      'deactivate',
      'terminate',
      'yes',
      'حذف',
      'إزالة',
      'ازالة',
      'إلغاء',
      'الغاء',
      'رفض',
      'خروج',
      'نعم',
    ];
    if (high.any(t.contains)) return HapticLevel.high;
    const medium = [
      'assign',
      'add',
      'create',
      'discard',
      'edit',
      'save',
      'submit',
      'confirm',
      'update',
      'upload',
      'new',
      'approve',
      'send',
      'apply',
      'إضافة',
      'اضافة',
      'إنشاء',
      'انشاء',
      'تعيين',
      'تعديل',
      'حفظ',
      'تأكيد',
      'إرسال',
      'ارسال',
      'تحديث',
      'رفع',
      'موافقة',
    ];
    if (medium.any(t.contains)) return HapticLevel.medium;
    return fallback;
  }

  static void forLabel(
    String? label, {
    HapticLevel fallback = HapticLevel.medium,
  }) =>
      level(levelForLabel(label, fallback: fallback));

  /// True for destructive "are you sure" wording (delete/remove/log out...).
  static bool isDestructiveText(String? text) {
    final t = (text ?? '').toLowerCase();
    const words = [
      'delete',
      'remove',
      'log out',
      'logout',
      'sign out',
      'حذف',
      'إزالة',
      'ازالة',
      'تسجيل الخروج',
    ];
    return words.any(t.contains);
  }
}

/// Standard haptic strengths (see [HapticController.low/medium/high]).
enum HapticLevel { low, medium, high }

/// Haptic strength used by [HapticController.triggerHapticFeedback].
/// Relocated from lib/core/enums/enum.dart, which was retired.
enum VibrateType { lightImpact, mediumImpact, heavyImpact }
