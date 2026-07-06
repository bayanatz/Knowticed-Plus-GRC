import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';

Future showLoadingIndicator() {
  double size = 70;
  return Get.dialog(
    Scaffold(
      backgroundColor: AppColors.transparent,
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
            backgroundColor: AppColors.white.withOpacity(0.6),
            strokeWidth: 2.0,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: AppColors.totalBlack.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
  );
}

hideLoadingIndicator() {
  Get.back();
}
