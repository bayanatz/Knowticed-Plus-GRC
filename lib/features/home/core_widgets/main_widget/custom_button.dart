import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomButton extends StatefulWidget {
  CustomButton({
    required this.buttonText,
    required this.onTap,
    this.buttonColor,
    this.width,
    this.textStyle,
    this.horizontalPadding,
    this.height,
    this.padding,
    this.verticalPadding,
    this.isEnabled = true, // Added enabled state
  });

  final double? verticalPadding;
  final double? horizontalPadding;
  final String buttonText;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;
  final Color? buttonColor;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final bool isEnabled; // New parameter for enabled/disabled state

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.isEnabled
          ? () {
        // Haptic feedback can be added here
        /*HapticFeedbackHelper.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact,
              );*/
        widget.onTap();
      }
          : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: widget.padding ??
            EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
        height: widget.height?.h ?? 38.h,
        alignment: Alignment.center,
        width: widget.width?.w,
        decoration: BoxDecoration(
          color: widget.isEnabled
              ? (widget.buttonColor ?? AppColors.primary)
              : (widget.buttonColor ?? AppColors.primary).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        transform: _isPressed && widget.isEnabled
            ? Matrix4.translationValues(0, 1, 0)
            : Matrix4.identity(),
        child: FittedBox(
          child: Text(
            widget.buttonText,
            style: widget.textStyle ??
                AppTextStyles.font16BlackCairoMedium.copyWith(
                  color: widget.isEnabled
                      ? AppColors.textButton
                      : AppColors.textButton.withOpacity(0.5),
                ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}