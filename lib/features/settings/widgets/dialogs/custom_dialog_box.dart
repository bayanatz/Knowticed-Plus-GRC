// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

class CustomDialogBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color backgroundColor;
  final bool showButtons;
  final String buttonText;
  final Color buttonFontColor;
  final Color buttoncolor;
  final VoidCallback? onConfirm;
  final double? heightContainer;
  final double? widthContainer;
  final double? secondHeightContainer;
  final double? secondWidthContainer;
  final bool isHorizontal;
  //final VoidCallback? onCancel;

  const CustomDialogBox({
    Key? key,
    required this.title,
    this.subtitle = '',
    required this.imagePath,
    required this.backgroundColor,
    required this.showButtons,
    this.heightContainer,
    this.widthContainer,
    this.secondHeightContainer,
    this.secondWidthContainer,
    this.buttonText = 'Delete',
    this.buttoncolor = Colors.black,
    this.buttonFontColor = Colors.white,
    this.isHorizontal = false,
    this.onConfirm, //this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final HapticController hapticController = Get.put(HapticController());

    double radius = 10;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 0.05.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            child: Container(
              width: isTablet
                  ? isPortrait == false
                      ? widthContainer ?? 0.42.w
                      : widthContainer ?? 0.7.w
                  : double.infinity,
              height: isTablet ? heightContainer ?? 0.025.h : 0.016.h,
              color: backgroundColor, //<<<<<<<<<
            ),
          ),
          Container(
            height: showButtons == true
                ? isPortrait == true
                    ? isTablet
                        ? 0.190.h
                        : 0.2.h
                    : 0.22.h
                : isPortrait == true
                    ? isTablet
                        ? secondHeightContainer ?? 0.165.h
                        : 0.145.h
                    : secondHeightContainer ?? 0.2.h,
            decoration: BoxDecoration(
              border: Border.all(color: backgroundColor, width: 1.2),
              borderRadius: BorderRadius.circular(10),
            ),
            width: isTablet
                ? isPortrait == false
                    ? secondWidthContainer ??
                        MediaQuery.of(context).size.width * 0.42
                    : secondWidthContainer ??
                        MediaQuery.of(context).size.width * 0.7
                : MediaQuery.of(context).size.width * 0.94,
            padding: const EdgeInsets.all(7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: isTablet ? 0.04.h : 0.02.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: Get.locale.toString().contains('en')
                              ? 0.009.w
                              : 0,
                          right: Get.locale.toString().contains('en')
                              ? 0
                              : 0.009.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: imagePath.endsWith('png')
                            ? Image.asset(
                                imagePath,
                                height: isHorizontal == true
                                    ? 0.12.h
                                    : isTablet
                                        ? .088.h
                                        : .09.h,
                                width: isHorizontal == true
                                    ? 0.12.h
                                    : isTablet
                                        ? .088.h
                                        : .09.h,
                                fit: BoxFit.cover,
                              )
                            : SvgPicture.asset(
                                imagePath,
                                height: isHorizontal == true
                                    ? 0.12.h
                                    : isTablet
                                        ? .088.h
                                        : .09.h,
                                width: isHorizontal == true
                                    ? 0.12.h
                                    : isTablet
                                        ? .088.h
                                        : .09.h,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(
                        width: isPortrait == true
                            ? isTablet
                                ? 0.026.w
                                : 0.03.w
                            : 0.016.w),
                    subtitle.isEmpty
                        ? Flexible(
                            child: Text(
                              title.tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: isHorizontal == true
                                    ? FontConstants.fontSize022.h
                                    : FontConstants.fontSize019.h,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //
                                Text(
                                  title.tr,
                                  style: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: isHorizontal == true
                                              ? FontConstants.fontSize028.h
                                              : isPortrait == true
                                                  ? FontConstants.fontSize020.h
                                                  : FontConstants.fontSize029.h,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          fontWeight: FontWeight.w600),
                                ),
                                isPortrait == false
                                    ? SizedBox(
                                        height: 0.008.h,
                                      )
                                    : isTablet
                                        ? const SizedBox.shrink()
                                        : SizedBox(
                                            height: 0.01.h,
                                          ),
                                Text(
                                  subtitle.tr,
                                  style:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                          fontSize: isHorizontal == true
                                              ? FontConstants.fontSize026.h
                                              : isPortrait == true
                                                  ? FontConstants.fontSize019.h
                                                  : FontConstants.fontSize028.h,
                                          color: AppColors.colorGrey,
                                          fontWeight: FontWeight.w500,
                                          height: 0.0014.h),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                //SizedBox(height: 16),
                if (showButtons)
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: isPortrait == true
                              ? isTablet
                                  ? 0.17.w
                                  : 0.22.w
                              : 0.08.w),
                      ElevatedButton(
                        onPressed: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.lightImpact,
                              hapticFeedback: HapticFeedback.lightImpact);
                          Navigator.pop(context,
                              false); // Return false to indicate cancel
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: isPortrait == true
                              ? isTablet
                                  ? Size(.2.w, 36)
                                  : Size(.28.w, 36)
                              : Size(.1.w, 36),
                        ),
                        child: Text(
                          'Cancel'.tr,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: isPortrait == true
                                  ? FontConstants.fontSize019.h
                                  : FontConstants.fontSize023.h,
                              color: AppColors.colorLightGrey,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(width: isPortrait == true ? 0.037.w : 0.027.w),
                      ElevatedButton(
                        onPressed: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.heavyImpact,
                              hapticFeedback: HapticFeedback.heavyImpact);
                          onConfirm
                              ?.call(); // call the onConfirm callback function
                          Navigator.of(context)
                              .pop(true); // close the dialog and return true
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttoncolor,
                          minimumSize: isPortrait == true
                              ? isTablet
                                  ? Size(.2.w, 36)
                                  : Size(.28.w, 36)
                              : Size(.1.w, 36),
                        ),
                        child: Text(
                          buttonText.tr,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isPortrait == true
                                ? FontConstants.fontSize019.h
                                : FontConstants.fontSize023.h,
                            color: buttonFontColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
