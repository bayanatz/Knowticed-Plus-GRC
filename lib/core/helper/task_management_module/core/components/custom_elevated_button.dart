// last Edit :16/August/2923 by mazen
// ignore_for_file: unnecessary_null_in_if_null_operators

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

// ignore: must_be_immutable
class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;
  final bool istrue;
  final double? height;
  final bool isGrey;
  ButtonStyle? buttonStyle;
  Color? textColor;
  final FontWeight? fontweight;
  final double? fontSize;
  final double? letterSpacing;
  final double? textHeight;
  final Widget? buttonWidget;
  final bool isButtonWidget;
  final String? widgetIcon;
  final double? iconHeight;

  CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.buttonText,
    this.buttonStyle,
    this.iconHeight,
    this.buttonWidget,
    this.fontSize,
    this.fontweight,
    this.textColor,
    this.isButtonWidget = false,
    this.height,
    this.letterSpacing,
    this.textHeight,
    this.widgetIcon,
    this.istrue = false,
    this.isGrey = false,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final HapticController hapticController = Get.put(HapticController());
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () {
          hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact);
          onPressed();
        },
        style: buttonStyle ??
            ElevatedButton.styleFrom(
              shadowColor: Colors.transparent,
              minimumSize: !istrue
                  ? Size(0.94.w, 0.060.h)
                  : Size(orientation == Orientation.portrait ? 0.7.w : 0.3.w,
                      orientation == Orientation.portrait ? 0.060.h : 0),
              backgroundColor:
                  !isGrey ? AppColors.signOut : AppColors.grey,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(6),
              )),
            ),
        child: isButtonWidget == true
            ? Row(
                children: <Widget>[
                  Transform.scale(
                    scale: 1.2,
                    child: SvgPicture.asset(widgetIcon as String,
                        height: iconHeight ?? null,
                        // ignore: deprecated_member_use
                        color: textColor ?? AppColors.colorBlack),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: Get.locale.toString().contains('en') ? 0.01.w : 0,
                        right:
                            Get.locale.toString().contains('en') ? 0 : 0.01.w),
                    child: Text(
                      buttonText as String,
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                          height: textHeight ?? 0.0018.h,
                          fontSize: FontConstants.fontSize015.w,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? AppColors.colorBlack),
                    ),
                  )
                ],
              )
            : Text(
                buttonText as String,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? fontSize ?? FontConstants.fontSize026.h
                        : fontSize ?? FontConstants.fontSize018.h,
                    color: textColor ?? AppColors.colorBlack,
                    height: textHeight ?? null,
                    /*color: Myclors.textmaincolor,*/
                    fontWeight: fontweight ??
                        FontWeight.lerp(
                            FontWeight.w500,
                            Get.locale.toString().contains('en')
                                ? FontWeight.w600
                                : FontWeight.w500,
                            0.5)!,
                    letterSpacing: letterSpacing ?? 1.2),
              ),
      ),
    );
  }
}
