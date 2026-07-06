// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :14/November/2023
// Objectives: this is a widget to customize the filters of the appbar
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class FiltersAppBar extends StatelessWidget {
  const FiltersAppBar(
      {super.key,
      required this.imageUrl,
      required this.title,
      this.hideIcon,
      this.iconColor});
  final String imageUrl;
  final String title;
  final bool? hideIcon;
  final Color? iconColor;

  double getIconSize(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
      return 0.8;
    } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
      return 0.9;
    } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
      return 1;
    } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
      return 1.2;
    } else if (isDesktop && screenHeight >= 1000) {
      return 1.3;
    }

    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double screenHeight = MediaQuery.of(context).size.height;

    // Print the screen height
    print('Screen Height: $screenHeight');
    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: Column(
        children: [
          Row(
            children: [

              CircleAvatar(
                      radius:
                         15.r,
                      backgroundColor: AppColors.primary,
                      child: Transform.scale(
                          scale: isDesktop
                              ? getIconSize(context)
                              : isTablet
                                  ? isPortrait
                                      ? (isLargeTablet ? 1 : 0.9)
                                      : (isLargeTablet ? 1 : 0.9)
                                  : 0.7,
                          child: SvgPicture.asset(
                            imageUrl,
                            color: AppColors.textButton,
                          )),
                    ),
              Padding(
                padding: EdgeInsets.only(
                    left: hideIcon == true
                        ? 0
                        : Get.locale.toString().contains('en')
                            ? isPortrait
                                ? 0.015.w
                                : 0.01.w
                            : 0,
                    right: hideIcon == true
                        ? 0
                        : Get.locale.toString().contains('en')
                            ? 0
                            : isPortrait
                                ? 0.015.w
                                : 0.01.w),
                child: Text(
                  title.tr,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: isTablet
                          ? isPortrait
                              ? FontConstants.fontSize021.h
                              : FontConstants.fontSize028.h
                          : FontConstants.fontSize020.h,
                      fontWeight: Get.locale.toString().contains('en')
                          ? FontWeight.w600
                          : FontWeight.w500,
                      height: isTablet ? (isPortrait ? 1.8 : 1.8) : 0.002.h,
                      color: Theme.of(context).colorScheme.inverseSurface),
                ),
              ),
            ],
          ),
          if (isTablet)
            isPortrait
                ? SizedBox(height: 0.015.h)
                : SizedBox(
                    height: 0.03.h,
                  ),
          // if(isTablet)
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical:isTablet? 0.005.h:0),
          //   child: Divider(
          //     color: AppColors.divider,
          //     thickness: 1.5,
          //   ),
          // ),
          if (!isTablet)
            SizedBox(
              height: 0.01.h,
            )
        ],
      ),
    );
  }
}
