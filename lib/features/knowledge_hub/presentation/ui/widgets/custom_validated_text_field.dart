/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: custom_validated_text_field.dart
/// Description: `CustomValidatedTextField` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CustomValidatedTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final ui.TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final Color? fillColor;

  /// false drops the yellow focus outline (an error still
  /// shows red). KH report p.15.
  final bool showFocusBorder;

  /// false turns off the English-only / Arabic-only check
  /// for free text in either language (KH vertical report p.9).
  final bool checkLanguage;

  // Error text parameter
  final String? errorText;

  // Keyboard type parameter
  final TextInputType? keyboardType;

  // Optional validator function
  final String? Function(String?)? validator;

  // SVG prefix icon parameters
  final String? prefixSvgAsset;
  final double? prefixIconWidth;
  final double? prefixIconHeight;
  final EdgeInsetsGeometry? prefixPadding;
  final VoidCallback? onPrefixTap;
  final BoxConstraints? prefixConstraints;

  const CustomValidatedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.height = 36,
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = ui.TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.fillColor,
    this.showFocusBorder = true,
    this.checkLanguage = true,
    this.errorText,
    this.keyboardType,

    // Validator parameter
    this.validator,

    // SVG prefix icon params
    this.prefixSvgAsset,
    this.prefixIconWidth,
    this.prefixIconHeight,
    this.prefixPadding,
    this.onPrefixTap,
    this.prefixConstraints,
  });

  TextInputType _getKeyboardType() {
    if (keyboardType != null) {
      return keyboardType!;
    }
    return onlyDigits ? TextInputType.number : TextInputType.text;
  }

  /// The error to show under the field, or null when there is none.
  ///
  /// Priority: the [validator], then [errorText], then the built-in checks
  /// (required, wrong script for this field, digits only).
  String? _errorText(BuildContext context) {
    final String text = controller.text;
    if (validator != null) return validator!(text.isEmpty ? null : text);
    if (errorText != null && errorText!.isNotEmpty) return errorText;

    // [textDirection] is the script this field is FOR (the Arabic or the
    // English name), not the UI language.
    final bool isArabicField = textDirection == ui.TextDirection.rtl;
    final bool isEnglishField = textDirection == ui.TextDirection.ltr;
    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
    final bool isEmpty = text.trim().isEmpty;

    final S s = S.of(context);
    if (isEmpty) return submitted ? s.fieldRequired : null;
    if (checkLanguage && isEnglishField && hasArabic) return s.englishOnly;
    if (checkLanguage && isArabicField && hasEnglish) return s.arabicOnly;
    if (isNotDigits) return s.onlyNumbersAllowed;
    return null;
  }

  Widget? _buildPrefixIcon() {
    if (prefixSvgAsset == null || prefixSvgAsset!.isEmpty) return null;

    final svg = CustomSvgImage.natural(
      assetPath: prefixSvgAsset!,
      width: (prefixIconWidth ?? 16).w,
      height: (prefixIconHeight ?? 16).h,
    );

    final padded = Padding(
      padding: prefixPadding ?? EdgeInsets.symmetric(horizontal: 8.w),
      child: svg,
    );

    if (onPrefixTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: hapticDown(onPrefixTap, HapticLevel.low),
        onTap: onPrefixTap,
        child: padded,
      );
    }
    return padded;
  }

  InputDecoration _decoration(bool showError) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      hoverColor: AppColors.transparent,
      hintText: hint,
      // KH vertical report p.3: the one hint style every field and
      // dropdown uses (12, the dropdown hint grey).
      hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
      filled: true,
      fillColor: fillColor ?? AppColors.background,
      isDense: true,
      counterText: '',
      prefixIcon: _buildPrefixIcon(),
      prefixIconConstraints:
          prefixConstraints ??
          BoxConstraints(
            minWidth: (prefixIconWidth ?? 16).w + 16.w,
            minHeight: (prefixIconHeight ?? 16).h,
          ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: BorderSide(
          color: showError ? AppColors.red : AppColors.transparent,
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: const BorderSide(color: AppColors.transparent, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.r),
        borderSide: BorderSide(
          color: showError
              ? AppColors.red
              : (showFocusBorder ? AppColors.primary : AppColors.transparent),
          width: 1,
        ),
      ),
    );
  }

  /// "length/500" under the field, written in the field's own direction.
  Widget _buildCharCount(BuildContext context) {
    final bool rtlField = textDirection == ui.TextDirection.rtl;
    return Align(
      alignment: rtlField ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          rtlField
              ? '${KhLocale.digits(context, 500)}/${KhLocale.digits(context, controller.text.length)}'
              : "${controller.text.length}/500",
          style: StyleText.fontSize12Weight400.copyWith(color: AppColors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? displayErrorText = _errorText(context);
    final bool showError = displayErrorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textDirection: textDirection,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: width?.w,
          height: height.h,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType: _getKeyboardType(),
            style:
                textStyle ??
                StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.blackButton,
                ),
            onChanged: (val) {
              if (onChanged != null) onChanged!(val);
            },
            decoration: _decoration(showError),
          ),
        ),
        if (displayErrorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              displayErrorText,
              textDirection: textDirection,
              style: StyleText.fontSize10Weight400.copyWith(
                color: AppColors.red,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (showCharCount) _buildCharCount(context),
      ],
    );
  }
}
