/// Module: GRC Policy Management
/// Description: Header row widget with avatar and Arabic version toggle.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, FlutterSwitch, CustomImagePicker
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Replaced the static avatar placeholder with
///                                CustomImagePicker for real image picking
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_header_widget.dart
/// Purpose: Contains PolicyHeaderWidget, the policy image picker and
///          "Create Arabic Version" toggle row at the top of the policy form.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'dart:io';

import 'package:demo_app/core/custom/46_custom_image_picker.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// class name: [PolicyHeaderWidget]
///
/// purpose: row containing the policy image picker (backed by
///          [CustomImagePicker]) and the "Create Arabic Version" toggle. The
///          owning page holds the isArabicEnabled/imageFile state and
///          receives changes via onArabicToggle/onImagePicked.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyHeaderWidget extends StatelessWidget {
  final bool isArabicEnabled;
  final ValueChanged<bool> onArabicToggle;
  final File? imageFile;
  final ValueChanged<File> onImagePicked;

  const PolicyHeaderWidget({
    super.key,
    required this.isArabicEnabled,
    required this.onArabicToggle,
    required this.onImagePicked,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImagePicker(
          radius: 30.r,
          badgeRadius: 11.r,
          imageFile: imageFile,
          onImagePicked: onImagePicked,
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
