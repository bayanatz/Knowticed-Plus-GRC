/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: custom_button_with_image.dart
/// Purpose: this is custom Button with image for reuse
/// Author: Amr Mesbah
/// Created at: 30/08/2025
library;

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget customButtonWithImage({
  required String title,
  required VoidCallback function,
  required TextStyle textStyle,
  double? width,
  double? height,
  double? space,
  double? radius,
  Color? color,
  required String image,
  double? widthImage,
  double? heightImage,
  Color? colorBorder,
  Color? svgColor, // optional color
}) {
  return GestureDetector(
    onTapDown: hapticDown(function, HapticLevel.low),
    onTap: function,
    child: Container(
      width: width ?? 135.sp,
      height: height ?? 38.sp,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomSvgImage.natural(
              assetPath: image,
              height: heightImage?.h ?? 20.sp,
              width: widthImage?.w ?? 20.sp,
              color: svgColor ?? AppColors.textButton,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: space ?? 8.sp),
          Text(title, style: textStyle),
        ],
      ),
    ),
  );
}
