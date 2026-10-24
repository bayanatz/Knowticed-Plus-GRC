/// Module: core/theme
///
///*************************** FILE INFO ****************************///
/// File Name: style_text.dart
/// Description: `StyleText` — split out of `app_theme.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../app_theme.dart';

// Split from app_theme.dart to keep every file under 700 lines.

// ===== Legacy TextStyle Redirects (StyleText) =====
abstract class StyleText {
  static final _storage = GetStorage();

  // ✅ CHANGED: Made font families getters that read from storage
  static String get englishFontFamily => _storage.read('font') ?? 'Cairo';
  static String get arabicFontFamily =>
      _storage.read('font_arabic') ?? 'CairoArabic';

  // Helper method to apply font family based on locale
  static TextStyle _withFontFamily(TextStyle style) {
    return style.copyWith(
      fontFamily: Get.locale?.languageCode == 'en'
          ? englishFontFamily
          : arabicFontFamily,
    );
  }

  // ─── Canonical text styles ──────────────────────────────────────────────────
  //
  // Naming: fontSize<size>Weight<w400|500|600|700>. Size and weight are the
  // ONLY dimensions in the name — what you read is exactly what renders.
  // The colour defaults to AppColors.text; for any other colour use copyWith:
  //
  //   StyleText.fontSize14Weight600.copyWith(color: AppColors.white)
  //
  // These are the only text styles new code should use.

  static TextStyle get fontSize8Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 8.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize8Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 8.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize10Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 10.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize10Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 10.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize10Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 10.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize10Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 10.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );

  static TextStyle get fontSize11Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 11.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize11Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 11.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize12Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 12.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize12Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 12.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize12Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 12.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize13Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 13.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize13Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 13.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize13Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 13.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize14Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize14Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize14Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize14Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 14.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );

  static TextStyle get fontSize15Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 15.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize15Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 15.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize15Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 15.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize16Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 16.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize16Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 16.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize16Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 16.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize16Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 16.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );

  static TextStyle get fontSize18Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 18.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize18Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 18.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize18Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 18.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize19Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 19.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize19Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 19.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize19Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 19.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize20Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 20.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize20Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 20.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize20Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 20.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize21Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 21.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize22Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 22.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize22Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 22.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize22Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 22.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );

  static TextStyle get fontSize23Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 23.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize23Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 23.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize23Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 23.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize23Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 23.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );

  static TextStyle get fontSize24Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 24.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize24Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 24.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize24Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 24.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize25Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 25.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize25Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 25.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize25Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 25.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize26Weight400 => _withFontFamily(
        TextStyle(
          fontSize: 26.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.regular,
        ),
      );

  static TextStyle get fontSize26Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 26.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize26Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 26.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize28Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 28.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize28Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 28.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize30Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 30.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  static TextStyle get fontSize30Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 30.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize35Weight600 => _withFontFamily(
        TextStyle(
          fontSize: 35.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.semiBold,
        ),
      );

  static TextStyle get fontSize36Weight500 => _withFontFamily(
        TextStyle(
          fontSize: 36.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.medium,
        ),
      );

  // ADDED 17/10/2026: sizes the old AppTextStyles copies used (one system).
  static TextStyle get fontSize12Weight700 => _withFontFamily(
        TextStyle(
          fontSize: 12.sp,
          color: AppColors.text,
          fontWeight: AppFontWeights.bold,
        ),
      );
}
