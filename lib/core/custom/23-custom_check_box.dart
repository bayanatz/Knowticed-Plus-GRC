/// ******************* FILE INFO *******************
/// File Name: custom_check_box.dart
/// Description: Custom CheckBox widget with styling to responed to secondary color
/// Created by: Mohamed Elrashidy

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class CustomCheckBox extends StatelessWidget {
  CustomCheckBox(
      {this.size, required this.isSelected, this.borderColor, super.key});
  bool isSelected = false;
  Color? borderColor;
  double? size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 22.sp,
      height: size ?? 22.sp,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondaryPrimary : AppColors.transparent,
        borderRadius: BorderRadius.circular(4.r),
        border: isSelected
            ? null
            : Border.all(color:  AppColors.secondaryText.withOpacity(.5), width: 1.5.sp),
      ),
      child: Center(
        child: Icon(Icons.check_rounded,
            size: (size ?? 22.sp) - 7.sp,
            color: isSelected ? AppColors.white : AppColors.transparent),
      ),
    );
  }
}
