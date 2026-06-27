// Date Created :31/july/2023
// Developer Name : Mazen shabaan
//App Version : Version 1
// Date of Last Edit :2/August/2023
// Objectives: this class named custom_container it created to customize the container of download or import photos
// and customize the styling of this container according to needed screen
// ignore_for_file: deprecated_member_use, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_font_size.dart';

class Custom_Container extends StatelessWidget {
  const Custom_Container(
      {super.key,
      required this.height,
      required this.imageAddress,
      required this.text,
      // required this.width,
      required this.backgroundColor,
      this.textStyle,
      required this.borderColor,
      required this.iconColor,
      this.iconSize,
      this.fontSize,
      this.isDownload = false,
      required this.textColor});

  final double height;
  final String imageAddress;
  final String text;
  final TextStyle? textStyle;
  //final double width;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;
  final double? iconSize;
  final double? fontSize;
  final bool isDownload;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        color: backgroundColor,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Transform.scale(
              scale: isPortrait ? 1.3 : 1,
              child: SvgPicture.asset(
                imageAddress,
                color: iconColor,
              ),
            ), //'assets/images/galleryadd.png'),
            SizedBox(width: isTablet ? 0.01.w : 0.03.w),
            Padding(
              padding: EdgeInsets.only(left: 0.001.w),
              child: Text(
                text.tr, //'Add Cover Photo For your Service',
                style: textStyle ??
                    AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize020.h,
                        fontWeight: FontWeight.w600,
                        height: isTablet ? 0.0018.h : 1.8,
                        color: textColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
