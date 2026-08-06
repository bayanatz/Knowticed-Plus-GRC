/// ************************* FILE INFO *************************
/// File Name: 35-custom_search_widget_custom.dart
/// purpose: app custom search text field (uses CustomTextField)
/// Created by: Mohamed Elrashidy
/// Created on: 5/5/2025
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/33-custom_haptic.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';

class AppSearchTextField extends StatelessWidget {
  AppSearchTextField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.fillColor,
    this.hintText, // ✅ Added optional hint parameter
    this.borderRadius,
  });

  final TextEditingController controller;
  final Color? fillColor;
  final dynamic Function(String)? onChanged;
  final String? hintText; // ✅ Optional hint text
  final BorderRadius? borderRadius;

  /// Figma spec (MESBAH / node 6550-8690): hint & icon gray.
  static const Color _figmaGrey = Color(0xFF797979);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        controller: controller,
        onChanged: onChanged,
        hint: hintText ?? S.of(context).search, // ✅ Use custom hint or default to search
        maxLines: 1,
        fillColor: fillColor ?? AppColors.card,
        // Figma: corner radius 16
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        // Figma: padding 16 horizontal / 8 vertical
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        hintStyle: StyleText.fontSize14Weight500.copyWith(
          height: 1,
          color: AppTheme.isDark ? AppColors.lightGrey : _figmaGrey,
        ),
        prefixIcon: CustomSvgImage(
   assetPath: "assets/icons_assets/main_icons_assets/search_magnifier_alt.svg",
   width: 16.w,
   height: 16.h,
   fit: BoxFit.contain,
   colorFilter: ColorFilter.mode(
            AppTheme.isDark ? AppColors.lightGrey : _figmaGrey,
            BlendMode.srcIn,
          ),
 ),
        onTap: () {
          hapticController.triggerHapticFeedback(
            vibration: VibrateType.lightImpact,
            hapticFeedback: HapticFeedback.lightImpact,
          );
        },
      ),
    );
  }
}
