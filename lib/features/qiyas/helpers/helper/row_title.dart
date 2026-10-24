import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/bread_scrum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/constants/image_paths.dart';

Row titleRow(
    BuildContext context, bool orientation, String title, Function()? onTap,
    {bool hasArrow = true,
    bool scrum = false,
    bool isQiyasMode = false,
    List<String>? titles,
    List<Function()?>? functions}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      scrum == true
          ? const SizedBox.shrink()
          : hasArrow
              ? GestureDetector(
                  onTap: () {
                    onTap!();
                    // hapticController.triggerHapticFeedback(
                    //     vibration: VibrateType.lightImpact,
                    //     hapticFeedback: HapticFeedback.lightImpact);
                  },
                  child: Transform.rotate(
                    angle: isQiyasMode || Get.locale.toString().contains('ar')
                        ? 3.13
                        : 0,
                    child: Transform.scale(
                      scale: isQiyasMode
                          ? 0.001.h
                          : orientation
                              ? 0.0014.h
                              : 0.0023.h,
                      child: SvgPicture.asset(
                        // ignore: deprecated_member_use
                        color: AppColors.text,
                        ImagePaths.getImagePath(
                          context,
                          'back_icon',
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
      scrum == true
          ? const SizedBox.shrink()
          : hasArrow
              ? SizedBox(
                  width: 0.01.w,
                )
              : const SizedBox.shrink(),
      scrum == true
          ? BreadCrumbsComponent(
              isQiyasMode: isQiyasMode,
              titles: titles!,
              onTaps: functions!,
            )
          : Text(
              title.tr,
              style: StyleText.fontSize16Weight400.copyWith(
                fontSize: orientation ? 18.sp : 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                height: 1.8,
                color: AppColors.text,
              ),
            ),
    ],
  );
}
