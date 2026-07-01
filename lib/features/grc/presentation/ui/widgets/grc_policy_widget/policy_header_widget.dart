/// Module: GRC Policy Management
/// Description: Header row widget with avatar and Arabic version toggle.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, FlutterSwitch
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_header_widget.dart
/// Purpose: Contains PolicyHeaderWidget, the avatar placeholder and
///          "Create Arabic Version" toggle row at the top of the policy form.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [PolicyHeaderWidget]
///
/// purpose: stateless row containing the policy avatar (with edit overlay)
///          and the "Create Arabic Version" toggle. The owning page holds
///          the isArabicEnabled state and receives changes via onArabicToggle.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyHeaderWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final VoidCallback? onImageTap;

  const PolicyHeaderWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.background,
              child: Icon(
                Icons.image_outlined,
                color: AppColors.secondaryText,
                size: 26.sp,
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: onImageTap,
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt,
                      color: Colors.white, size: 13.sp),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('Create Arabic Version'.tr),
            SizedBox(width: 10.w),
            FlutterSwitch(
              width: 38.sp,
              height: 22.sp,
              padding: 3.sp,
              borderRadius: 20.sp,
              toggleSize: 16.sp,
              activeColor: AppColors.secondaryPrimary,
              inactiveColor: Colors.grey.withOpacity(.16),
              value: isArabicEnabled,
              onToggle: onArabicToggle,
            ),
          ],
        ),
      ],
    );
  }
}
