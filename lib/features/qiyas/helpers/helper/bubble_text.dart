import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class BubbleText extends StatelessWidget {
  const BubbleText({required this.text, required this.onTap, super.key});
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    // remove from text new line characters and trim the text
    final String oneLineText = text.replaceAll('\n', ' ').trim();
    return Container(
      padding: EdgeInsets.all(4.sp),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 5.sp,
        children: [
          Text(oneLineText,
              maxLines: 1,
              style: StyleText.fontSize14Weight500.copyWith(height: 1.3)),
          InkWell(
            onTapDown: hapticDown(onTap, HapticLevel.high),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: SvgPicture.asset(
                'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg',
                colorFilter: ColorFilter.mode(AppColors.red, BlendMode.srcIn),
                width: 12.sp,
                height: 12.sp,
              ),
            ),
          )
        ],
      ),
    );
  }
}
