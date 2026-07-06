import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/local_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/local_widgets/reschedule_dialog.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

class CustomScheduleOrNowDialog extends StatefulWidget {
  CustomScheduleOrNowDialog({
    super.key,
    required this.yesOnPressed,
    required this.titleText,
    required this.bodyText,
    this.isNow = false,
    required this.onDateTimeSelected,
    this.onDailogPressed,
  });

  final void Function() yesOnPressed;
  final String titleText;
  final String bodyText;
  final bool? isNow;
  final Function(String) onDateTimeSelected;
  final Function()? onDailogPressed;
  @override
  State<CustomScheduleOrNowDialog> createState() =>
      _CustomScheduleOrNowDialogState();
}

class _CustomScheduleOrNowDialogState extends State<CustomScheduleOrNowDialog> {
  ButtonStyle buttonStyle(Color buttonColor) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.25.w, 0.04.h),
        maximumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.25.w, 0.04.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }


  @override
  Widget build(BuildContext context) {
    String firstWord = widget.titleText.split(' ').first;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isPortrait ? 0.1.w : 0.25.w) : 0.04.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 0.02.w : 0.04.w,
              vertical: isTablet ? (isPortrait ? 0.025.h : 0.03.h) : 0.015.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.titleText.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (isPortrait
                            ? FontConstants.fontSize023.h
                            : FontConstants.fontSize035.h)
                        : FontConstants.fontSize022.h,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface),
              ),
              SizedBox(
                height: 0.01.h,
              ),
              Text(
                widget.bodyText.tr,
                textAlign: isTablet ? TextAlign.center : TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? (isPortrait
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize028.h)
                        : FontConstants.fontSize018.h,
                    fontWeight: FontWeight.w600,
                    height: isTablet ? 1.5 : 1.5,
                    color: Theme.of(context).colorScheme.scrim),
              ),
              SizedBox(
                height: isTablet ? 0.02.h : 0.01.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 0.0.w : 0.0.w,
                ),
                child: Row(
                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: MainCustomIconButton(
                        buttonStyle: buttonStyle(AppColors.colorWhiteDark),
                        onPressed: widget.isNow == true
                            ? () {
                                Navigator.of(context).pop();
                              }
                            : () {
                                Navigator.of(context).pop();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return RescheduleDialog(
                                        dialogName: firstWord == "Reactivate"
                                            ? "Reactivation"
                                            : firstWord == "Deactivate"
                                                ? "Deactivation"
                                                : "",
                                        onButtonPressed: () {
                                          if (widget.onDailogPressed != null) {
                                            widget.onDailogPressed!();
                                          }
                                        },
                                        confirmationDialogBody:
                                            "Are You Sure You Want To ${firstWord} This Account At",
                                        onDateTimeSelected:
                                            widget.onDateTimeSelected,
                                      );
                                    });
                              },
                      
                        buttonText: widget.isNow == true
                            ? "No".tr
                            : "${"Schedule".tr} ${firstWord.tr}",
                      
                      ),
                    ),
                    Container(width: 0.06.w),
                    Expanded(
                      child: MainCustomIconButton(
                        buttonStyle: buttonStyle(AppColors.bubbleColor),
                        onPressed: widget.yesOnPressed,
                     
                        buttonText: widget.isNow == true
                            ? "Yes".tr
                            : "${firstWord.tr} ${"Now".tr}",
                       
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
