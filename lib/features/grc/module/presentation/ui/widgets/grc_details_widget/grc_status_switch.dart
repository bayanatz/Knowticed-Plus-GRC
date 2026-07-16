/// Module: GRC Module Management
/// Description: Provides the status toggle row shown above the form in edit
///              mode, allowing the user to switch a GRC Module between Active
///              and Inactive.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, FlutterSwitch
/// Revision History: 2026-06-29 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_status_switch.dart
/// Purpose: Contains GrcStatusSwitch, a small row widget with a FlutterSwitch
///          for toggling GRC Module status in edit mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [GrcStatusSwitch]
///
/// purpose: renders a labeled toggle row for the GRC Module status field.
///          Shown only in edit mode; tapping the switch triggers [onToggle]
///          so the parent can show a confirmation dialog before committing.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 29/6/2026
class GrcStatusSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;

  const GrcStatusSwitch({
    super.key,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SvgPicture.asset('assets/icons_assets/data_grc_assets/icons_status.svg'),
            SizedBox(width: 10.w),
            Text('Status'.tr),
            SizedBox(width: 10.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: value,
              onToggle: onToggle,
            ),
          ],
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
