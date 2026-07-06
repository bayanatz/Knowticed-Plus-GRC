/// ******************* FILE INFO *******************
/// File Name: custom_textformfield.dart
/// Description: this is custom Text field can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_theme.dart';



class CustomValidatedTextFieldMaster extends StatelessWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final double height;
  final double? width;
  final int maxLines;
  final bool enabled;
  final bool showCharCount;
  final ValueChanged<String>? onChanged;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final bool onlyDigits;
  final bool submitted;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final bool allowMixedLanguages; // 👈 ADD THIS

  final int maxLength;

  final String? suffixUrl;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = 38,
    this.width,
    this.maxLines = 1,
    this.enabled = true,
    this.showCharCount = false,
    this.onChanged,
    this.textDirection = TextDirection.ltr,
    this.textAlign = TextAlign.start,
    this.allowMixedLanguages = false, // 👈 ADD THIS
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.hintStyle,
    this.fillColor,
    this.maxLength = 500,
    this.suffixUrl,
  });

  String _toArabicNum(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicNums[int.parse(e)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicField = textDirection == TextDirection.rtl;
    final bool isEnglishField = textDirection == TextDirection.ltr;
    final String text = controller.text;

    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    final bool hasEnglish = RegExp(r'[a-zA-Z]').hasMatch(text);
    final bool isNotDigits =
        onlyDigits && text.isNotEmpty && !RegExp(r'^\d+$').hasMatch(text);
    final bool isEmpty = text.trim().isEmpty;

    final bool showError =
        (submitted && isEmpty) ||
            (!isEmpty &&
                ((isEnglishField && hasArabic && !allowMixedLanguages) || // 👈 ADD CHECK
                    (isArabicField && hasEnglish && !allowMixedLanguages) || // 👈 ADD CHECK
                    isNotDigits));

    String errorText = '';
    if (isEmpty) {
      errorText = textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    } else if (isEnglishField && hasArabic && !allowMixedLanguages) { // 👈 ADD CHECK
      errorText = "Please use English characters only.";
    } else if (isArabicField && hasEnglish && !allowMixedLanguages) { // 👈 ADD CHECK
      errorText = "الرجاء استخدام الأحرف العربية فقط.";
    } else if (isNotDigits) {
      errorText = "Only numbers are allowed.";
    }

     final bool isDarkMode = AppTheme.isDark;
    final bool showCounter = showCharCount && !showError;

    final List<TextInputFormatter> formatters = [
      if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxLength),
    ];

    int currentLen = controller.text.characters.length;

    return Column(
      crossAxisAlignment: isArabicField
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty)
          Align(
            alignment: isArabicField
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Text(
              label!,
              textDirection: textDirection,
              style: AppTextStyles.font12BlackMediumCairo.copyWith(
                color: isDarkMode
                    ? AppColors.white
                    : AppColors.blackButton,
              ),
            ),
          ),
        if (label != null && label!.isNotEmpty) SizedBox(height: 6.h),
        SizedBox(
          width: width,
          height: maxLines > 1 ? null : height.h,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType: onlyDigits
                ? TextInputType.number
                : TextInputType.text,
            style:
                textStyle ??
                AppTextStyles.font12BlackMediumCairo.copyWith(
                  color: isDarkMode
                      ? AppColors.grey: AppColors.secondaryText
                      ,
                ),
            onChanged: onChanged,
            inputFormatters: formatters,
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: InputDecoration(
              hoverColor: Colors.transparent,
              hintText: hint.isNotEmpty ? hint : null,
              hintStyle:
                  hintStyle ??
                  AppTextStyles.font12BlackMediumCairo.copyWith(
                    color: isDarkMode
                        ? AppColors.grey: AppColors.secondaryText
                        ,
                  ),
              filled: true,
              fillColor:
                  fillColor ??
                  AppColors.background,
              isDense: true,
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              suffixIcon: suffixUrl == null
                  ? null
                  : Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: 12.w,
                        end: 12.w,
                        top: 8.h,
                        bottom: 8.h,
                      ),
                      child: SvgPicture.asset(
                        suffixUrl as String,
                        width: 12.sp,
                        height: 12.sp,
                        fit: BoxFit.fill,
                        color: isDarkMode
                            ? AppColors.grey: AppColors.secondaryText
                            ,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 18.h,
          child: showError
              ? Padding(
                  padding: EdgeInsets.only(top: 4.h, left: 4.w),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: AppColors.red,
                    ),
                  ),
                )
              : (showCounter
                    ? Align(
                        alignment: textDirection == TextDirection.rtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Text(
                          textDirection == TextDirection.rtl
                              ? "${_toArabicNum(currentLen)}/${_toArabicNum(maxLength)}"
                              : "$currentLen/$maxLength",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      )
                    : const SizedBox.shrink()),
        ),
      ],
    );
  }
}
