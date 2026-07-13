/// ************************ FILe INFO ********************************///
/// File: gradiant_container.dart
/// Purpose: Contains the gradient container widget for the home screen
/// Author: Mohamed Elrashidy
/// Refactored at: 9/2/2025
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/skeleton_home_controller.dart';

class GradientContainer extends StatelessWidget {

  GradientContainer({Key? key}) : super(key: key);
  SkeletonHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
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
                colors: Get.locale.toString().contains('en')
                    ? [
                        AppColors.white.withOpacity(0.5),
                        AppColors.primary.withOpacity(0.5),
                      ]
                    : [
                        AppColors.primary.withOpacity(0.5),
                       AppColors.white.withOpacity(0.5),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(
                vertical: 10.h, horizontal: orientation ? 30.w : 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.quote.tr,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton
                  )
                ),
                SizedBox(height:  10.h ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "- ${controller.author.tr}",
                      style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton
                      )
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: Get.locale.toString().contains('en') ? 0 : null,
          right: Get.locale.toString().contains('ar') ? 0 : null,
          child: SvgPicture.asset(
            "assets/icons_assets/home_assets/gradiantIcon.svg",
            height: 25.h,
            color: AppColors.text,
            width: 25.h,
          ),
        ),
      ],
    );
  }
}
