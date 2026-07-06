import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:lottie/lottie.dart';


class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.subtitle,
    required this.title,
    required this.lottieAsset,
  });

  final String subtitle;
  final String title;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 0.3.w : 0.12.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: isTablet ? 0.4.h : 0.32.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w),
          child: Column(
            children: <Widget>[
              Transform.scale(
                scale: isTablet ? 1 : 1,
                child: Lottie.asset(
                  lottieAsset,
                  width: isTablet ? 0.15.w : 0.3.w,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.02.h),
                child: Text(
                  title.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? FontConstants.fontSize035.h
                        : FontConstants.fontSize025.h,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ),
              Text(
                subtitle.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: isTablet
                      ? FontConstants.fontSize025.h
                      : FontConstants.fontSize020.h,
                  height: isTablet ? null : 1.5,
                  fontWeight: Get.locale.toString().contains('en')
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: Theme.of(context).colorScheme.scrim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
