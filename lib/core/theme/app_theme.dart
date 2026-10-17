/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_theme.dart
/// Description: Declares `AppTheme`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Date: 1/8/2024
// By: Youssef Ashraf, Mohamed Ashraf, Nada Mohammed
// Last update: 20/8/2024
// Objectives: This file is responsible for providing the app themes that is used in the app.

import 'package:flutter/material.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grc_module/core/theme/app_font_weights.dart';

part 'app_theme/style_text.dart';

abstract class AppTheme {
  static bool isDark = false;

  // FIXED 17/10/2026: each theme reads ITS OWN colour map. These are built
  // once (static final); reading the active `AppColors` map instead baked the
  // light background into the dark theme when it was first built during the
  // switch to dark (pages showed light behind dark cards).
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    textTheme: TextTheme(
      headlineMedium: StyleText.fontSize20Weight500,
      headlineSmall: StyleText.fontSize16Weight500,
      titleLarge: StyleText.fontSize18Weight500,
      titleMedium: StyleText.fontSize16Weight500,
      titleSmall: StyleText.fontSize14Weight500,
      bodyLarge: StyleText.fontSize14Weight500,
      bodySmall: StyleText.fontSize12Weight500,
      bodyMedium: StyleText.fontSize14Weight600,
      labelLarge: StyleText.fontSize14Weight500,
      labelMedium: StyleText.fontSize12Weight500,
      labelSmall: StyleText.fontSize10Weight400,
      displayLarge: StyleText.fontSize23Weight400,
      displayMedium: StyleText.fontSize20Weight500,
      displaySmall: StyleText.fontSize16Weight500,
    ),
    splashFactory: NoSplash.splashFactory, // ADD THIS
    highlightColor: Colors.transparent, // ADD THIS
    splashColor: Colors.transparent, // ADD THIS
    primaryColor: lightThemeColors['primary']!,
    // X-15 / X-72: every page slides in over 400 ms.
    pageTransitionsTheme: kpPageTransitionsTheme,
    scaffoldBackgroundColor: lightThemeColors['background']!,

    colorScheme: ColorScheme.light(
      primary: lightThemeColors['secondaryPrimary']!,
      onPrimary: Colors.white,
      outlineVariant: lightThemeColors['lightGrey']!,
      onSurface: lightThemeColors['secondaryBlack']!,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      headerHeadlineStyle: StyleText.fontSize23Weight400,
      weekdayStyle:
          StyleText.fontSize12Weight600.copyWith(color: lightThemeColors['darkGrey']!),
      headerBackgroundColor: lightThemeColors['secondaryPrimary']!,
      headerForegroundColor: Colors.white,
      backgroundColor: lightThemeColors['card']!,
      todayBackgroundColor: WidgetStatePropertyAll(lightThemeColors['card']!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      dayStyle: StyleText.fontSize14Weight500,
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return lightThemeColors['secondaryPrimary']!;
          }
          return lightThemeColors['card']!;
        },
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          } else if (states.contains(WidgetState.disabled)) {
            return lightThemeColors['lightGrey']!;
          }
          return lightThemeColors['text']!;
        },
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return lightThemeColors['secondaryPrimary']!;
          }
          return lightThemeColors['card']!;
        },
      ),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return lightThemeColors['text']!;
        },
      ),
      dividerColor: lightThemeColors['secondaryPrimary']!,
      dayShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      todayForegroundColor: WidgetStateProperty.all(
        lightThemeColors['secondaryPrimary']!,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: darkThemeColors['primary']!,
    textTheme: TextTheme(
      headlineMedium: StyleText.fontSize20Weight500,
      headlineSmall: StyleText.fontSize16Weight500,
      titleLarge: StyleText.fontSize18Weight500,
      titleMedium: StyleText.fontSize16Weight500,
      titleSmall: StyleText.fontSize14Weight500,
      bodyLarge: StyleText.fontSize14Weight500,
      bodySmall: StyleText.fontSize12Weight500,
      bodyMedium: StyleText.fontSize14Weight600,
      labelLarge: StyleText.fontSize14Weight500,
      labelMedium: StyleText.fontSize12Weight500,
      labelSmall: StyleText.fontSize10Weight400,
      displayLarge: StyleText.fontSize23Weight400,
      displayMedium: StyleText.fontSize20Weight500,
      displaySmall: StyleText.fontSize16Weight500,
    ),
    // X-15 / X-72: every page slides in over 400 ms.
    pageTransitionsTheme: kpPageTransitionsTheme,
    scaffoldBackgroundColor: darkThemeColors['background']!,
    splashFactory: NoSplash.splashFactory, // ADD THIS
    highlightColor: Colors.transparent, // ADD THIS
    splashColor: Colors.transparent, // ADD THIS
    colorScheme: ColorScheme.dark(
      primary: darkThemeColors['secondaryPrimary']!,
      onPrimary: Colors.white,
      outlineVariant: darkThemeColors['lightGrey']!,
      onSurface: darkThemeColors['secondaryBlack']!,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      headerHeadlineStyle: StyleText.fontSize23Weight400,
      weekdayStyle:
          StyleText.fontSize12Weight600.copyWith(color: darkThemeColors['darkGrey']!),
      headerBackgroundColor: darkThemeColors['secondaryPrimary']!,
      headerForegroundColor: Colors.white,
      backgroundColor: darkThemeColors['card']!,
      todayBackgroundColor: WidgetStatePropertyAll(darkThemeColors['card']!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      dayStyle: StyleText.fontSize14Weight500,
      dayBackgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return darkThemeColors['secondaryPrimary']!;
          }
          return darkThemeColors['white']!;
        },
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          } else if (states.contains(WidgetState.disabled)) {
            return darkThemeColors['lightGrey']!;
          }
          return darkThemeColors['black']!;
        },
      ),
      yearBackgroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return darkThemeColors['secondaryPrimary']!;
          }
          return darkThemeColors['card']!;
        },
      ),
      yearForegroundColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return darkThemeColors['text']!;
        },
      ),
      dividerColor: darkThemeColors['secondaryPrimary']!,
      dayShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      todayForegroundColor: WidgetStateProperty.all(
        darkThemeColors['secondaryPrimary']!,
      ),
    ),
  );

  // ****************** DEFINE COLOR PALETTE HERE ******************
  static Map<String, Color> lightThemeColors = {
    'greyDark': const Color(0xff8D8D8D),
    'switchOff': const Color(0xffe9e9eb),

    'evenRowColor': const Color(0xFFf1f1f1),
    'secondaryPrimary': const Color(0xffE5B800),
    'primary': const Color(0xffFFDE59),
    'grey': const Color(0xffD9D9D9),
    'lightGrey': const Color(0xffC3C3C3),
    'moreLightGrey': const Color(0xffEFEFEF),
    'mediumGrey': const Color(0xffA6A6A6),
    'darkGrey': const Color(0xffD9D9D9),
    'blackShadow': const Color.fromRGBO(0, 0, 0, 0.4),
    'green': const Color(0xff008000),
    'red': const Color(0xffDF1C1C),
    'header': const Color(0xff2D2D2D),
    'blue': const Color(0xff1F78D1),
    'card': Colors.white,
    'text': const Color(0xff2D2D2D),
    'lightPrimary': const Color(0xFFffe993),

    'base': Colors.white,
    'borderCard': const Color(0xffFFFFFF),
    'border': const Color(0xffD9D9D9),
    'background': const Color(0xffF5F5F5),
    'indicator': const Color(0xffE9E9E9),
    'black': const Color(0xff2D2D2D),
    'secondaryBlack': const Color(0xff797979),
    'whiteShadow': const Color(0xD9D9D9E0),
    'darkWhiteShadow': const Color(0x9E9E9E9E),
    'white': Colors.white,
    'darkWhite': const Color(0xffF2F2F2),
    'icon': const Color(0xff2D2D2D),
    'chatBackground': const Color(0xffF5F5F5),
    'chatField': Colors.white,
    'lightGreen': const Color(0xff4BB609),
    'orange': const Color(0xffFF814A),
    // Cancelled reads as a deeper red than Rejected. Was 0xffDF1C1C —
    // byte-identical to 'red', so the two statuses were indistinguishable
    // on the requests filter (bug report p.15).
    'darkRed': const Color(0xff8E1616),
    "lightRed": const Color(0xffFF0000),

    'oddRowColor': Colors.white,
    'secondaryText': const Color(0xff797979),
    'spanText': const Color(0xff797979),
    'secondaryButton': const Color(0xCCCCCCCC),
    'fullBlack': const Color(0xff000000),
    'lighterGrey': const Color(0xff999999),
    'liteBlue': const Color(0xff1877F2), // Same as light theme
// Stays the same in dark theme
    'borderGrey': const Color(0xffB5B4B4), // Stays the same in dark theme
    'darkerGrey': const Color(0xffcccccc), // Stays the same in dark theme
    'navyBlue': const Color(0xFF768396),

    'greyBack': const Color(0xFFBCCCCC),
    'darkBackGround': const Color(0xFF545454),
    'block': const Color(0xFFDF0C0C),
    'expiringSoon': const Color(0xFF991010),
    'onboardingDotInactive': const Color(0x332D2D2D),
    'barrierColor': const Color(0XFFD9D9D9).withValues(alpha: .9),
    'totalBlack': const Color(0xFF000000),
    'whiteDashboardTable': const Color(0xFFF1F1F1),
    'darkDashboardTable': const Color(0xFF28282B),
    'greyIcon': const Color(0xffA6A6A6),
    'blackButton': Colors.black
  };

  // ****************** DEFINE DARK COLOR PALETTE HERE ******************
  static Map<String, Color> darkThemeColors = {
    "greyDark": const Color(0xff8D8D8D),
    'greyIcon': const Color(0xFF6F6F6F),
    'secondaryPrimary': const Color(0xffE5B800),
    'evenRowColor': const Color(0xFF545454),
    'oddRowColor': const Color(0xFF28282B),
    'primary': const Color(0xffFFDE59),
    'grey': const Color(0xffD9D9D9),
    'lightGrey': const Color(0xffC3C3C3),
    'moreLightGrey': const Color(0xffEFEFEF),
    'mediumGrey': const Color(0xffA6A6A6),
    'darkGrey': const Color(0xff858585),
    'blackShadow': const Color.fromRGBO(0, 0, 0, 0.4),
    'green': const Color(0xff008000),
    'red': const Color(0xffDF1C1C),
    'header': const Color(0xFF171717),
    'blue': const Color(0xff1F78D1),
    'card': const Color(0xff4B4B4B),
    'text': Colors.white,
    'base': const Color(0xff797979),
    'borderCard': const Color(0xffFFFFFF),
    'border': Colors.transparent,
    'navyBlue': const Color(0xFF768396),
    'switchOff': const Color(0xffe9e9eb),

    'background': const Color(0xff2D2D2D),
    'indicator': const Color(0xffE9E9E9),
    'black': const Color(0xff2D2D2D),
    'secondaryBlack': Colors.white,
    'whiteShadow': const Color(0xD9D9D9E0),
    'lightPrimary': const Color(0xFFffe993),

    'darkWhiteShadow': const Color(0x9E9E9E9E),
    'white': Colors.white,
    'darkWhite': const Color(0xffF2F2F2),
    'icon': const Color(0xD9D9D9E0),
    'chatBackground': const Color(0xff4B4B4B),
    'chatField': const Color(0xff2D2D2D),
    'lightGreen': const Color(0xff4BB609),
    'orange': const Color(0xffFF814A),
    // Lighter than the light-theme value so it still reads against the
    // dark background, while staying clearly darker than 'red'.
    'darkRed': const Color(0xffB03030),
    'secondaryText': const Color(0xffcccccc),
    'spanText': const Color(0xffd3d3d3),
    'secondaryButton': const Color(0xff858585),
    'fullBlack': const Color(0xffffffff),
    'lighterGrey': const Color(0xff999999), // Same as light theme
    'liteBlue': const Color(0xff1877F2), // Same as light theme
    'borderGrey': const Color(0xffB5B4B4), // Same as light theme
    'darkerGrey': const Color(0xffcccccc), // Same as light theme
    'whiteDashboardTable': const Color(0xFFF1F1F1),
    'darkDashboardTable': const Color(0xFF28282B),
    'blackButton': Colors.white,
    // Keys present in lightThemeColors that must also exist in dark to prevent null crashes:
    'barrierColor': const Color(0xFFD9D9D9),
    'totalBlack': const Color(0xFF000000),
    'block': const Color(0xFFDF0C0C),
    'expiringSoon': const Color(0xFF991010),
    // FIXED 22/8/2026: was 0xFFF2F2F2 — an almost-white dot on the dark
    // 0xff2D2D2D background, so in dark mode the inactive indicators read
    // brighter than the active one. Matches `darkGrey`, the palette's neutral.
    'onboardingDotInactive': const Color(0xff858585),
    'greyBack': const Color(0xFFBCCCCC),
    'darkBackGround': const Color(0xFF545454),
    'lightRed': const Color(0xffFF0000),
  };

  static void setCurrentThemeColors() {
    AppColors.currentThemeColors = isDark ? darkThemeColors : lightThemeColors;
    Get.forceAppUpdate();
  }

  static void initTheme(
      Color primaryColor, Color secondaryColor, bool isDarkMode) async {
    isDark = isDarkMode;
    interfaceUpdateBrandingColors(primaryColor, secondaryColor);
    // Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    setCurrentThemeColors();
  }

  static void interfaceUpdateBrandingColors(
      Color primaryColor, Color secondaryColor) {
    lightThemeColors['secondaryPrimary'] = secondaryColor;
    lightThemeColors['primary'] = primaryColor;
    darkThemeColors['secondaryPrimary'] = secondaryColor;
    darkThemeColors['primary'] = primaryColor;

    setCurrentThemeColors();
  }

  static void interfaceInitTheme(
          Color primaryColor, Color secondaryColor, bool isDarkMode) =>
      initTheme(primaryColor, secondaryColor, isDarkMode);

  static void interfaceToggleTheme() => toggleTheme();

  static void toggleTheme() async {
    isDark = !isDark;
    setCurrentThemeColors();
  }

  /// Text / icon colour that reads on [fill]: dark on a light fill, white on
  /// a dark one. ADDED 17/10/2026 (Moataz: "when I hover on an option … if it
  /// is dark it becomes white, if the secondary colour is light it has to be
  /// dark") — follows Branding, so a dark brand colour flips the text (K-31).
  static Color readableOn(Color fill) =>
      fill.computeLuminance() > 0.5 ? AppColors.black : AppColors.white;

  static Color contrastGreyColor() {
    final double primaryLuminance = AppColors.primary.computeLuminance();
    final double secondaryPrimaryLuminance =
        AppColors.secondaryPrimary.computeLuminance();

    // Check if both colors are light or dark
    if (primaryLuminance > 0.5 && secondaryPrimaryLuminance > 0.5) {
      return AppColors.secondaryBlack; // Return black for light colors
    } else if (primaryLuminance <= 0.5 && secondaryPrimaryLuminance <= 0.5) {
      return AppColors.white; // Return white for dark colors
    } else {
      // If one color is light and the other is dark, return a contrasting color
      return AppColors.white; // Change this to the desired contrasting color
    }
  }
}
