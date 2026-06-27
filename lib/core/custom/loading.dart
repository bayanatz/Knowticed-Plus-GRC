import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get.dart';


Future showLoadingIndicator() {
  double size = 70;
  return Get.dialog(
    Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimary),
            backgroundColor: Colors.white60,
            strokeWidth: 2.0,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
  );
}

hideLoadingIndicator() {
  Get.back();
}
