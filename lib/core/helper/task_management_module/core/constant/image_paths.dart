// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/theme_controller.dart';

class ImagePaths {
  static String getImagePath(BuildContext context, String imageName) {
    final ThemeController themeController = Get.put(ThemeController());

    bool isDarkMode = themeController.currentTheme == AppColors.darkTheme;
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
    } else if (imageName == 'delete') {
      return 'assets/icons/delete_attachment.svg';
    } else if (imageName == 'Download') {
      return 'assets/icons_assets/task_assets/icons_Download.svg';
    } else if (imageName == 'social_icon') {
      return 'assets/icons_assets/main_icons_assets/social_dialog_icon.svg';
    } else if (imageName == 'back_icon') {
      return 'assets/icons_assets/main_icons_assets/back_icon.svg';
    } else if (imageName == 'DeleteIcon') {
      return 'assets/icons_assets/task_assets/deleteIcon.svg';
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
    } else if (imageName == 'AttachSquareIcon') {
      return 'assets/icons_assets/task_assets/attachsquareIcon.svg';
    } else if (imageName == 'taskDeadline') {
      return "assets/icons_assets/task_assets/taskDeadline.svg";
    } else if (imageName == 'calendar2') {
      return "assets/icons_assets/main_icons_assets/calendar2.svg";
    } else if (imageName == 'arrow_down_mobile') {
      return "assets/icons_assets/main_icons_assets/arrow_down_mobile.svg";
    } else if (imageName == 'ClockCircleIcon') {
      return "assets/icons_assets/task_assets/ClockCircleIcon.svg";
    } else if (imageName == 'pdfImage') {
      return "assets/icons_assets/task_assets/pdfImage.svg";
    } else if (imageName == 'docxImage') {
      return "assets/icons_assets/task_assets/docxImage.svg";
    } else if (imageName == 'threeDotsDialog') {
      return "assets/icons_assets/main_icons_assets/threeDotsDialog.svg";
    } else if (imageName == 'ImagePlaceHolder') {
      return "assets/images/ImagePlaceHolder.svg";
    } else {
      return '';
    }
  }

  static String getDarkModeImagePath(String imageName) {
    if (imageName == 'logo') {
      return 'assets/icons_assets/main_icons_assets/knowticed_logo_dark.svg';
    } else if (imageName == 'threeDotsDialog') {
      return "assets/icons_assets/main_icons_assets/threeDotsDialog.svg";
    }  else if (imageName == 'edit_data') {
      return 'assets/icons_assets/main_icons_assets/dialog_card_icon_dark.svg';
    } else if (imageName == 'DeleteIcon') {
      return 'assets/icons_assets/task_assets/deleteIcon.svg';
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
    } else if (imageName == 'AttachSquareIcon') {
      return 'assets/icons_assets/task_assets/attachsquareIcon.svg';
    } else if (imageName == 'taskDeadline') {
      return "assets/icons_assets/task_assets/taskDeadline.svg";
    } else if (imageName == 'calendar2') {
      return "assets/icons_assets/main_icons_assets/calendar2.svg";
    } else if (imageName == 'ClockCircleIcon') {
      return "assets/icons_assets/task_assets/ClockCircleIcon.svg";
    } else if (imageName == 'pdfImage') {
      return "assets/icons_assets/task_assets/pdfImage.svg";
    } else if (imageName == 'docxImage') {
      return "assets/icons_assets/task_assets/docxImage.svg";
    } else if (imageName == 'delete') {
      return 'assets/icons/delete_attachment.svg';
    } else if (imageName == 'Download') {
      return 'assets/icons_assets/task_assets/icons_Download.svg';
    } else if (imageName == 'ImagePlaceHolder') {
      return "assets/images/ImagePlaceHolder.svg";
    } else {
      return '';
    }
  }
}
