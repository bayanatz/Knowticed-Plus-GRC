// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to title time in emeetings screen
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

class TitleTimeColumn extends StatelessWidget {
  const TitleTimeColumn({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.soon = false,
    this.soonListMeetings = false,
  });
  final String title;
  final String startTime;
  final String endTime;
  final bool soon;
  final bool soonListMeetings;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.capitalize as String,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: isTablet
                  ? isPortrait
                      ? FontConstants.fontSize014.h
                      : FontConstants.fontSize012.w
                  : FontConstants.fontSize016.h,
              color: soonListMeetings
                  ? AppColors.colorWhite
                  : Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.01.h),
            child: soon
                ? Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            right: Get.locale.toString().contains('en')
                                ? 0.006.w
                                : 0,
                            left: Get.locale.toString().contains('en')
                                ? 0
                                : 0.006.w,
                            bottom: 0.004.h),
                        child: SvgPicture.asset(
                            "assets/images/begin_rectangle.svg"),
                      ),
                      Text(
                        "Begins in 30m".tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isTablet
                                ? isPortrait
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize010.w
                                : FontConstants.fontSize013.h,
                            color: AppColors.block,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Text(
                        startTime.tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isTablet
                                ? isPortrait
                                    ? FontConstants.fontSize012.h
                                    : FontConstants.fontSize010.w
                                : FontConstants.fontSize015.h,
                            color: soonListMeetings
                                ? AppColors.colorWhite
                                : Theme.of(context).colorScheme.scrim,
                            fontWeight: FontWeight.w500),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isPortrait ? 0.01.w : 0.02.w),
                        child: SvgPicture.asset(
                          "assets/images/dots.svg",
                          // ignore: deprecated_member_use
                          color: soonListMeetings
                              ? AppColors.colorWhite
                              : Theme.of(context).colorScheme.scrim,
                        ),
                      ),
                      Text(
                        endTime.tr,
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: isTablet
                                ? isPortrait
                                    ? FontConstants.fontSize012.h
                                    : FontConstants.fontSize010.w
                                : FontConstants.fontSize015.h,
                            color: soonListMeetings
                                ? AppColors.colorWhite
                                : Theme.of(context).colorScheme.scrim,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
