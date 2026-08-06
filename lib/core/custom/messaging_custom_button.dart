import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grc_module/core/helper/main_helper/haptic_feedback_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

class CustomButton extends StatefulWidget {
  CustomButton(
      {required this.buttonText,
      required this.onTap,
      this.buttonColor,
      this.width,
      this.textStyle,
      this.horizontalPadding,
      this.height,
      this.verticalPadding});
  double? verticalPadding;
  double? horizontalPadding;
  String buttonText;
  var onTap;
  Color? buttonColor;
  TextStyle? textStyle;
  double? width;
  double? height;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedbackHelper.triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
        widget.onTap();
      },
      splashColor: Colors.transparent,
      child: Container(
        height: widget.height?.sp,
        alignment: Alignment.center,
        width: widget.width?.w,
        padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding ?? 24.sp,
            vertical: widget.verticalPadding ?? 8.sp),
        decoration: BoxDecoration(
          color: widget.buttonColor ?? AppColors.primary,
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: FittedBox(
          child: Text(
            widget.buttonText,
            style: widget.textStyle ??
                AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.textButton,
                ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
