import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/theme/app_colors.dart';

// ignore: must_be_immutable
class MainCustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? buttonText;
  final double? height;
  final bool isDisabled;
  ButtonStyle? buttonStyle;
  final String? widgetIcon;
  final double? iconHeight;
  final TextStyle? textStyle;

  MainCustomIconButton({
    super.key,
    required this.onPressed,
    this.buttonText,
    this.buttonStyle,
    this.iconHeight,
    this.height,
    this.widgetIcon,
    this.textStyle,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    return SizedBox(
      height: height,
      child: ElevatedButton(
          onPressed: () {
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.heavyImpact,
                hapticFeedback: HapticFeedback.heavyImpact
            );
            onPressed();
          },
          style: buttonStyle ??
              ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    !isDisabled ? AppColors.primary : AppColors.greyBack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.r))),
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            (widgetIcon!=null)?  SvgPicture.asset(widgetIcon as String,
                  height: iconHeight ?? 20.h,
                  width: iconHeight ?? 20.h,
                  color:  AppColors.black):Container(),
              buttonText!=null
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: Get.locale.toString().contains('en') ? 10.w : 0,
                          right:
                              Get.locale.toString().contains('en') ? 0 : 10.w),
                      child: Text(
                        buttonText!.tr,
                        style: textStyle ??
                            AppTextStyles.font16BlackRegularCairo
                                .copyWith(color: AppColors.textButton),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          )),
    );
  }
}
