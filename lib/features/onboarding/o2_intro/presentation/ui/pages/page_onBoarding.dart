//Date Created :1/September/2023
// Developer Name : Mazen shabaan
//App Version : Version tablet
// Date of Last Edit :3/October/2023 by mazen
// Objectives: this class  created to Customize the pageview element of onboarding
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_theme.dart';

class CustomPageView extends StatelessWidget {
  final String title;
  final String description;
  final String imgurl;
  const CustomPageView(
      {Key? key,
      required this.title,
      required this.description,
      required this.imgurl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
     bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      padding: EdgeInsets.only(left: 0.005.w, right: 0.005.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            imgurl,
            height: isTablet ? 0.39.h : 0.35.h,
            fit: BoxFit.fill,
          ),
          SizedBox(
            height: isTablet ?isPortrait?0.04.h :0.06.h : 0.05.h,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize24Weight600.copyWith(
                height: 1.3,
                fontSize: isTablet
                    ? FontConstants.fontSize030.h
                    : FontConstants.fontSize032.h,
                color: Theme.of(context).colorScheme.secondaryContainer,
                fontWeight: Get.locale.toString().contains('en')
                    ? FontWeight.w600
                    : FontWeight.w500),
          ),
          SizedBox(
            height: isTablet ?isPortrait?0.015.h : 0.02.h : 0.015.h,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.fade,
            style: StyleText.fontSize18Weight500.copyWith(
                height: 1.7,
                fontSize: isTablet
                    ? FontConstants.fontSize024.h
                    : FontConstants.fontSize018.h,
                color: AppColors.colorGrey,
                fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }
}
