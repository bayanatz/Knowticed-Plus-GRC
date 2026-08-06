// Moved from features/roles/r3_user_access/data/user_access_status.dart.
// The trailing `MyWidget` usage-example class was dropped - it was dead
// demo code, not part of the enum's API.

import 'dart:ui';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

enum UserAccessStatus {
  all,
  active,
  scheduled, // ✅ NEW: access granted but start date is still in the future
  inactive,
  expiringSoon;

  // ✅ SOLUTION 1: Method that takes BuildContext
  //
  // [context] is kept for API compatibility with existing callers; the colours
  // themselves come from AppColors, which already resolves per active theme.
  Color getColor(BuildContext context) {
    switch (this) {
      case UserAccessStatus.all:
        return AppColors.text;
      case UserAccessStatus.active:
        return AppColors.green;
      case UserAccessStatus.scheduled:
        return AppColors.orange; // ✅ Orange — matches getStatusColor("scheduled")
      case UserAccessStatus.inactive:
        return AppColors.red;
      case UserAccessStatus.expiringSoon:
        return AppColors.expiringSoon;
    }
  }
}
