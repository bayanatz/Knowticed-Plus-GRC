import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/events/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:demo_app/core/custom/33-custom_haptic.dart';

// ignore: must_be_immutable
class DeleteMemberDialog extends StatefulWidget {
  DeleteMemberDialog(
      {super.key,
      this.userName,
      required this.title,
      required this.subtitle,
      required this.yesText,
      required this.onPressed,
      required this.lottieUrl,
      this.width,
      this.scale,
      this.index});
  final String? userName;
  int? index;
  final String title;
  final String subtitle;
  final String yesText;
  Function() onPressed;
  final String lottieUrl;
  double? scale;
   double? width;

  @override
  State<DeleteMemberDialog> createState() => _DeleteMemberDialogState();
}

class _DeleteMemberDialogState extends State<DeleteMemberDialog> {
  ButtonStyle buttonStyle(Color buttonColor) {
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: Size(0.1.w, 0.053.h),
        shape: RoundedRectangleBorder(
            side: buttonColor == AppColors.lightPrimary
                ? BorderSide.none
                : BorderSide(color: AppColors.colorBlack, width: 1.5),
            borderRadius: BorderRadius.circular(8)));
  }

  @override
  Widget build(BuildContext context) {
     bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? (isPortrait? 0.15.w : 0.3.w) : 0.05.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal:isTablet?  0.02.w : 0.03.w, vertical: isTablet? 0.02.h : 0.025.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical:isTablet? 0.015.h : 0.03.h),
                child: Transform.scale(
                  scale:widget.scale??( isTablet? (isPortrait ? 1.4  : 1.5) : 1.8),
                  child: Lottie.asset(
                    widget.lottieUrl,
                    width:widget.width?? (isTablet? (isPortrait ? 0.2.w  : 0.1.w ): 0.12.h),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.02.h),
                child: Text(
                  widget.title.tr,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet? (isPortrait ? FontConstants.fontSize022.h : FontConstants.fontSize035.h) : FontConstants.fontSize022.h,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
              Text(
                widget.subtitle.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet? (isPortrait ? FontConstants.fontSize018.h : FontConstants.fontSize025.h): FontConstants.fontSize018.h,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: AppColors.colorGrey),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.025.h),
                child: Row(
                  // direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: MainCustomIconButton(
                        buttonStyle: ElevatedButton.styleFrom(
                          minimumSize: Size(0.7.w, isTablet? (isPortrait? 0.045.h : 0.055.h) : 0.045.h),
                          backgroundColor: AppColors.colorWhite,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColors.lightPrimary,),
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              )),
                        ),
                        onPressed: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.lightImpact,
                              hapticFeedback: HapticFeedback.lightImpact);
                          Navigator.of(context).pop();
                        },
                        buttonText: "No".tr,
          
                      ),
                    ),
                     SizedBox(width: 0.025.w),
                    Expanded(
                      child: MainCustomIconButton(
                          buttonStyle: ElevatedButton.styleFrom(
                          minimumSize: Size(0.7.w, isTablet? (isPortrait? 0.045.h : 0.055.h) : 0.045.h),
                          backgroundColor: AppColors.lightPrimary,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColors.lightPrimary,),
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              )),
                        ),
                        onPressed: widget.onPressed,
                        buttonText: widget.yesText.tr,
                    
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
