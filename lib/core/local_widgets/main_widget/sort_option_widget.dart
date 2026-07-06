// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to the sort widget in messages screen
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class SortOptionWidget extends StatelessWidget {
  const SortOptionWidget(
      {super.key,
      required this.text,
      required this.iconAddress,
      this.hasImage = true,
      this.iconColor});
  final String text;
  final String iconAddress;
  final Color? iconColor;
  final bool hasImage;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      mainAxisAlignment:
          hasImage ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        hasImage
            ? Padding(
                padding: EdgeInsets.only(
                    right: Get.locale.toString().contains('en') ? 0.02.w : 0,
                    left: Get.locale.toString().contains('en') ? 0 : 0.02.w),
                child: Transform.scale(
                  scale: isTablet ? 1.2 : 1.1,
                  child: Container(
                    width: isTablet ? null : 0.06.w,
                    child: SvgPicture.asset(
                      iconAddress,
                      // ignore: deprecated_member_use
                      color: iconColor ?? Theme.of(context).colorScheme.scrim,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Text(
          text.tr,
          style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: isTablet
                  ? isPortrait
                      ? FontConstants.fontSize014.h
                      : FontConstants.fontSize014.w
                  : FontConstants.fontSize035.w,
              color: Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.w400,
              height: isTablet ? (isPortrait ? 1.8 : 0.0022.h) : 0.0022.h),
        ),
      ],
    );
  }
}
