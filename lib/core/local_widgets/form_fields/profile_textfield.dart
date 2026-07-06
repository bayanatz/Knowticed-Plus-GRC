// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';

import 'package:demo_app/core/theme/app_colors.dart';

Widget textfieled(
    BuildContext context,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    String hits,
    String? initialValue,
    Widget? prefixIcon,
    {Widget? suffixIcon,
    TextEditingController? controller,
    Function(String)? onFinish,
    bool isReadOnly = false,
    bool isRole = false,
    bool isCSV = false,
    bool isRequestDialog = false,
    int? maxLines = 1,
    bool? hasError,
    bool? isRequests = false,
    int? maxLength}) {
  bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
  final ThemeController themeController = Get.put(ThemeController());
  final orientation = MediaQuery.of(context).orientation;
  bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  final errorNotifier = ValueNotifier('');
  bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: orientation == Orientation.portrait ? 0.004.h : 0.01.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: isTablet ? (isPortrait ? 0.04.h : 0.05.h) : 0.05.h,
          child: Theme(
            data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
            child: TextFormField(

              key: Key(initialValue.toString()),
              controller: controller,
              maxLines: maxLines,
              textAlignVertical: TextAlignVertical.bottom,
              initialValue: initialValue == null
                  ? initialValue
                  : initialValue.contains('@')
                      ? initialValue
                      : initialValue.capitalize,
              onChanged: (value) {
                onChanged!(value);
                final errorMessage = validator?.call(value) ?? '';
                errorNotifier.value = errorMessage;
              },
              onFieldSubmitted: (value) {
                onFinish!(value);
              },
              //   validator: validator,
              maxLength: maxLength,
              autovalidateMode: isCSV
                  ? AutovalidateMode.always
                  : AutovalidateMode.onUserInteraction,
              readOnly: isReadOnly,

              style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: orientation == Orientation.portrait
                      ? isTablet
                          ? FontConstants.fontSize012.h
                          : isRequestDialog == true && isTablet == false
                              ? FontConstants.fontSize016.h
                              : FontConstants.fontSize017.h
                      : 12.sp,
                  height: isCSV
                      ? 0
                      : isRole == true && !isTablet
                          ? (1.8)
                          : 0,
                  color: hasError == true
                      ? AppColors.delete
                      : themeController.currentTheme == AppColors.lightTheme
                          ? AppColors.colorBlack
                          : AppColors.colorWhite,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                suffixIcon: suffixIcon,
                errorStyle: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation == Orientation.portrait
                        ? FontConstants.fontSize014.h
                        : FontConstants.fontSize018.h,
                    color: AppColors.delete,
                    fontWeight: FontWeight.w500),
                focusColor: AppColors.textfieldColor,
                hoverColor: Colors.transparent,
                hintText: hits,
                counterText: '',

                prefixIcon: isDesktop
                    ? null
                    : (prefixIcon != null)
                        ? Padding(
                            padding:
                                MediaQuery.of(context).size.shortestSide > 600
                                    ? const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      )
                                    : EdgeInsets.only(
                                        left: 0.008.w,
                                        right: 10.0,
                                      ),
                            child: prefixIcon)
                        : null,
                prefixIconConstraints: BoxConstraints(
                  maxHeight: .035.h,
                  maxWidth: .06.h,
                ),
                hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: orientation == Orientation.portrait
                      ? isTablet
                          ? FontConstants.fontSize014.h
                          : isRequestDialog == true && isTablet == false
                              ? FontConstants.fontSize017.h
                              : FontConstants.fontSize017.h
                      : FontConstants.fontSize020.h,
                  color: AppColors.colorGrey,
                  fontWeight: FontWeight.w400,
                 
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: isCSV
                      ? BorderSide(color: AppColors.lightPrimary)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: isCSV
                      ? BorderSide(
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhite)
                      : BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.delete, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                //
                fillColor: isCSV
                    ? Colors.transparent
                    : isRole == true
                        ? Theme.of(context).colorScheme.onPrimary
                        : isRequests == true
                            ? Theme.of(context).colorScheme.inversePrimary
                            : AppColors.card,

              ),
            ),
          ),
        ),
        Builder(
          builder: (context) {
            return ValueListenableBuilder<String>(
              valueListenable: errorNotifier,
              builder: (context, errorMessage, _) {
                return errorMessage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: orientation == Orientation.portrait
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize018.h,
                            color: AppColors.delete,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : SizedBox.shrink();
              },
            );
          },
        ),
      ],
    ),
  );
}
