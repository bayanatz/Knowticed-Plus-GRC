import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:demo_app/core/helper/main_helper/arabic_number_formatter.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/helper/date_time_helper.dart';
// REMOVED_MODULE: import 'package:demo_app/core/features/external/services_mangment_module/core/new_theme.dart';

class DefaultFormField extends StatelessWidget {
  DefaultFormField({
    super.key,
    this.contentPadding,
    this.focusedBorder,
    this.showBorder,
    this.enabledBorder,
    this.textAlign,
    this.width,
    this.inputTextStyle,
    this.hintStyle,
    this.style,
    this.hintText,
    this.isObscureText,
    this.suffixIcon,
    this.backGroundColor,
    this.onChanged,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.prefixIcon2,
    this.label,
    this.readOnly,
    this.enabled,
    this.onTap,
    this.top,
    this.bottom,
    this.maxLength,
    this.expands,
    this.keyboardType,
    this.autovalidateMode,
    this.height,
    this.labelText,
    this.minLines,
    this.maxLines,
    this.collapsed,
    this.errorHeight,
    this.textDirection,
    this.alignCounterTextLeft = false,
    this.showCounter = false,
    this.helperText,
    this.focusNode,
    this.radius,
    this.initialValue,
    this.inputFormatters, // ✅ NEW: Add this parameter
  });

  final TextAlign? textAlign;
  final int? maxLength;
  final double? errorHeight;
  final bool? collapsed;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle, style;
  final String? hintText;
  final bool? isObscureText, readOnly, enabled, showBorder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefixIcon2;
  final Widget? label;
  final Color? backGroundColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double? top, bottom;
  final double? height;
  final double? width;
  final AutovalidateMode? autovalidateMode;
  final void Function()? onTap;
  final bool? expands;
  final TextInputType? keyboardType;
  final String? labelText;
  final int? minLines;
  final int? maxLines;
  final TextDirection? textDirection;
  final bool alignCounterTextLeft;
  final bool showCounter;
  final String? helperText;
  final FocusNode? focusNode;
  final double? radius;
  final List<TextInputFormatter>? inputFormatters; // ✅ NEW: Add this property
  bool isShowError = false;
  String? errorText = '';
  String? initialValue;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height?.h,
            child: TextFormField(
              initialValue: initialValue,
              // ✅ UPDATED: Combine existing formatters with new ones
              inputFormatters: [
                if (context.isArabic) ArabicNumberFormatter(),
                // ✅ NEW: Add custom formatters if provided
                if (inputFormatters != null) ...inputFormatters!,
              ],
              buildCounter: (context,
                  {required currentLength,
                    required isFocused,
                    required maxLength}) =>
              const SizedBox.shrink(),
              focusNode: focusNode,
              textDirection: textDirection,
              textInputAction: TextInputAction.done,
              keyboardType: keyboardType,
              expands: expands ?? false,
              autovalidateMode:
              autovalidateMode ?? AutovalidateMode.onUserInteraction,
              onTap: onTap,
              controller: controller,
              onChanged: onChanged,
              minLines: minLines,
              maxLines: maxLines ?? 1,
              readOnly: readOnly ?? false,
              enabled: enabled,
              maxLength: maxLength,
              textAlignVertical: (height ?? 0) < 60.h
                  ? TextAlignVertical.center
                  : TextAlignVertical.top,
              textAlign: textAlign ?? TextAlign.start,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                helperText: helperText,
                counterStyle: GoogleFonts.cairo(
                  color: AppColors.lightGrey,
                  fontWeight: FontWeight.w400,
                  fontSize: ContextExtension(context).isTablet ? 13.sp : 10.sp,
                ),
                hoverColor: Colors.transparent,
                hintStyle:
                hintStyle ?? AppTextStyles.font12SecondaryBlackCairoRegular,
                isCollapsed: collapsed ?? false,
                errorStyle: const TextStyle(fontSize: 0),
                labelText: labelText,
                prefixIcon: prefixIcon != null
                    ? Container(
                  height: 16.sp,
                  padding: EdgeInsets.symmetric(
                      vertical: 8.h, horizontal: 0.sp),
                  child: prefixIcon,
                )
                    : null,
                label: label,
                contentPadding: contentPadding,
                focusedBorder: focusedBorder ??
                    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius ?? 6.r),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: showBorder ?? false
                    ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide.none,
                )
                    : InputBorder.none,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: const BorderSide(
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius ?? 6.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                hintText: hintText,
                suffixIcon: suffixIcon != null
                    ? Container(
                  height: 16.sp,
                  width: 16.sp,
                  padding: EdgeInsets.symmetric(
                      vertical: 8.r, horizontal: 8.r),
                  child: suffixIcon,
                )
                    : null,
                fillColor: backGroundColor ?? (AppColors.background),                filled: true,
              ),
              obscureText: isObscureText ?? false,
              style: style ??
                  AppTextStyles.font14BlackCairoRegular.copyWith(
                    locale: Get.locale,
                  ),
              validator: (value) {
                var flag = validator?.call(value);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isShowError = flag != null;
                    if (isShowError) {
                      errorText = flag;
                    } else {
                      flag = '';
                    }
                  });
                });
                return flag;
              },
            ),
          ),
          if (showCounter) ...[
            SizedBox(
              height: 4.h,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection:
              alignCounterTextLeft ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (isShowError)
                  Text(
                    errorText!,
                    style: AppTextStyles.font12RedRegularCairo,
                  ),
                const Spacer(),
                Text(
                  alignCounterTextLeft
                      ? "${DateTimeHelper.formatInt(maxLength ?? 0).toArabicNumbers()}/${DateTimeHelper.formatInt(controller?.text.length ?? 0).toArabicNumbers()}"
                      : "${controller?.text.length}/$maxLength",
                  style: GoogleFonts.cairo(
                    color: AppColors.lightGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: context.isTablett ? 13.sp : 14.sp,
                  ),
                ),
              ],
            ),
          ],
          if (isShowError && showCounter == false) ...[
            SizedBox(
              height: 4.h,
            ),
            Text(
              errorText ?? '',
              style: AppTextStyles.font12RedRegularCairo,
            )
          ]
        ],
      ),
    );
  }
}