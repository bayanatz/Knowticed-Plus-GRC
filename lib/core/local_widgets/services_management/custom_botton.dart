/// ******************* FILE INFO *******************
/// File Name: custom_button.dart
/// Description: this is custom Button for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

class _AnimatedButtonState extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButtonState({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedButtonState> createState() => __AnimatedButtonStateState();
}

class __AnimatedButtonStateState extends State<_AnimatedButtonState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {


    print("Trigger haptic feedback");
    // Trigger haptic feedback
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    await _controller.forward();
    widget.onTap();
    // Reset animation after navigation for when user comes back
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

Widget customButtonAnimation({
  required String title,
  required VoidCallback function,
  double? width,
  double? height,
  double radius = 8,
  Color? color,
  TextStyle? textStyle,
  double? paddingHorizontal,
}) {
  return _AnimatedButtonState(
    onTap: function,
    child: Container(
      width: width,
      height: height ?? 38.h,
      padding: width == null && paddingHorizontal != null
          ? EdgeInsets.symmetric(horizontal: paddingHorizontal)
          : null,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Text(
          title,
          style: textStyle ??
              (AppTextStyles.font16BlackRegularCairo.copyWith(
                color: AppColors.textButton,
              )),
        ),
      ),
    ),
  );
}
