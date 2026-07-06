/// ******************* FILE INFO *******************
/// File Name: custom_button.dart
/// Description: this is custom Button for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

Widget customButton({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  TextStyle? textStyle, // Optional override
}) {
  return GestureDetector(
    onTap: function,
    child: Container(
     // padding: EdgeInsets.symmetric(horizontal: 6.sp),
      width: width,
      height: height ?? 38.sp,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(radius),  // ✅ Remove .r here
      ),
      child: Center(
        child: Text(
          title,
          style: textStyle ??
              (AppTextStyles.font16BlackRegularCairo
                  .copyWith(color: AppColors.textButton)),
        ),
      ),
    ),
  );
}
