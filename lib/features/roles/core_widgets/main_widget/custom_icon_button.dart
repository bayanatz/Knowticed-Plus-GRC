import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    required this.iconPath,
    required this.buttonText,
    required this.onTap,
    this.buttonColor,
    this.textStyle,
    this.width,
    this.height,
    this.iconColor,
    this.isEnabled = true,
    this.useDisappearAnimation = true, // ✅ NEW: Control animation type
  });

  final String iconPath;
  final String buttonText;
  final VoidCallback onTap;
  final Color? buttonColor;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? width;
  final double? height;
  final bool isEnabled;
  final bool useDisappearAnimation; // If false, uses press animation only

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with SingleTickerProviderStateMixin {
  // ✅ Initialize HapticController
  late final HapticController hapticController;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Initialize haptic controller
    hapticController = Get.put(HapticController());

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.useDisappearAnimation) {
      // ✅ DISAPPEAR ANIMATION (like second implementation)
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInBack,
        ),
      );

      _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ),
      );

      _pressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
    } else {
      // ✅ PRESS ANIMATION (subtle press effect)
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );

      _opacityAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);

      _pressAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    if (!widget.isEnabled) return;

    // Only use press animation for non-disappear mode
    if (!widget.useDisappearAnimation) {
      setState(() => _isPressed = true);
      await _controller.forward();
    }
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    if (!widget.isEnabled) return;

    // Only use press animation for non-disappear mode
    if (!widget.useDisappearAnimation) {
      setState(() => _isPressed = false);
      await _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isEnabled) return;

    // Only use press animation for non-disappear mode
    if (!widget.useDisappearAnimation) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  Future<void> _onTap() async {
    if (!widget.isEnabled) return;

    // ✅ Trigger haptic feedback
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    if (widget.useDisappearAnimation) {
      // ✅ Play disappear animation
      await _controller.forward();
      widget.onTap();

      // Reset animation after action
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _controller.reset();
      }
    } else {
      // Just execute callback (press animation handled by onTapDown/Up)
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveButtonColor = widget.buttonColor ?? AppColors.primary;
    final effectiveIconColor = widget.iconColor ?? AppColors.textButton;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _pressAnimation.value),
              child: Opacity(
                opacity: widget.isEnabled
                    ? _opacityAnimation.value
                    : 0.5,
                child: Container(
                  alignment: Alignment.center,
                  width: widget.width?.w,
                  height: widget.height?.h ?? 36.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  decoration: BoxDecoration(
                    color: widget.isEnabled
                        ? effectiveButtonColor
                        : effectiveButtonColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.r),

                  ),
                  child: FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10.sp,
                      children: [
                        SvgPicture.asset(
                          widget.iconPath,
                          width: 20.sp,
                          height: 20.sp,
                          color: widget.isEnabled
                              ? effectiveIconColor
                              : effectiveIconColor.withOpacity(0.6),
                        ),
                        if (widget.buttonText.isNotEmpty)
                          Text(
                            widget.buttonText,
                            style: widget.textStyle ??
                                AppTextStyles.font16BlackMediumCairo.copyWith(
                                  color: widget.isEnabled
                                      ? AppColors.textButton
                                      : AppColors.textButton.withOpacity(0.6),
                                ),
                            maxLines: 1,
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}