import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class GRCCustomValidatedTextField extends StatelessWidget {
  final String label;
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
  final Color? fillColor;

  // ✅ New error text parameter
  final String? errorText;

  // ✅ New keyboard type parameter
  final TextInputType? keyboardType;

  // SVG prefix icon parameters
  final String? prefixSvgAsset;
  final double? prefixIconWidth;
  final double? prefixIconHeight;
  final EdgeInsetsGeometry? prefixPadding;
  final VoidCallback? onPrefixTap;
  final BoxConstraints? prefixConstraints;
  final String? suffixUrl;
  const GRCCustomValidatedTextField({
    super.key,
    required this.label,
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
    this.onlyDigits = false,
    this.submitted = false,
    this.textStyle,
    this.fillColor,

    // ✅ New error text parameter
    this.errorText,

    // ✅ New keyboard type parameter
    this.keyboardType,

    // SVG prefix icon params
    this.prefixSvgAsset,
    this.prefixIconWidth,
    this.prefixIconHeight,
    this.prefixPadding,
    this.onPrefixTap,
    this.prefixConstraints,
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

  // ✅ Helper method to determine the appropriate keyboard type
  TextInputType _getKeyboardType() {
    // If keyboardType is explicitly provided, use it
    if (keyboardType != null) {
      return keyboardType!;
    }

    // Fall back to the original onlyDigits logic
    return onlyDigits ? TextInputType.number : TextInputType.text;
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

    // ✅ Updated error logic to prioritize errorText parameter
    String? displayErrorText;
    bool showError = false;

    // First check if errorText parameter is provided (from validation)
    if (errorText != null && errorText!.isNotEmpty) {
      displayErrorText = errorText;
      showError = true;
    } else {
      // Fall back to original validation logic
      showError =
          (submitted && isEmpty) ||
          (!isEmpty &&
              ((isEnglishField && hasArabic) ||
                  (isArabicField && hasEnglish) ||
                  isNotDigits));

      if (showError) {
        if (isEmpty) {
          displayErrorText = textDirection == TextDirection.rtl
              ? "هذا الحقل مطلوب"
              : "This field is required.";
        } else if (isEnglishField && hasArabic) {
          displayErrorText = "Please use English characters only.";
        } else if (isArabicField && hasEnglish) {
          displayErrorText = "الرجاء استخدام الأحرف العربية فقط.";
        } else if (isNotDigits) {
          displayErrorText = "Only numbers are allowed.";
        }
      }
    }

    final bool isDarkMode = AppTheme.isDark;

    // Build optional prefix icon (SVG)
    Widget? buildPrefixIcon() {
      if (prefixSvgAsset == null || prefixSvgAsset!.isEmpty) return null;

      final svg = SvgPicture.asset(
        prefixSvgAsset!,
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
          onTap: onPrefixTap,
          child: padded,
        );
      }
      return padded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textDirection: textDirection,
          style: AppTextStyles.font14BlackCairoRegular.copyWith(
            color: isDarkMode
                ? AppColors.white
                : AppColors.blackButton,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: width?.w,
          height: height.sp,
          child: TextFormField(
            controller: controller,
            cursorColor: AppColors.primary,
            maxLines: maxLines,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,

            // ✅ Use the new helper method for keyboard type
            keyboardType: _getKeyboardType(),

            style:
                textStyle ??
                AppTextStyles.font12BlackCairoRegular.copyWith(
                  color: isDarkMode
                      ? AppColors.grey
                      : AppColors.secondaryText,
                ),
            onChanged: (val) {
              if (onChanged != null) onChanged!(val);
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.sp,
                horizontal: 8.w,
              ),
              hoverColor: Colors.transparent,
              hintText: hint,
              hintStyle: AppTextStyles.font10BlackCairoRegular.copyWith(
                color: isDarkMode
                    ? AppColors.grey
                    : AppColors.secondaryText,
              ),
              filled: true,
              fillColor:
                  fillColor ??
                  (isDarkMode
                      ? AppColors.chatBackground
                      : AppColors.background),
              isDense: true,
              counterText: '',
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
                            ? AppColors.grey
                            : AppColors.secondaryText,
                      ),
                    ),
              // Prefix SVG support
              prefixIcon: buildPrefixIcon(),
              prefixIconConstraints:
                  prefixConstraints ??
                  BoxConstraints(
                    minWidth: (prefixIconWidth ?? 16).w + 16.w,
                    minHeight: (prefixIconHeight ?? 16).h,
                  ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: showError ? Colors.red : Colors.transparent,
                  width: 1,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(color: Colors.transparent, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.r),
                borderSide: BorderSide(
                  color: showError ? Colors.red : AppColors.primary,
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // ✅ Show error text only when there's an actual error
        if (showError && displayErrorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              displayErrorText,
              textDirection: textDirection,
              style: TextStyle(fontSize: 10.sp, color: Colors.red),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        if (showCharCount)
          Align(
            alignment: textDirection == TextDirection.rtl
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                textDirection == TextDirection.rtl
                    ? "٥٠٠/${_toArabicNum(controller.text.length)}"
                    : "${controller.text.length}/500",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
