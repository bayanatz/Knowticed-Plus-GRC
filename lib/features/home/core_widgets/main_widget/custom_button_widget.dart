import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/theme/app_colors.dart';

/// Shared utility button used across skeleton pages.
Widget customButton({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  TextStyle? textStyle,
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
      width: width,
      height: height ?? 38.h,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: textStyle ??
            TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    ),
  );
}
