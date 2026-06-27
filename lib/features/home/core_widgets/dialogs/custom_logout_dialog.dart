// ignore_for_file: deprecated_member_use

import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/enums/enum.dart';

// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/timeline_widget.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/generated/l10n.dart';


class CustomLogOutDialogBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color backgroundColor;
  final bool showButtons;
  final String buttonText;
  final Color buttonFontColor;
  final Color buttoncolor;
  final VoidCallback? onConfirm;

  const CustomLogOutDialogBox({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.backgroundColor,
    required this.showButtons,
    this.buttonText = 'Delete',
    this.buttoncolor = Colors.black,
    this.buttonFontColor = Colors.white,
    this.onConfirm,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      ButtonStyle buttonStyle(Color buttonColor) {
 
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, (isPortrait? 0.045.h : 0.06.h)) : Size(0.3.w, 0.04.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)));
  }
     
    
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        width: isTablet? (isPortrait? 0.7.w : 0.45.w) : null, 
        padding:   EdgeInsets.all(isTablet?20 : 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              imagePath,
              width: isPortrait? .09.h : 0.15.h,
              height: isPortrait? .09.h : 0.15.h,
            ),
           
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).logout,
                     textAlign: TextAlign.center,
                      style: StyleText.fontSize20Weight500.copyWith(
                          color: AppColors.text
                      )
                  ),
                  SizedBox(height: .02.h),
                  Text(
                    S.of(context).confirmLogout,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight500.copyWith(
                      color: AppColors.secondaryText
                    )
                  ),
                ],
              ),
            ),
            if (showButtons)
              Padding(
                padding: EdgeInsets.only(top:isTablet? (isPortrait? 0.025.h : 0.03.h) : 0.01.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: "Cancel".tr,
                        onTap: () {
                          hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact,
                          );
                          Navigator.pop(context, false);
                        },
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                            color: Colors.black
                        ),
                        buttonColor: AppColors.darkGrey,
                        height: 38.sp, // Match the original height
                      ),
                    ),
                    SizedBox(
                      width: 0.04.w,
                    ),
                    Expanded(
                      child: CustomButton(
                        buttonText: buttonText.tr,
                        onTap: onConfirm!,

                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton
                        ),
                        buttonColor: AppColors.primary,
                        height: 38.sp, // Match the original height
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
