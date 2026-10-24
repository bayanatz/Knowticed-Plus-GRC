/// Module: Settings · Presentation · Widgets · Custom Icon Container
/// Description: Settings page (presentation/ui/pages). See class doc for details.
/// Author: Knowticed Team
/// Date: 26/06/2026
/// Dependencies: see imports
/// Revision History:
///   - 26/06/2026 (Amr Mesbah): Added Module header and FILE INFO block.
///
/// ************************ FILE INFO ****************************///
/// File Name: custom_icon_container.dart
/// Purpose: Custom Icon Container widget.
/// Author: Knowticed Team
/// Created At: 26/06/2026
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CustomIconContainer extends StatelessWidget {
  final String text;
  final String? image;
  final VoidCallback? onPressed;
  final bool isEdit;
  final bool isEditIcon;
  final bool isSmallerFont;

  const CustomIconContainer({
    super.key,
    required this.text,
    this.image,
    this.onPressed,
    this.isEdit = false,
    this.isEditIcon = false,
    this.isSmallerFont = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      width: isEdit
          ? isTablet
              ? orientation == Orientation.portrait
                  ? 0.29.w
                  : (0.32.w)
              : 0.4.w
          : 0.16.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.darkerGrey,
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(0.02.h),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.barrierColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 0.17.h,
              child: GestureDetector(
                onTapDown: hapticDown(onPressed, HapticLevel.medium),
                onTap: onPressed,
                child: Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.barrierColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        height: 0.17.h,
                        child: image == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.asset(
                                  'assets/icons_assets/main_icons_assets/img_image_placeholder_large.png',
                                  fit: BoxFit.fill,
                                ),
                              )
                            : image!.contains('assets')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6.0),
                                    child: Image.asset(
                                      image!,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(6.0),
                                    child: Image.network(
                                      image!,
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                    Positioned(
                      top: 0.02.h,
                      right: orientation == Orientation.portrait
                          ? 0.022.w
                          : 0.02.h,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primary),
                        child: Padding(
                          padding: EdgeInsets.all(
                              orientation == Orientation.portrait ? 4 : 2),
                          child: Center(
                            child: CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/settings_assets/ic_action_add_thin.svg",
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ) /*CustomSvgImage.natural(
                          assetPath: isEditIcon
                              ? 'assets/icons_assets/settings_assets/ic_action_add_badge.svg'
                              : 'assets/icons_assets/settings_assets/ic_addition.svg',
                          color: isEditIcon
                              ? null
                              : image != null
                                  ? AppColors.barrierColor
                                  : AppColors.colorBlack,
                          height: 0.035.h,
                        )*/
                      ,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 0.01.h),
            child: Text(
              text,
              style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: !kpIsPhoneLayout(context)
                      ? (orientation == Orientation.portrait ? 14.sp : 18.sp)
                      : isSmallerFont
                          ? 12.sp
                          : 14.sp,
                  color: !AppTheme.isDark
                      ? AppColors.colorBlack
                      : AppColors.colorWhiteDark,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
