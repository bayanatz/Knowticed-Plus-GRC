// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

class ImagePaths {
  static String getImagePath(BuildContext context, String imageName) {
    // The old GRCThemeController instance registered here was never read —
    // theme state comes from AppTheme.isDark. Registering core's
    // ThemeController would overwrite the app's live instance, so it is gone.
    bool isDarkMode = AppTheme.isDark;
    return isDarkMode
        ? getDarkModeImagePath(imageName)
        : getLightModeImagePath(imageName);
  }

  static String getLightModeImagePath(String imageName) {
    String logo = 'assets/icons_assets/main_icons_assets/logo_knowticed.svg';
    // 'assets/icons_assets/main_icons_assets/bmw.svg';
    if (imageName == 'logo') {
      return logo;
      // return 'assets/icons_assets/main_icons_assets/logo_knowticed.svg';
    } else if (imageName == 'edit_data') {
      return 'assets/icons_assets/main_icons_assets/ic_edit_dialog_profile.svg';
    } else if (imageName == 'social_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_social_interests_person.svg';
    } else if (imageName == 'back_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';
    } else if (imageName == 'call_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_comms_phone.svg';
    } else if (imageName == 'mic_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_media_microphone.svg';
    } else if (imageName == 'camera_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_media_camera.svg';
    } else if (imageName == 'add_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
    } else if (imageName == 'send_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';
    } else if (imageName == 'send_inactive_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';
    } else if (imageName == 'switch_off_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_field_switch.svg';
    } else if (imageName == 'splash') {
      return 'assets/icons_assets/main_icons_assets/logo_knowticed.svg';
    } else if (imageName == 'notification') {
      return 'assets/icons_assets/main_icons_assets/ic_comms_notification_badge.svg';
    } else {
      return '';
    }
  }

  static String getDarkModeImagePath(String imageName) {
    if (imageName == 'logo') {
      return 'assets/icons_assets/main_icons_assets/logo_knowticed_dark.svg';
    } else if (imageName == 'edit_data') {
      return 'assets/icons_assets/main_icons_assets/ic_edit_dialog_profile.svg';
    } else if (imageName == 'social_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_social_interests_person.svg';
    } else if (imageName == 'back_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';
    } else if (imageName == 'call_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_comms_phone.svg';
    } else if (imageName == 'mic_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_media_microphone.svg';
    } else if (imageName == 'camera_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_media_camera.svg';
    } else if (imageName == 'add_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
    } else if (imageName == 'send_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';
    } else if (imageName == 'send_inactive_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_action_send_white.svg';
    } else if (imageName == 'switch_off_icon') {
      return 'assets/icons_assets/main_icons_assets/ic_field_switch.svg';
    } else if (imageName == 'splash') {
      return 'assets/icons_assets/main_icons_assets/logo_knowticed_badge_light.svg';
    } else if (imageName == 'notification') {
      return 'assets/icons_assets/main_icons_assets/ic_comms_notification_badge.svg';
    } else {
      return '';
    }
  }
}
