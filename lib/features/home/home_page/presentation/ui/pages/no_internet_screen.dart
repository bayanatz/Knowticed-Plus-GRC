import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // done
    return Dialog(

      // done
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      backgroundColor: AppColors.background,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.15.w : 0.25.w) : .1.w,
        vertical: isTablet ? (0.25.h) : .35.h,
      ),
      child: PopScope(
       
        onPopInvoked: (x){},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: isTablet ? (isPortrait ? 2.5 : 1.5) : 1.2,
                child: Lottie.asset(
                  "assets/lottie_assets/main_lottie_assets/internet.json",
                  width: isTablet ? 0.15.w : 0.3.w,
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(
                  height: isTablet && isPortrait
                      ? 0.15.h
                      : isTablet
                          ? 0.1.h
                          : 0.05.h),
              Text(
                'Can\'t Connect .. Check Internet'.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: isTablet
                      ? (isPortrait
                          ? FontConstants.fontSize025.h
                          : FontConstants.fontSize032.h)
                      : FontConstants.fontSize020.h,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
