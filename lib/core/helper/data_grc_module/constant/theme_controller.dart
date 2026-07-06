import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/helper/data_grc_module/constant/restart_widget.dart';

class GRCThemeController extends GetxController {
  final storage = GetStorage();
  Rx<ThemeData> currentTheme = AppTheme.lightTheme.obs;
  RxBool animationsEnabled = true.obs; // For animation toggle

  @override
  void onInit() {
    super.onInit();
    loadThemeFromStorage();
    loadAnimationsSetting(); // Load animation setting on init
    ever(currentTheme, (_) => updateSystemUIOverlayStyle());
  }

  void updateSystemUIOverlayStyle() {
    if (Get.context != null) {
      bool isTablet = MediaQuery.of(Get.context!).size.shortestSide > 600;
      if (isTablet) {
        updateSystemUIOverlayStyleTablet();
      } else {
        updateSystemUIOverlayStyleMobile();
      }
    }
  }

  void updateSystemUIOverlayStyleMobile() {
    if (currentTheme.value == AppTheme.lightTheme) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.background,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // Necessary for iOS
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // Necessary for iOS
        ),
      );
    }
  }

  void updateSystemUIOverlayStyleTablet() {
    if (currentTheme.value == AppTheme.lightTheme) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light, // Necessary for iOS
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.field,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // Necessary for iOS
        ),
      );
    }
  }

  void toggleTheme() {
    //AppTheme.isDark = false;
    //AppTheme.toggleTheme();
    if (currentTheme.value == AppTheme.lightTheme) {
      currentTheme.value = AppTheme.darkTheme;
      AppTheme.toggleTheme();
      storage.write('theme', 'darkMode');
      Get.changeTheme(AppTheme.darkTheme);
    } else {
      currentTheme.value = AppTheme.lightTheme;
      AppTheme.toggleTheme();
      storage.write('theme', 'lightMode');
      Get.changeTheme(AppTheme.lightTheme);
    }
    update();
  }

  void loadThemeFromStorage() {
    final savedTheme = storage.read('theme');
    if (savedTheme != null) {
      if (savedTheme == 'darkMode') {
        currentTheme.value = AppTheme.darkTheme;
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            Get.changeTheme(AppTheme.darkTheme);
          },
        );
      } else {
        currentTheme.value = AppTheme.lightTheme;
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            Get.changeTheme(AppTheme.lightTheme);
          },
        );
      }
    }
  }

  /// Toggle whether animations are enabled or disabled.
  ///
  /// When animations are disabled, various transitions and animations in the app
  /// will be skipped. This is useful for people who have motion sensitivity issues
  /// or prefer a more static experience.
  ///
  /// The app will be restarted if `shouldRestartAppForAnimationChange` is true.
  /// This is useful if other parts of the app depend on this value.
  ///
  /// [isEnabled] whether animations should be enabled or disabled.
  void toggleAnimations(bool isEnabled) {
    animationsEnabled.value = isEnabled;
    storage.write('animationsEnabled', isEnabled); // Save to storage
    // Only restart if there are other dependencies that need reloading
    if (shouldRestartAppForAnimationChange) {
      RestartWidget.restartApp(Get.context!);
    }
    update();
  }

  bool get shouldRestartAppForAnimationChange => false; // Set as needed

  void loadAnimationsSetting() {
    animationsEnabled.value =
        storage.read('animationsEnabled') ?? true; // Load saved setting
  }
}

/// Global theme controller instance (moved from theme_controller_instance.dart).
final GRCThemeController themeController = Get.put(GRCThemeController());
