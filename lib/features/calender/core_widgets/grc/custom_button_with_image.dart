/// ******************* FILE INFO *******************
/// File Name: custom_button_with_image.dart
/// Description: Custom button with SVG image — ported from demo_app_plus grc module.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';

// ─── Animated wrapper ────────────────────────────────────────────────────────

class _AnimatedButtonWithImage extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptic;

  const _AnimatedButtonWithImage({
    required this.child,
    required this.onTap,
    this.enableHaptic = true,
  });

  @override
  State<_AnimatedButtonWithImage> createState() =>
      __AnimatedButtonWithImageState();
}

class __AnimatedButtonWithImageState extends State<_AnimatedButtonWithImage>
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
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.enableHaptic) {
      try {
        Get.find<HapticController>().triggerHapticFeedback(
          vibration: VibrateType.mediumImpact,
          hapticFeedback: HapticFeedback.mediumImpact,
        );
      } catch (_) {
        HapticFeedback.mediumImpact();
      }
    }
    await _controller.forward();
    widget.onTap();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}

// ─── Public function ──────────────────────────────────────────────────────────

Widget customButtonWithImageMas({
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
  Color? svgColor,
  bool enableHaptic = true,
}) {
  return _AnimatedButtonWithImage(
    onTap: function,
    enableHaptic: enableHaptic,
    child: Container(
      width: width ?? 100.w,
      height: height ?? 38.h,
      decoration: BoxDecoration(
        color: color,
        border: colorBorder != null ? Border.all(color: colorBorder) : null,
        borderRadius: BorderRadius.circular(radius ?? 8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            height: heightImage ?? 20.h,
            width: widthImage ?? 20.w,
            color: svgColor ?? AppColors.textButton,
            fit: BoxFit.fill,
          ),
          SizedBox(width: space ?? 8.sp),
          Text(title, style: textStyle),
        ],
      ),
    ),
  );
}
