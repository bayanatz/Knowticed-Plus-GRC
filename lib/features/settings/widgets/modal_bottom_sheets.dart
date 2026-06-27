import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:lottie/lottie.dart';



///  Developer's Name: Bassel Attia
///  Date: 5/8/2023
///  App Version : demo_app V1
///  Date of Last Edit: 5/8/2023
///
/// This mixin shows a modal bottom sheet with a check mark and a thank you after
/// an operation is done. It's used in PaymentScreen after making a payment and on
/// subscribing to a plan.
mixin ModalBottomSheets {
  void showDoneModalBottomSheet(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    showModalBottomSheet(
      context: context,
      barrierColor: AppColors.colorGrey.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.030.h, vertical: 0.020.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/images/check.json',
                  width: 0.42.w, height: 0.17.h),
              SizedBox(height: 0.020.h),
              Text(
                'Thank You'.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize035.h,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.020.h),
              Text(
                "We'd love to hear more about your service".tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize020.h,
                  color: AppColors.colorDarkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.020.h),
              SizedBox(
                width: double.infinity,
                child: MainCustomIconButton(
                    buttonText: "Done".tr,
                    onPressed: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback: HapticFeedback.heavyImpact);
                      //put here the navigation that goes to the screen of services or saved services according to the case
                      Navigator.pop(context);
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
