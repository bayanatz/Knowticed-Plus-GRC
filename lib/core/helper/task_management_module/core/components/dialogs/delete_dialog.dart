import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_elevated_button.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({
    super.key,
    required this.yesOnPressed,
    required this.deleteTitleText,
    required this.deleteText,
    this.isDeleteDialog = true,
  });

  final void Function() yesOnPressed;
  final String deleteTitleText;
  final String deleteText;
  final bool? isDeleteDialog;
  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  ButtonStyle buttonStyle(Color buttonColor) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.3.w, 0.05.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }

  final HapticController hapticController = Get.put(HapticController());
  MainCoreEmployeeController addEmployeeController = Get.find();
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (orientation ? 0.22.w : 0.33.w) : 0.15.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
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
                    vertical:
                        isTablet ? (orientation ? 0.03.h : 0.0.h) : 0.04.h),
                child: Transform.scale(
                  scale: isTablet ? (orientation ? 2 : 0.9) : 2,
                  child: Lottie.asset(
                    widget.isDeleteDialog == false
                        ? "assets/lottie_assets/main_lottie_assets/images_attention.json"
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
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? (orientation
                              ? FontConstants.fontSize025.h
                              : FontConstants.fontSize035.h)
                          : FontConstants.fontSize022.h,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              Text(
                widget.deleteText.tr,
                textAlign: isTablet ? TextAlign.center : TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (orientation
                            ? FontConstants.fontSize022.h
                            : FontConstants.fontSize030.h)
                        : FontConstants.fontSize020.h,
                    fontWeight: FontWeight.w600,
                    height: isTablet ? 1.5 : 1.5,
                    color: Theme.of(context).colorScheme.scrim),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.025.h),
                child: Row(
                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CustomElevatedButton(
                        buttonStyle: buttonStyle(AppColors.colorGreydark),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        fontSize: isTablet
                            ? (orientation
                                ? FontConstants.fontSize022.h
                                : FontConstants.fontSize025.h)
                            : FontConstants.fontSize021.h,
                        buttonText: "No".tr,
                        textColor: AppColors.colorWhite,
                        fontweight: FontWeight.w600,
                      ),
                    ),
                    Container(width: 0.025.w),
                    Expanded(
                      child: CustomElevatedButton(
                        buttonStyle: buttonStyle(AppColors.bubbleColor),
                        onPressed: widget.yesOnPressed,
                        buttonText: "Yes".tr,
                        fontSize: isTablet
                            ? (orientation
                                ? FontConstants.fontSize022.h
                                : FontConstants.fontSize025.h)
                            : FontConstants.fontSize021.h,
                        fontweight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
