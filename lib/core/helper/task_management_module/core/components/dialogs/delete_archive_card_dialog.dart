import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/helper/task_management_module/core/components/custom_elevated_button.dart';

class DeletOrArchiveDialog extends StatefulWidget {
  DeletOrArchiveDialog(
      {super.key,
      this.isDelete,
      this.isCheckListElement,
      this.yesOnPressed,
      this.isAttachment});
  bool? isDelete = false;
  bool? isCheckListElement = false;
  bool? isAttachment = false;
  final VoidCallback? yesOnPressed;
  @override
  State<DeletOrArchiveDialog> createState() => _DeletOrArchiveDialogState();
}

class _DeletOrArchiveDialogState extends State<DeletOrArchiveDialog> {
  ButtonStyle buttonStyle(Color buttonColor) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.3.w, 0.05.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }

  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 0.3.w : 0.15.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        height: isTablet ? 0.42.h : 0.36.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: isTablet ? 0.015.h : 0.04.h),
                child: Transform.scale(
                  scale: isTablet ? 0.7 : 2,
                  child: Lottie.asset(
                    "assets/lottie_assets/main_lottie_assets/lottie_trash.json",
                    width: 0.1.w,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.02.h),
                child: Text(
                  widget.isDelete == true
                      ? "Delete Card".tr
                      : widget.isCheckListElement == true
                          ? "Delete Element".tr
                          : widget.isAttachment == true
                              ? "Delete Attachments".tr
                              : "Archive Card".tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? FontConstants.fontSize035.h
                          : FontConstants.fontSize022.h,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              Text(
                widget.isDelete == true
                    ? "Are You Sure you want to Delete this card?".tr
                    : widget.isCheckListElement == true
                        ? "Are You Sure you want to Delete this element?".tr
                        : widget.isAttachment == true
                            ? "Are You Sure you want to Delete these attachments?"
                                .tr
                            : "Are You Sure you want to Archive this card?".tr,
                textAlign: isTablet ? null : TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? FontConstants.fontSize025.h
                        : FontConstants.fontSize020.h,
                    fontWeight: FontWeight.w600,
                    height: isTablet ? null : 1.5,
                    color: Theme.of(context).colorScheme.scrim),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.025.h),
                child: Row(
                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomElevatedButton(
                      buttonStyle: buttonStyle(AppColors.bubbleColor),
                      onPressed: widget.yesOnPressed!,
                      buttonText: "Yes".tr,
                      fontSize: isTablet
                          ? FontConstants.fontSize025.h
                          : FontConstants.fontSize021.h,
                      fontweight: FontWeight.w600,
                    ),
                    Container(width: 0.025.w),
                    CustomElevatedButton(
                      buttonStyle: buttonStyle(AppColors.colorGreydark),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      fontSize: isTablet
                          ? FontConstants.fontSize025.h
                          : FontConstants.fontSize021.h,
                      buttonText: "No".tr,
                      textColor: AppColors.colorWhite,
                      fontweight: FontWeight.w600,
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
