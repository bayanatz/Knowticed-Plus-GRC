/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: gradient_container.dart
/// Purpose: Declares `GradientContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// ************************ FILe INFO ********************************///
/// File: gradiant_container.dart
/// Purpose: Contains the gradient container widget for the home screen
/// Author: Amr Mesbah
/// Refactored at: 9/2/2025
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/skeleton_home_controller.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';

class GradientContainer extends StatelessWidget {
  GradientContainer({super.key});
  final SkeletonHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    Theme.of(context).brightness == Brightness.light;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isEnglish
                    ? [
                        AppColors.white.withValues(alpha: 0.5),
                        AppColors.primary.withValues(alpha: 0.5),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.5),
                        AppColors.white.withValues(alpha: 0.5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 10.h, horizontal: orientation ? 30.w : 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.quote,
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton)),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("- ${controller.author}",
                        style: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton))
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: context.isEnglish ? 0 : null,
          right: context.isArabic ? 0 : null,
          child: CustomSvgImage.natural(
            assetPath: "assets/icons_assets/main_icons_assets/ic_gradient.svg",
            height: 25.h,
            color: AppColors.text,
            width: 25.h,
          ),
        ),
      ],
    );
  }
}
