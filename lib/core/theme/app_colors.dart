// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing the app colors that are used in the app.

import 'package:flutter/material.dart';

import 'app_theme.dart';

abstract class AppColors {
  static Map<String, Color> currentThemeColors = AppTheme.lightThemeColors;

  // Theme-independent constant (avoids raw Colors.transparent in widgets, §12).
  static const Color transparent = Colors.transparent;

  /// Theme-independent disabled/inactive-state grey (was inline
  /// `Color(0xFFD9D9D9)` in custom_check_box.dart). Matches the light-theme
  /// barrierColor value but is kept separate since it's used for disabled
  /// buttons/controls, not modal barriers.
  static const Color disabledGrey = Color(0xFFD9D9D9);


  // ----------------- Black & White Colors -----------------
  static Color get pending => currentThemeColors['pending']!;
  static Color get black => currentThemeColors['black']!;
  static Color get blackShadow => currentThemeColors['blackShadow']!;
  static Color get secondaryBlack => currentThemeColors['secondaryBlack']!;
  static Color get white => currentThemeColors['white']!;
  static Color get whiteShadow => currentThemeColors['whiteShadow']!;
  static Color get darkWhite => currentThemeColors['darkWhite']!;
  static Color get darkWhiteShadow => currentThemeColors['darkWhiteShadow']!;
  static Color get oddRowColor => currentThemeColors['oddRowColor']!;
  static Color get evenRowColor => currentThemeColors['evenRowColor']!;
  static Color get fullBlack => currentThemeColors['fullBlack']!;
  static Color get blackButton => currentThemeColors['blackButton']!;

  static Color get block => currentThemeColors['block']!;
  static Color get darkBackGround => currentThemeColors['darkBackGround']!;
  static Color get warning => currentThemeColors['warning']!;
  static Color get greyBack => currentThemeColors['greyBack']!;
  static Color get barrierColor {
    final v = currentThemeColors['barrierColor'];
    if (v == null) {
      print('❌ [AppColors] barrierColor is NULL — map keys: ${currentThemeColors.keys.toList()}');
    }
    return v ?? const Color(0xFFD9D9D9);
  }
  static Color get unBlock => currentThemeColors['unBlock']!;
  static Color get delete => currentThemeColors['delete']!;
  static Color get differentGrey => currentThemeColors['differentGrey']!;
  static Color get whiteDark => currentThemeColors['whiteDark']!;
  static Color get lightRed => currentThemeColors['lightRed']!;

  // ----------------- Primary Colors -----------------

  static Color get primary => currentThemeColors['primary']!;
  static Color get secondaryPrimary => currentThemeColors['secondaryPrimary']!;
  // ----------------- Components Colors -----------------
  static Color get header => currentThemeColors['header']!;
  static Color get text => currentThemeColors['text']!;
  static Color get inputColor => currentThemeColors['inputColor']!;
  static Color get button => currentThemeColors['button']!;
  static Color get textButton => AppTheme.contrastColor();
  static Color get secondaryPrimaryText => AppTheme.secondaryPrimaryText();
  static Color get icon => currentThemeColors['icon']!;
  static Color get card => currentThemeColors['card']!;
  static Color get field => currentThemeColors['field']!;
  static Color get appBar => currentThemeColors['appBar']!;
  static Color get dropShadow => currentThemeColors['dropShadow']!;
  static Color get borderCard => currentThemeColors['borderCard']!;
  static Color get message => currentThemeColors['message']!;
  static Color get messageText => currentThemeColors['messageText']!;
  static Color get background => currentThemeColors['background']!;
  static Color get switchOff => currentThemeColors['switchOff']!;

  static Color get indicator => currentThemeColors['indicator']!;
  static Color get starredCard => currentThemeColors['starredCard']!;
  static Color get border => currentThemeColors['border']!;
  static Color get navyBlue => currentThemeColors['navyBlue']!;

  static Color get dialog => currentThemeColors['dialog']!;
  static Color get chatBackground => currentThemeColors['chatBackground']!;
  static Color get chatField => currentThemeColors['chatField']!;
  static Color get fieldBorder => currentThemeColors['fieldBorder']!;
  static Color get totalBlack => currentThemeColors['totalBlack']!;
  static Color get greyDark => currentThemeColors['greyDark']!;

  //
  // ----------------- Grey Colors -----------------
  static Color get grey => currentThemeColors['grey']!;
  static Color get lightGrey => currentThemeColors['lightGrey']!;
  static Color get moreLightGrey => currentThemeColors['moreLightGrey']!;
  static Color get mediumGrey => currentThemeColors['mediumGrey']!;
  static Color get darkGrey => currentThemeColors['darkGrey']!;
  static Color get lighterGrey => currentThemeColors['lighterGrey']!;
  static Color get darkerGrey => currentThemeColors['darkerGrey']!;
  static Color get greyIcon => currentThemeColors['greyIcon']!;
  static Color get drawerColor => currentThemeColors['drawerColor']!;
  static Color get lightPrimary => currentThemeColors['lightPrimary']!;

  // ----------------- Basic Colors -----------------
  static Color get base => currentThemeColors[
      'base']!; // *** anything white and converted to secondary black in dark mode ***
  static Color get inverseBase => currentThemeColors[
      'inverseBase']!; // *** anything secondary black and converted to white in dark mode ***

  // ----------------- Secondary Colors -----------------
  static Color get lightGreen => currentThemeColors['lightGreen']!;
  static Color get green => currentThemeColors['green']!;
  static Color get darkRed => currentThemeColors['darkRed']!;
  static Color get red => currentThemeColors['red']!;
  static Color get blue => currentThemeColors['blue']!;
  static Color get orange => currentThemeColors['orange']!;
  static Color get yellow => currentThemeColors['yellow']!;
  static Color get warming => currentThemeColors['warming']!;
  static Color get lightBlue => currentThemeColors['liteBlue']!;
  static Color get secondaryText => currentThemeColors['secondaryText']!;
  static Color get spanText => currentThemeColors['spanText']!;
  static Color get secondaryButton => currentThemeColors['secondaryButton']!;
  static Color get borderGrey => currentThemeColors['borderGrey']!;
  static Color get crimson => currentThemeColors['crimson']!;

  static Color get whiteDashboardTable =>
      currentThemeColors['whiteDashboardTable']!;
  static Color get darkDashboardTable =>
      currentThemeColors['darkDashboardTable']!;

  /// Create a list of colors to be used for the chart.
  static List<Color> colors = [
    AppColors.primary,
    AppColors.grey,
    AppColors.black,
    AppColors.secondaryPrimary,
  ];

  // ----------------- MyThemeData backward-compat aliases -----------------
  // These allow files that used to import MyThemeData but now import AppColors
  // to compile without changes. Values match MyThemeData exactly.

  /// Brand primary/action color — same as AppColors.signOut / barColor / bubbleColor
  static Color get signOut => currentThemeColors['primary']!;
  static Color get barColor => currentThemeColors['primary']!;
  static Color get bubbleColor => currentThemeColors['primary']!;
  static Color get mainColor => currentThemeColors['primary']!;
  static Color get primaryYellow => currentThemeColors['primary']!;

  /// Brand secondary color — same as AppColors.switchSettings / lightPrimary (secondary)
  static Color get switchSettings => currentThemeColors['secondaryPrimary']!;

  /// Fixed neutrals — theme-unaware (same in light and dark)
  static const Color colorBlack = Color(0xFF2D2D2D);
  static const Color colorWhite = Color(0xFFFFFFFF);
  static const Color colorGrey = Color(0xFF9E9E9E);
  static const Color colorGreyDark = Color(0xFF6F6F6F);
  static const Color mainBlack = Color(0xFF2D2D2D);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color textfieldColor = Color.fromRGBO(246, 246, 246, 1);
  static const Color darkWhiteShadowDisabled = Color(0x9E9E9E9E);

  /// Theme-aware neutral aliases
  static Color get fieldBackGround => currentThemeColors['field']!;
  static Color get lightGreyBg => currentThemeColors['background']!;

  /// ThemeData forwarding — files using AppColors.lightTheme / darkTheme
  static ThemeData get lightTheme => AppTheme.lightTheme;
  static ThemeData get darkTheme => AppTheme.darkTheme;

  // ----------------- Full MyThemeData aliases (for complete removal) -----------------
  /// AppColors.action (was int primary/action, now a Color)
  static Color get action => currentThemeColors['primary']!;

  /// AppColors.colorWhiteDark
  static Color get colorWhiteDark => currentThemeColors['whiteDark']!;

  /// AppColors.colorLightGrey
  static Color get colorLightGrey => currentThemeColors['lightGrey']!;

  /// AppColors.colorRed
  static Color get colorRed => currentThemeColors['red']!;

  /// AppColors.colorTotalBlack
  static Color get colorTotalBlack => currentThemeColors['totalBlack']!;

  /// AppColors.colorGreydark (0xFFCCCCCC)
  static Color get colorGreydark => currentThemeColors['darkerGrey']!;

  /// AppColors.colorDarkGrey (0xFF797979)
  static const Color colorDarkGrey = Color(0xFF797979);

  /// Settings input background (dark mode) — 0xFF545454
  static const Color inputBackgroundDark = Color(0xFF545454);

  /// Invoices table zebra-stripe (light) — 0xFFF1F1F1
  static const Color tableRowLight = Color(0xFFF1F1F1);

  /// Invoices table zebra-stripe (dark) — 0xFF28282B
  static const Color tableRowDark = Color(0xFF28282B);

  /// AppColors.dark (0xFF4B4B4B)
  static Color get dark => currentThemeColors['greyDark']!;

  /// AppColors.dividerGrey (0xFFDBDCDD)
  static Color get dividerGrey => currentThemeColors['border']!;

  /// AppColors.dotBlack — colorBlack with 20% opacity
  static Color get dotBlack => const Color(0xFF2D2D2D).withOpacity(.2);

  /// AppColors.secondaryColor
  static Color get secondaryColor => currentThemeColors['secondaryPrimary']!;

  /// AppColors.textCal (0xFF19181A ≈ black)
  static Color get textCal => currentThemeColors['black']!;

  /// AppColors.textGrey (0xFF8D8D8D ≈ grey)
  static Color get textGrey => currentThemeColors['grey']!;

  /// AppColors.textdeactivecolor (0xFF797979 ≈ darkGrey)
  static Color get textdeactivecolor => currentThemeColors['darkGrey']!;

  /// AppColors.yellowColor (0xffFFCC00)
  static Color get yellowColor => currentThemeColors['yellow']!;
}
