// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/data_grc_module/constant/theme_controller.dart';

class ImagePaths {
  static String getImagePath(BuildContext context, String imageName) {
    final GRCThemeController themeController = Get.put(GRCThemeController());

    bool isDarkMode = AppTheme.isDark ?? false;
    return isDarkMode
        ? getDarkModeImagePath(imageName)
        : getLightModeImagePath(imageName);
  }

  static String getLightModeImagePath(String imageName) {
    String logo = 'assets/icons_assets/main_icons_assets/knowticed_logo.svg';
    // 'assets/icons_assets/main_icons_assets/bmw.svg';
    if (imageName == 'logo') {
      return logo;
      // return 'assets/icons_assets/main_icons_assets/knowticed_logo.svg';
    } else if (imageName == 'edit_data') {
      return 'assets/icons_assets/main_icons_assets/dialog_card_icon.svg';
    } else if (imageName == 'social_icon') {
      return 'assets/icons_assets/main_icons_assets/social_dialog_icon.svg';
    } else if (imageName == 'back_icon') {
      return 'assets/icons_assets/main_icons_assets/back_icon.svg';
    } else if (imageName == 'call_icon') {
      return 'assets/icons_assets/main_icons_assets/call_icon.svg';
    } else if (imageName == 'mic_icon') {
      return 'assets/icons_assets/main_icons_assets/mic_chat_icon.svg';
    } else if (imageName == 'camera_icon') {
      return 'assets/icons_assets/main_icons_assets/camera_icon.svg';
    } else if (imageName == 'add_icon') {
      return 'assets/icons_assets/main_icons_assets/add_chat_icon.svg';
    } else if (imageName == 'send_icon') {
      return 'assets/icons_assets/main_icons_assets/send_icon.svg';
    } else if (imageName == 'send_inactive_icon') {
      return 'assets/icons_assets/main_icons_assets/send_inactive_icon.svg';
    } else if (imageName == 'switch_off_icon') {
      return 'assets/icons/SwitchOff.png';
    } else if (imageName == 'splash') {
      return 'assets/png_assets/assets_splash.gif';
    } else if (imageName == 'notification') {
      return 'assets/png_assets/NotificationAppBarRedDot.png';
    } else {
      return '';
    }
  }

  static String getDarkModeImagePath(String imageName) {
    if (imageName == 'logo') {
      return 'assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg';
    } else if (imageName == 'edit_data') {
      return 'assets/icons_assets/main_icons_assets/dialog_card_icon_dark.svg';
    } else if (imageName == 'social_icon') {
      return 'assets/icons_assets/main_icons_assets/social_dialog_icon_dark.svg';
    } else if (imageName == 'back_icon') {
      return 'assets/icons_assets/main_icons_assets/back_icon_dark.svg';
    } else if (imageName == 'call_icon') {
      return 'assets/icons_assets/main_icons_assets/call_icon_dark.svg';
    } else if (imageName == 'mic_icon') {
      return 'assets/icons_assets/main_icons_assets/mic_icon_dark.svg';
    } else if (imageName == 'camera_icon') {
      return 'assets/icons_assets/main_icons_assets/camera_icon_dark.svg';
    } else if (imageName == 'add_icon') {
      return 'assets/icons_assets/main_icons_assets/add_icon_dark.svg';
    } else if (imageName == 'send_icon') {
      return 'assets/icons_assets/main_icons_assets/send_icon_dark.svg';
    } else if (imageName == 'send_inactive_icon') {
      return 'assets/icons_assets/main_icons_assets/send_inactive_dark_icon.svg';
    } else if (imageName == 'switch_off_icon') {
      return 'assets/icons/switch_off_icon.png';
    } else if (imageName == 'splash') {
      return 'assets/png_assets/assets_splash_dark.gif';
    } else if (imageName == 'notification') {
      return 'assets/png_assets/NotificationAppBarRedDot_dark.png';
    } else {
      return '';
    }
  }
}
