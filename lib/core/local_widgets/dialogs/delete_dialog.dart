import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/local_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/animation/app_animations.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/helper/organization_chart_module/presentation/controller/employee_controller.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/helper/inventory_module/core/custom_button_widget.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

class DeleteDialog extends StatefulWidget {
  DeleteDialog({
    super.key,
    required this.yesOnPressed,
    required this.deleteTitleText,
    required this.deleteText,
    this.noOnPressed,
    this.isDeleteDialog = true,
    this.lottiePhoto,
    this.scale,
  });
  final void Function()? noOnPressed;
  final void Function() yesOnPressed;
  final String deleteTitleText;
  final String deleteText;
  final bool? isDeleteDialog;
  final String? lottiePhoto;
  final double? scale;

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  EmployeeController addEmployeeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return ShakeOnce(child: Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (orientation ? 0.22.w : 0.33.w) : 0.15.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: isTablet
                        ? (orientation ? 0.03.h : 0.0.h)
                        : 0.04.h),
                child: Transform.scale(
                  scale:
                  isTablet ? (orientation ? 2 : 0.9) : widget.scale ?? 2,
                  child: Lottie.asset(
                    widget.isDeleteDialog == false
                        ? widget.lottiePhoto ?? "assets/lottie_assets/main_lottie_assets/lottie_attension.json"
                        : "assets/lottie_assets/main_lottie_assets/lottie_trash.json",
                    width: 0.1.w,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              SizedBox(
                height: isTablet ? (orientation ? 0.03.h : 0.02.h) : 0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: orientation ? 0.015.h : 0.015.h),
                child: Text(
                  widget.deleteTitleText.tr,
                  style: AppTextStyles.font23BlackRegularCairo.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                widget.deleteText.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.font20BlackCairoMedium.copyWith(
                  color: AppColors.secondaryText,
                ),

              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: isTablet
                        ? (orientation ? 0.015.h : 0.015.h)
                        : 0.005.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: customButton(
                        title: "No".tr,
                        function: () {
                          Navigator.of(context).pop();
                          widget.noOnPressed?.call();
                        },
                        height: 38.h,
                        radius: 8.r,
                        color: lightMode
                            ? Colors.grey[400]!
                            : Colors.grey[700]!,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: lightMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    Container(width: 0.025.w),
                    Expanded(
                      child: customButton(
                        title: "Yes".tr,

                        height: 38.h,
                        textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
                          color: AppColors.textButton
                        ),
                        function: widget.yesOnPressed,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}