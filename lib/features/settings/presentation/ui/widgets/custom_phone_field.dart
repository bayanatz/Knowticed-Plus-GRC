import 'dart:async';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/country_picker_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/phone_number.dart';



import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';


class CustomPhoneField extends StatefulWidget {
  final Function(PhoneNumber)? onChanged;
  final String? initialCountryCode;
  final String? initialValue;
  final FutureOr<String?> Function(PhoneNumber?)? validator;

  const CustomPhoneField({
    Key? key,
    required this.onChanged,
    this.initialCountryCode,
    this.initialValue,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return IntlPhoneField(
      autovalidateMode: AutovalidateMode.always,
       textAlign: TextAlign.start,
      pickerDialogStyle: PickerDialogStyle(
        searchFieldInputDecoration: InputDecoration(
          enabled: true,
          hintText: 'search',
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.scrim,
              width: 1.0,
            ),
          ),
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          hintStyle: TextStyle(
            fontSize: isVertical
                ? FontConstants.fontSize016.h
                : FontConstants.fontSize020.h,
            fontWeight: FontWeight.w400,
            color: themeController.currentTheme == AppColors.lightTheme
                ? Theme.of(context).colorScheme.scrim
                : AppColors.colorWhite,
          ),
        ),
        width: .45.w,
        backgroundColor: Colors.white,
        countryCodeStyle: TextStyle(
          fontSize: isVertical
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ),
        countryNameStyle: TextStyle(
          fontSize: isVertical
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ),
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 5),
      showDropdownIcon: false,
      disableLengthCheck: true,
      style: AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isVertical
            ? FontConstants.fontSize016.h
            : FontConstants.fontSize020.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhite,
        fontWeight: FontWeight.w400,
      ),
      dropdownTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isVertical
            ? FontConstants.fontSize016.h
            : FontConstants.fontSize020.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhite,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        contentPadding: Get.locale.toString().contains('en')
            ? const EdgeInsets.only(  top: 10)
            : const EdgeInsets.only(  top: 10),
        focusColor: const Color.fromRGBO(246, 246, 246, 1),
        hoverColor: const Color.fromRGBO(246, 246, 246, 1),
        hintText: 'Enter The Phone Number'.tr,
        prefix:   SizedBox(
          height: isTablet?
          ( isVertical
              ? 10 : 0) : 20,
        ),
        hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: isVertical
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
          height:  isTablet?
          (isVertical ? 1.2 : 1 ) : 1.2,
          color: AppColors.colorGrey,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize:   FontConstants.fontSize018.h,
          height: isVertical ? 1.2 : 1.4,
          color: AppColors.delete,
          fontWeight: FontWeight.w400,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        fillColor: themeController.currentTheme == AppColors.lightTheme
            ? const Color(0xFFF6F6F6)
            :  AppColors.colorBlack,
      ),
      onCountryChanged: (value) {},
     // initialCountryCode: widget.initialCountryCode,
      
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
