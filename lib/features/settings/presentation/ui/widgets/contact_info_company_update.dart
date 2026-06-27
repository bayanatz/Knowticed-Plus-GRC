import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/country_picker_dialog.dart';

import 'package:demo_app/features/settings/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/controller/add_company_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/settings/settings_screen/views/owner_screens/company_info_update_dialog/company_contact_info.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

// Globals previously declared in the removed company_contact_info.dart
TextEditingController email = TextEditingController();
TextEditingController contactEmail = TextEditingController();
TextEditingController contactPhone = TextEditingController();
TextEditingController contactLastName = TextEditingController();

class ContactInfoCompanyUpdate extends StatefulWidget {
  const ContactInfoCompanyUpdate({super.key});

  @override
  State<ContactInfoCompanyUpdate> createState() =>
      _ContactInfoCompanyUpdateState();
}

class _ContactInfoCompanyUpdateState extends State<ContactInfoCompanyUpdate> {
  CompanyController addCompanyController = Get.find();
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;


    PickerDialogStyle pickerDialogStyle = PickerDialogStyle(
        searchFieldInputDecoration: InputDecoration(
          enabled: true,
          hintText: 'search',
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.scrim,
                width: 1.0,
              )),
          fillColor: Theme.of(context).colorScheme.inversePrimary,
          hintStyle: TextStyle(
            fontSize: !isTablet
                ? FontConstants.fontSize016.h
                : (isVertical
                    ? FontConstants.fontSize014.h
                    : FontConstants.fontSize020.h),
            fontWeight: FontWeight.w400,
            color: themeController.currentTheme == AppColors.lightTheme
                ? Theme.of(context).colorScheme.scrim
                : AppColors.colorWhite,
          ),
        ),
        width: .45.w,
        backgroundColor: Colors.white,
        countryCodeStyle: TextStyle(
          fontSize: !isTablet
              ? FontConstants.fontSize014.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ),
        countryNameStyle: TextStyle(
          fontSize: !isTablet
              ? FontConstants.fontSize014.h
              : FontConstants.fontSize020.h,
          fontWeight: FontWeight.w400,
          color: themeController.currentTheme == AppColors.lightTheme
              ? AppColors.colorBlack
              : AppColors.colorWhite,
        ));
    InputDecoration inputDecoration = InputDecoration(
      filled: true,
      contentPadding: Get.locale.toString().contains('en')
          ? const EdgeInsets.only(left: 10, top: 10)
          : const EdgeInsets.only(right: 10, top: 10),
      focusColor: const Color.fromRGBO(246, 246, 246, 1),
      hoverColor: const Color.fromRGBO(246, 246, 246, 1),
      hintText: 'Enter Phone Number'.tr,
      prefix: const SizedBox(
        height: 12,
      ),
      hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: !isTablet
              ? FontConstants.fontSize016.h
              : isVertical
                  ? FontConstants.fontSize014.h
                  : FontConstants.fontSize020.h,
          height: 1.4,
          color: AppColors.colorGrey,
          fontWeight: FontWeight.w400),
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
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8.0),
      ),
      fillColor: themeController.currentTheme == AppColors.lightTheme
          ? const Color(0xFFF6F6F6)
          : AppColors.colorBlack,
    );
    double widthSpace = 0.02.w;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Contact First Name"
                          : "اسم الشخص الأول غير صالح",
                    );
                  },
                  'First Name'.tr, // hintText
                  addCompanyController
                      .company!.firstName!.firstNames!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Contact First Name"
                          : "اسم الشخص الأول غير صالح",
                    );
                  },
                  'First Name'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon

                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Contact Last Name"
                          : "اسم الشخص الأخير غير صالح",
                    );
                  },
                  'Last Name'.tr, // hintText
                  addCompanyController
                      .company!.lastName!.lastNames!.last!.capitalize,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {},
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid Contact Last Name"
                          : "اسم الشخص الأخير غير صالح",
                    );
                  },
                  'Last Name'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: contactLastName,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Enter Email'.tr, // hintText
                  addCompanyController.company!.email!.emails!.last!,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                    email = value.trim() as TextEditingController;
                  },
                  (value) {
                    return Validator.email(value);
                  },
                  'Enter Email'.tr, // hintText
                  null, // initialValue
                  null, // prefixIcon
                  controller: contactEmail,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 0.007.h,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: isTablet ? (isVertical? 0.04.h : 0.05.h) : 0.05.h,
                width: 0.32.w,
                child: IntlPhoneField(
                   textAlign: TextAlign.start,
                  enabled: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue:
                      //  "${addCompanyController.company!.phone!.countryCode!.last}"
                      "${addCompanyController.company!.phone!.phones!.last}",
                  flagsButtonPadding: const EdgeInsets.only(left: 5, top: 4),
                  showDropdownIcon: false,
                  disableLengthCheck: true,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                        height:   1.2,
                        fontSize:  FontConstants.fontSize016.h
                            ,
                        color: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhite,
                        fontWeight: FontWeight.w400),
                   dropdownTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
                        height:   1.2,
                        fontSize:   FontConstants.fontSize016.h
                            ,
                        color: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhite,
                        fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    prefix: const SizedBox(
                      height: 17.5,
                    ),
                    filled: true,
                    contentPadding: Get.locale.toString().contains('en')
                        ? const EdgeInsets.only(left: 10, top: 10)
                        : const EdgeInsets.only(right: 10, top: 10),
                    hintText: 'Enter Your Mobile Number'.tr,
                    hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize020.h,
                        //  color: Myclors.textdeactivecolor,
                        fontWeight: FontWeight.w400),
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
                      borderSide:
                          const BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    fillColor:
                        themeController.currentTheme == AppColors.lightTheme
                            ? const Color(0xFFF6F6F6)
                            : AppColors.colorBlack,
                  ),
                  onCountryChanged: (value) {},
                  initialCountryCode: addCompanyController
                          .company!.phone!.countryCode?.lastOrNull ??
                      "EG",
                  onChanged: (value) {},
                  validator: (value) {
                    return Validator.number(value!.completeNumber);
                  },
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(
              width: widthSpace,
            ),
             Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // width: 0.32.w,
                     height: isTablet ? (isVertical? 0.04.h : 0.05.h) : 0.05.h,
                      child: IntlPhoneField(
                         textAlign: TextAlign.start,
                        // autovalidateMode: AutovalidateMode.always,
                        pickerDialogStyle: pickerDialogStyle,
                        flagsButtonPadding: const EdgeInsets.only(left: 5),
                        showDropdownIcon: false,
                        disableLengthCheck: true,
                    
                        style: AppFontStyle.cairoRegularStyle.copyWith(
                            height: isTablet ? (isVertical ? 1.75 : 1.8) : 1.2,
                            fontSize:!isTablet
                                ? FontConstants.fontSize016.h
                                : isVertical
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize020.h,
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400),
                        dropdownTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
                            height: isTablet ? (isVertical ? 1.6 : 1.6) : 1.2,
                            fontSize: !isTablet
                                ? FontConstants.fontSize016.h
                                : isVertical
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize020.h,
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite,
                            fontWeight: FontWeight.w400),
                        decoration: inputDecoration,
                        onCountryChanged: (value) {},
                        initialCountryCode: "EG",
                    
                        onChanged: (value) {
                           setState(() {
                              _errorMessage =
                                  Validator.number(value.completeNumber);
                            });
                          print('countryISOCode ${value.countryISOCode}');
                          print('number ${value.number}');
                          print('countryCode ${value.countryCode}');
                          print('completeNumber ${value.completeNumber}');
                          contactPhone.text = value as String;
                        },
                        // validator: (value) {
                        //   return Validator.number(value!.completeNumber);
                        // },
                      ),
                    ),
                     if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize:  isVertical
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize018.h,
                              color: AppColors.delete,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            // Expanded(
            //   child: SizedBox(
            //     width: 0.32.w,
            //     child: textfieled(
            //       context,
            //       (value) {},
            //       (value) {
            //         return Validator.number(value);
            //       },
            //       'Enter Phone'.tr, // hintText
            //       null, // initialValue
            //       null, // prefixIcon
            //       controller: contactPhone,
            //       isReadOnly: false,
            //     ),
            //   ),
            // )
          ],
        )
      ],
    );
  }
}
