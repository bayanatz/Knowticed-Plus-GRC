import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/country_picker_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/location_info_update.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_health_insurance.dart' hide insuranceName2;
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/profile_screen.dart';

class HealthInsuranceUpdate extends StatefulWidget {
  final bool isRequestMobile;
  const HealthInsuranceUpdate({this.isRequestMobile = false, super.key});

  @override
  State<HealthInsuranceUpdate> createState() => _HealthInsuranceUpdateState();
}

class _HealthInsuranceUpdateState extends State<HealthInsuranceUpdate> {
 
  @override
  void initState() {
    insuranceName2 = null;
    insurancePolice2 = null;
    insurancePhone2 = null;
    super.initState();
  }
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
/*            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  isReadOnly: true,
                  context,
                  (value) {
                   
                  },
                  (value) {
                    
                  },
                  'Enter Insurance Name'.tr, // hintText
                  capitalize('${employee!.insuranceName?.insuranceNames?.lastOrNull}'),
                  null, // prefixIcon
                  controller: null,
                ),
              ),
            ),*/
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  isReadOnly: false,
                  context,
                  (value) {
                    insuranceName2 = value.trim().toLowerCase();
                  },
                  (value) {
                    return Validator.text(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Insurance Name"
                            : "اسم التأمين غير صالح");
                  },
                  'Enter Insurance Name'.tr, // hintText
                  null,
                  null, // prefixIcon
                  controller: null,
                ),
              ),
            ),
          ],
        ),
        
        Padding(
          padding:   EdgeInsets.symmetric(vertical:0.007.h ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
         /*     Expanded(
                child: SizedBox(
                  height: isTablet ? (isVertical? 0.04.h : 0.05.h) : 0.05.h,
                  width: 0.32.w,
                  child: IntlPhoneField(
                     textAlign: TextAlign.start,
                     enabled: false,
                    // autovalidateMode: AutovalidateMode.always,
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
                              )),
                          fillColor: Theme.of(context).colorScheme.inversePrimary,
                          hintStyle: TextStyle(
                            fontSize: widget.isRequestMobile == true
                                ? FontConstants.fontSize016.h
                                : isVertical
                                    ? FontConstants.fontSize014.h
                                    : FontConstants.fontSize020.h,
                            fontWeight: FontWeight.w400,
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? Theme.of(context).colorScheme.scrim
                                : AppColors.colorWhite,
                          ),
                        ),
                        width: .32.w,
                        backgroundColor: Colors.white,
                        countryCodeStyle: TextStyle(
                          fontSize: widget.isRequestMobile == true
                              ? FontConstants.fontSize016.h
                              : isVertical
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize020.h,
                          fontWeight: FontWeight.w400,
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhite,
                        ),
                        countryNameStyle: TextStyle(
                          fontSize: widget.isRequestMobile == true
                              ? FontConstants.fontSize016.h
                              : isVertical
                                  ? FontConstants.fontSize014.h
                                  : FontConstants.fontSize020.h,
                          fontWeight: FontWeight.w400,
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorBlack
                              : AppColors.colorWhite,
                        )),
                    flagsButtonPadding: const EdgeInsets.only(left: 5),
                    showDropdownIcon: false,
                    disableLengthCheck: true,
                   
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        height: isTablet ? (isVertical ? 1.65 : 2) : 1.2,
                        fontSize: widget.isRequestMobile == true
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
                        fontSize: widget.isRequestMobile == true
                            ? FontConstants.fontSize016.h
                            : isVertical
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize020.h,
                        color: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhite,
                        fontWeight: FontWeight.w400),
                    decoration: InputDecoration(
                      filled: true,
                      // contentPadding: Get.locale.toString().contains('en')
                      //     ? const EdgeInsets.only(left: 10, top: 10)
                      //     : const EdgeInsets.only(right: 10, top: 10),
                      focusColor: const Color.fromRGBO(246, 246, 246, 1),
                      hoverColor: const Color.fromRGBO(246, 246, 246, 1),
                      hintText: 'Enter The Phone Number'.tr,
                      prefix: const SizedBox(
                        height: 12,
                      ),
                      hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: widget.isRequestMobile == true
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
                        borderSide:
                            const BorderSide(color: Colors.red, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      fillColor:
                          (themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? const Color(0xFFF6F6F6)
                              : AppColors.colorBlack),
                    ),
                    onCountryChanged: (value) {},
                    initialCountryCode:
                        employee!.insurancePhoneNumber?.countryCode?.lastOrNull ??
                            "EG",
                    initialValue: employee!
                        .insurancePhoneNumber?.insurancePhoneNumber?.lastOrNull,
                    onChanged: (value) {
                      print('countryISOCode ${value.countryISOCode}');
                      print('number ${value.number}');
                      print('countryCode ${value.countryCode}');
                      print('completeNumber ${value.completeNumber}');
                      insurancePhone2 = value;
                    },
                    validator: (value) {
                      return Validator.number(value!.completeNumber);
                    },
                    readOnly: true,
                  ),
                ),
              ),*/
              SizedBox(width: spaceWidth),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: isTablet ? (isVertical? 0.04.h : 0.05.h) : 0.05.h,
                      child: IntlPhoneField(
                         textAlign: TextAlign.start,
                        // autovalidateMode: AutovalidateMode.always,
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
                                  )),
                              fillColor: Theme.of(context).colorScheme.inversePrimary,
                              hintStyle: TextStyle(
                                fontSize: widget.isRequestMobile == true
                                    ? FontConstants.fontSize016.h
                                    : isVertical
                                        ? FontConstants.fontSize014.h
                                        : FontConstants.fontSize020.h,
                                fontWeight: FontWeight.w400,
                                color: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? Theme.of(context).colorScheme.scrim
                                    : AppColors.colorWhite,
                              ),
                            ),
                            width: .32.w,
                            backgroundColor: Colors.white,
                            countryCodeStyle: TextStyle(
                              fontSize: widget.isRequestMobile == true
                                  ? FontConstants.fontSize016.h
                                  : isVertical
                                      ? FontConstants.fontSize014.h
                                      : FontConstants.fontSize020.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            ),
                            countryNameStyle: TextStyle(
                              fontSize: widget.isRequestMobile == true
                                  ? FontConstants.fontSize016.h
                                  : isVertical
                                      ? FontConstants.fontSize014.h
                                      : FontConstants.fontSize020.h,
                              fontWeight: FontWeight.w400,
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            )),
                        flagsButtonPadding: const EdgeInsets.only(left: 5),
                        showDropdownIcon: false,
                        disableLengthCheck: true,
                      
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                        height: isTablet ? (isVertical ? 1.65 : 2) : 1.2,
                        fontSize: widget.isRequestMobile == true
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
                        fontSize: widget.isRequestMobile == true
                            ? FontConstants.fontSize016.h
                            : isVertical
                                ? FontConstants.fontSize014.h
                                : FontConstants.fontSize020.h,
                        color: themeController.currentTheme ==
                                AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhite,
                        fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          filled: true,
                          // contentPadding: Get.locale.toString().contains('en')
                          //     ? const EdgeInsets.only(left: 10, top: 10)
                          //     : const EdgeInsets.only(right: 10, top: 10),
                          focusColor: const Color.fromRGBO(246, 246, 246, 1),
                          hoverColor: const Color.fromRGBO(246, 246, 246, 1),
                          hintText: 'Enter The Phone Number'.tr,
                          prefix: const SizedBox(
                            height: 12,
                          ),
                          hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: widget.isRequestMobile == true
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
                            borderSide:
                                const BorderSide(color: Colors.red, width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          fillColor:
                              (themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? const Color(0xFFF6F6F6)
                              : AppColors.colorBlack),
                        ),
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
                           insurancePhone2 = value;
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
                                fontSize: isVertical 
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
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
       /*     Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  isReadOnly: true,
                  context,
                  (value) {
                  
                  },
                  (value) {
                    
                  },
                  'Enter Insurance Police Number'.tr, // hintText
                  employee!
                      .insurancePoliceNumber?.insurancePoliceNumber?.lastOrNull,
                  null, // prefixIcon
                  controller: null,
                ),
              ),
            ),*/
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  isReadOnly: false,
                  context,
                  (value) {
                    insurancePolice2 = value.trim();
                  },
                  (value) {
                    return Validator.insurancePolicyNumber(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Insurance Police Number"
                            : "رقم بوليصة التأمين غير صالحة");
                  },
                  'Enter Insurance Police Number'.tr, // hintText
                  null,
                  null, // prefixIcon
                  controller: null,
                ),
              ),
            ),
          ],
        ),
       
      ],
    );
  }
}
