import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/helper/main_helper/spacing_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_weights.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/messaging_custom_button.dart';
import 'package:grc_module/generated/l10n.dart';

//Youssef Ashraf,mohamed mohy
///Default Result Dialog after specific Action has been performed
class DefaultDialog extends StatelessWidget {
  final dynamic Function()? onConfirm;
  final String? lottieAsset, svgAsset;
  final String? title;
  final String? subTitle;
  final bool showButtons;
  final bool autoClose;
  final String? okButtonText;
  final String? cancelButtonText;
  final double? width, height;
  final Widget? customWidget, customIconWidget;

  const DefaultDialog({
    super.key,
    this.onConfirm,
    this.lottieAsset,
    this.title,
    this.subTitle,
    this.showButtons = false,
    this.okButtonText,
    this.cancelButtonText,
    this.autoClose = true,
    this.width,
    this.svgAsset,
    this.customWidget,
    this.customIconWidget,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (autoClose) {
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.field,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 8.h,
        horizontal: 8.w,
      ),
      width: width ?? (ContextExtension(context).isTablett ? 410 : 343),
      height: height,
      child: customWidget ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottieAsset != null || svgAsset != null)
                Container(
                  alignment: Alignment.center,
                  height: 100.h,
                  width: 100.w,
                  margin: EdgeInsets.only(left: 8.w, right: 8.w),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
                  child: lottieAsset != null
                      ? LottieBuilder.asset(lottieAsset!,
                          frameRate: const FrameRate(120))
                      : SvgPicture.asset(
                          svgAsset!,
                          height: 50.h,
                          width: 50.w,
                        ),
                ),
              if (customIconWidget != null) customIconWidget!,

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(fontSize: 20.sp, height: 1),
                    ),
                  if (title != null) SizedBox(height: 20.sp),
                  if (subTitle != null)
                    Text(
                      subTitle!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font14SecondaryBlackCairoRegular
                          .copyWith(
                        height: 1,
                        fontWeight: AppFontWeights.medium,
                      ),
                    ),
                  if (!showButtons && subTitle != null) SizedBox(height: 30.sp),
                  if (showButtons)
                    Column(
                      children: [
                        verticalSpace(15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              width: ContextExtension(context).isPhone ? 130.w : 120.w,
                              buttonColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[400] : Colors.grey[700],
                              textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                                color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                              ),
                              height: 38,
                              buttonText: cancelButtonText ?? S.of(context).no,
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            horizontalSpace(30),
                            CustomButton(
                              width: ContextExtension(context).isPhone ? 130.w : 120.w,
                              height: 38,
                              buttonText: okButtonText ?? S.of(context).yes,
                              buttonColor: AppColors.primary,
                              onTap: () {
                                Navigator.of(context).pop();

                                onConfirm?.call();
                              },
                            ),
                          ],
                        ),
                        verticalSpace(15),

                      ],
                    ),
                ],
              ),
            ],
          ),
    );
  }
}
