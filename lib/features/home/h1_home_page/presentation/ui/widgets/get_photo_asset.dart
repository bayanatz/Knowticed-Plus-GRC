/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: get_photo_asset.dart
/// Purpose: Widget used by the feature's screens.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';

/// Date Created :2/Sep/2023
/// Developer Name : Bassem Mohamed
/// App Version : knowticed Plus
/// Date of Last Edit :2/Sep/2023 By Bassem
/// Objectives: this widget responsible for showing the photo in upcoming schedule container,
/// with its desired color according to the event type

Widget getPhotoAsset(String eventType) {
  String assetPath;
  Color assetColor;
  Color containerColor;

  // Determine the appropriate photo and color based on the type
  switch (eventType.toLowerCase()) {
    case 'event':
      assetPath =
          'assets/icons_assets/main_icons_assets/ic_calendar_event_star_white.svg';
      containerColor = AppColors.lightGreen;
      assetColor = AppColors.colorWhite;
      break;
    case 'to do list':
      assetPath = 'assets/icons_assets/main_icons_assets/ic_module_todo.svg';
      containerColor = AppColors.orange;
      assetColor = AppColors.colorWhite;
      break;
    case 'board':
      assetPath =
          'assets/icons_assets/main_icons_assets/ic_time_sla_schedule.svg';
      containerColor = AppColors.primary;
      assetColor = AppColors.colorBlack;
      break;
    case 'service':
      assetPath = 'assets/icons_assets/home_assets/ic_data_service_total.svg';
      containerColor = Color(0xFF73A2FF);
      assetColor = AppColors.colorWhite;
      break;
    default:
      return Container();
  }

  return Container(
    height: 0.045.h,
    width: 0.045.h,
    decoration: BoxDecoration(
        color: containerColor, borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: EdgeInsets.all(0.007.h),
      child: CustomSvgImage.natural(
        assetPath: assetPath,
        color: assetColor,
      ),
    ),
  );
}
