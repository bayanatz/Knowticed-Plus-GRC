import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomButtonWithIcon extends StatelessWidget {
  final String buttonText;
  final String imagePath;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final Color? textColor;
  final Color? imageColor;
  final bool hasIcon;
  final double? width;
  final double? height;

  const CustomButtonWithIcon({
    super.key,
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
    this.buttonColor,
    this.textColor,
    this.imageColor,
    this.hasIcon = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? 135.sp,
        height: height ?? 38.sp,
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon && imagePath.isNotEmpty)
              Center(
                child: SvgPicture.asset(
                  imagePath,
                  height: 20.sp,
                  width: 20.sp,
                  color: imageColor ?? AppColors.textButton,
                  fit: BoxFit.scaleDown,
                ),
              ),
            if (hasIcon && imagePath.isNotEmpty) SizedBox(width: 8.sp),
            Text(
              buttonText,
              style: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: textColor ?? AppColors.textButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

