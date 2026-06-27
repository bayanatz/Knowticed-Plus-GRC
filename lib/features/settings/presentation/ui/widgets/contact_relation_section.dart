import 'dart:async';
import 'package:demo_app/core/theme/app_colors.dart';

import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart' hide themeController;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/country_picker_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/phone_number.dart';

import 'package:demo_app/features/settings/presentation/ui/widgets/custom_phone_field.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

class ContactRelationSection extends StatelessWidget {
  final Function(String)? firstNameOnChanged;
  final String? Function(String?)? firstNameValidator;
  final String? firstNameInitialValue;
  final String firstNameHint;

  final Function(String)? emailOnChanged;
  final String? Function(String?)? emailValidator;
  final String? emailInitialValue;
  final String emailHint;

  final Function(PhoneNumber)? phoneOnChanged;
  final String? initialCountryCode;
  final String? phoneInitialValue;
  final FutureOr<String?> Function(PhoneNumber?)? phoneValidator;

  const ContactRelationSection({
    Key? key,
    this.firstNameOnChanged,
    this.firstNameValidator,
    this.emailOnChanged,
    this.emailValidator,
    this.firstNameInitialValue,
    this.emailInitialValue,
    required this.firstNameHint,
    required this.emailHint,
    this.phoneOnChanged,
    this.initialCountryCode,
    this.phoneInitialValue,
    this.phoneValidator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return isVertical
        ? Column(
            children: [
              textfieled(
                context,
                null,
                null,
                firstNameHint.tr,
                firstNameInitialValue,
                null, // prefixIcon
                controller: null,
                isReadOnly: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0.007.h),
                child: phoneWidget(context),
              ),
              textfieled(
                context,
                null,
                null,
                emailHint.tr,
                emailInitialValue,
                null, // prefixIcon
                controller: null,
                isReadOnly: true,
              ),
            ],
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                      left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                    ),
                    child: textfieled(
                      context,
                      null,
                      null,
                      firstNameHint.tr,
                      firstNameInitialValue,
                      null, // prefixIcon
                      controller: null,
                      isReadOnly: true,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right:
                            Get.locale.toString().contains('en') ? 0.02.h : 0,
                        left:
                            Get.locale.toString().contains('ar') ? 0.02.h : 0),
                    child: SizedBox(
                      height: 0.05.h,
                      child: phoneWidget(context),
                    ),
                  ),
                ),
                Expanded(
                  child: textfieled(
                    context,
                    null,
                    null,
                    emailHint.tr,
                    emailInitialValue,
                    null, // prefixIcon
                    controller: null,
                    isReadOnly: true,
                  ),
                ),
              ],
            ),
          );
  }

  Widget phoneWidget(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return IntlPhoneField(
      textAlign: TextAlign.start,
      readOnly: true,
      enabled: false,
      pickerDialogStyle: PickerDialogStyle(
        searchFieldInputDecoration: InputDecoration(
          enabled: false,
          hintText: 'search',
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.scrim,
                  width: 1.0)),
          fillColor:
          Theme.of(context).colorScheme.inversePrimary,
          hintStyle: TextStyle(
            fontSize: isPortrait
                ? FontConstants.fontSize016.h
                : FontConstants.fontSize020.h,
            fontWeight: FontWeight.w400,
            color: themeController.currentTheme.value ==
                AppColors.lightTheme
                ? Theme.of(context).colorScheme.scrim
                : AppColors.colorWhite,
          ),
        ),
        width: .45.w,
        backgroundColor: Colors.white,
        countryCodeStyle: TextStyle(
          fontSize: isPortrait
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme.value ==
              AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ),
        countryNameStyle: TextStyle(
          fontSize: isPortrait
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme.value ==
              AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ),
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 5),
      showDropdownIcon: false,
      disableLengthCheck: true,
      style: AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isPortrait
            ? FontConstants.fontSize017.h
            : FontConstants.fontSize020.h,
        color: themeController.currentTheme.value ==
            AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhite,
        fontWeight: FontWeight.w400,
        height: isTablet ? (isPortrait ? 1.7 : 1.8) : 2.1,
      ),
      dropdownTextStyle:
      AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: isPortrait
            ? FontConstants.fontSize016.h
            : FontConstants.fontSize020.h,
        color: themeController.currentTheme.value ==
            AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhite,
        fontWeight: FontWeight.w400,
        height: isTablet ? (isPortrait ? 1.6 : 1.6) : 2.4,
      ),
      decoration: InputDecoration(
        filled: true,
        contentPadding: Get.locale.toString().contains('en')
            ? const EdgeInsets.only(top: 10)
            : const EdgeInsets.only(top: 10),
        focusColor: const Color.fromRGBO(246, 246, 246, 1),
        hoverColor: const Color.fromRGBO(246, 246, 246, 1),
        hintText: 'Enter The Phone Number'.tr,
        prefix: SizedBox(
            height: isTablet ? (isPortrait ? 10 : 0) : 20),
        hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: isPortrait
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize020.h,
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
          fontSize: FontConstants.fontSize018.h,
          height: isPortrait ? 1.2 : 1.4,
          color: AppColors.delete,
          fontWeight: FontWeight.w400,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        fillColor: themeController.currentTheme.value ==
            AppColors.lightTheme
            ? const Color(0xFFF6F6F6)
            : AppColors.colorBlack,
      ),
      initialCountryCode: initialCountryCode,
      initialValue: phoneInitialValue,
    );
  }
}
