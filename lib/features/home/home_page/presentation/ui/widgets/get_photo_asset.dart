 import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';

import 'package:demo_app/core/theme/app_font_size.dart';


/// Date Created :2/Sep/2023
/// Developer Name : Bassem Mohamed
/// App Version : demo_app Plus
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
        assetPath = 'assets/icons_assets/home_assets/eventIconHome.svg';
        containerColor = AppColors.unBlock;
        assetColor = AppColors.colorWhite;
        break;
      case 'to do list':
        assetPath = 'assets/icons_assets/home_assets/todoListIconHome.svg';
        containerColor = AppColors.warning;
        assetColor = AppColors.colorWhite;
        break;
      case 'board':
        assetPath = 'assets/icons_assets/home_assets/boardIcon.svg';
        containerColor = AppColors.primary;
        assetColor = AppColors.colorBlack;
        break;
      case 'service':
        assetPath = 'assets/icons_assets/home_assets/serviceIconHomeNew.svg';
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
        child: SvgPicture.asset(
          assetPath,
          color: assetColor,
        ),
      ),
    );
  }