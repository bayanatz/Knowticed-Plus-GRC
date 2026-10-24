/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_validated_textfield.dart
/// Description: Declares `CustomValidatedTextFieldMaster`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// ******************* FILE INFO *******************
/// File Name: custom_textformfield.dart
/// Description: this is custom Text field can reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:knowticed_plus/core/custom/inputs/field_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/services.dart';

class CustomValidatedTextFieldMaster extends StatelessWidget {
  final String? label; // optional
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

  /// NEW: hard character cap (default 500)
  final int maxLength;

  /// ADDED 14/10/2026 — false drops the yellow focus outline (KH report p.15:
  /// "Remove this yellow border" on the approval-justification box).
  final bool showFocusBorder;

  /// ADDED 14/10/2026 — false turns off the English-only / Arabic-only
  /// check for free text that may be in either language (KH vertical report
  /// p.9: a reason written in Arabic was refused).
  final bool checkLanguage;

  const CustomValidatedTextFieldMaster({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.height = FieldSizing.height,
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
    this.hintStyle,
    this.fillColor,
    this.maxLength = 500, // <-- default cap
    this.showFocusBorder = true,
    this.checkLanguage = true,
  });

  String _toArabicNum(int number) {
    const arabicNums = [
      // R-31: an Arabic field's counter uses Arabic digits (٠ / ٥٠٠).
      '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    ];
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

    final bool wrongScript = checkLanguage &&
        ((isEnglishField && hasArabic) || (isArabicField && hasEnglish));
    final bool showError =
        (submitted && isEmpty) || (!isEmpty && (wrongScript || isNotDigits));

    String errorText = '';
    if (isEmpty) {
      errorText = textDirection == TextDirection.rtl
          ? "هذا الحقل مطلوب"
          : "This field is required.";
    } else if (checkLanguage && isEnglishField && hasArabic) {
      errorText = "Please use English characters only.";
    } else if (checkLanguage && isArabicField && hasEnglish) {
      errorText = "الرجاء استخدام الأحرف العربية فقط.";
    } else if (isNotDigits) {
      errorText = "Only numbers are allowed.";
    }

    Theme.of(context).brightness == Brightness.light;
    final bool showCounter = showCharCount && !showError;

    // Input formatters: enforce digits (optional) + length cap (hard)
    final List<TextInputFormatter> formatters = [
      if (onlyDigits) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(maxLength),
    ];

    // Helper for current length (already limited by formatter)
    int currentLen = controller.text.characters.length; // safer for graphemes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            textDirection: textDirection,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.text,
            ),
          ),
        if (label != null) SizedBox(height: 6.h),

        // Text field
        SizedBox(
          width: width,
          height: height,
          child: TextFormField(
            // ADDED 17/10/2026: a tap anywhere outside the field closes the
            // keyboard (it stayed open over the Messages list).
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: controller,
            maxLines: maxLines,
            // ADDED 14/10/2026 (vertical-alignment bug report): a single-line
            // field centres its text — typed text AND placeholder — in the
            // full box height. Multi-line keeps the caret on the first line.
            textAlignVertical: maxLines == 1
                ? TextAlignVertical.center
                : TextAlignVertical.top,
            enabled: enabled,
            textDirection: textDirection,
            textAlign: textAlign,
            keyboardType:
                onlyDigits ? TextInputType.number : TextInputType.text,
            style: textStyle ??
                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
            onChanged: onChanged,
            inputFormatters: formatters, // <-- enforce limits
            maxLength:
                maxLength, // <-- show native limit (hidden via buildCounter)
            maxLengthEnforcement: MaxLengthEnforcement.enforced, // <-- hard cap
            // 17/10/2026: NO counter at all (we draw our own below). With
            // `counterText: ''` Flutter still kept an empty counter row INSIDE
            // the fixed-height box, squeezing the input to about half height.
            buildCounter: (
              BuildContext context, {
              required int currentLength,
              required bool isFocused,
              int? maxLength,
            }) =>
                null,
            decoration: InputDecoration(
              hoverColor: Colors.transparent,
              hintText: hint,
              hintStyle: hintStyle ??
                  StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
              filled: true,
              fillColor: fillColor ?? AppColors.background,
              isDense: true,
              // ADDED 14/10/2026: the decorator fills the fixed height and
              // adds NO vertical padding of its own, so the centring above is
              // measured against the real input height (not the dense
              // default padding, which left the text sitting high).
              constraints: maxLines == 1
                  ? BoxConstraints.tightFor(height: height)
                  : null,
              contentPadding: maxLines == 1
                  ? EdgeInsets.symmetric(horizontal: 12.sp)
                  : EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
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
                borderSide: BorderSide(
                  color:
                      showFocusBorder ? AppColors.primary : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          ),
        ),

        // Fixed-height lane: error OR counter OR nothing
        SizedBox(
          height: 18.h, // keeps rows aligned
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
                        // Show current / max in the correct numeral system
                        textDirection == TextDirection.rtl
                            ? "\u2066${_toArabicNum(currentLen)} / ${_toArabicNum(maxLength)}\u2069"
                            : "$currentLen / $maxLength",
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    )
                  : const SizedBox.shrink()),
        ),
      ],
    );
  }
}
