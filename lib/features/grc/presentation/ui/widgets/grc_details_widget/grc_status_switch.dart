/// ************************* FILE INFO *************************** ///
/// File Name: grc_status_switch.dart
/// Purpose: This file contains the implementation of the GrcStatusSwitch widget, which provides a toggle switch for managing the status of GRC modules.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-29
library;

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

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
            SvgPicture.asset('assets/state/status.svg'),
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
