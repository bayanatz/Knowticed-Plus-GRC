import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/widgets/default_form_field.dart';

class TextSingleField extends StatelessWidget {
  final String typeName;
  final String? hintText;
  final Widget? icon;
  final TextEditingController? controller;
  final bool? isArabic;
  final double? height;
  final String? Function(String?)? validator;
  final bool isReadOnly;
  final bool enabled; // ✅ Added enabled parameter
  final void Function()? onTap;
  final String? helperText;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final dynamic Function(String)? onChange;
  final Color? backGroundColor;
  final Color? color;
  final int? maxLength, maxLines, minLines;
  final bool? showCounter;
  final bool enforceLanguage;

  const TextSingleField({
    super.key,
    this.isArabic,
    this.validator,
    this.hintText,
    this.controller,
    this.color,
    required this.typeName,
    this.isReadOnly = false,
    this.enabled = true, // ✅ Default to enabled
    this.icon,
    this.onTap,
    this.backGroundColor,
    this.helperText,
    this.style,
    this.keyboardType = TextInputType.text,
    this.onChange,
    this.maxLength,
    this.maxLines = 1,
    this.showCounter,
    this.height,
    this.minLines,
    this.enforceLanguage = false,
  });

  List<TextInputFormatter> _getInputFormatters(bool arabicMode) {
    if (!enforceLanguage) return [];

    if (arabicMode) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s\d.,!?()-]'))
      ];
    } else {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\d.,!?()-]'))
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Determine if field is Arabic based on isArabic parameter only
    final bool isArabicField = isArabic ?? false;

    return Column(
      children: [
        Align(
          // ✅ Title alignment based on field language
          alignment: isArabicField ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            typeName,
            style: AppTextStyles.font14BlackCairoRegular,
          ),
        ),
        SizedBox(height: 8.sp),
        // ✅ Wrap with Opacity for visual feedback when disabled
        Opacity(
          opacity: enabled ? 1.0 : 0.6, // ✅ 60% opacity when disabled
          child: DefaultFormField(
            minLines: minLines,
            expands: false,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: AppColors.secondaryText.withOpacity(.5)
            ),
            height: height,
            helperText: helperText,
            alignCounterTextLeft: isArabicField,
            textAlign: isArabicField ? TextAlign.right : TextAlign.left,
            hintText: hintText ?? (isArabicField ? 'اكتب هنا' : 'Text Here'.tr),
            maxLines: maxLines,
            showCounter: showCounter ?? false,
            maxLength: maxLength,
            prefixIcon: icon,
            hintStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: AppColors.secondaryText.withOpacity(.5)
            ),
            backGroundColor: AppColors.background,
            showBorder: true,
            width: double.infinity,
            controller: controller,
            validator: validator,
            readOnly: !enabled || isReadOnly, // ✅ Read-only when disabled or explicitly read-only
            onTap: enabled ? onTap : null, // ✅ Disable onTap when disabled
            keyboardType: keyboardType,
            contentPadding: const EdgeInsetsDirectional.only(
                top: 7, bottom: 7, start: 9, end: 9),
            onChanged: enabled ? onChange : null, // ✅ Disable onChange when disabled
            inputFormatters: _getInputFormatters(isArabicField),
            // ✅ Force text direction
            textDirection: isArabicField ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ],
    );
  }
}