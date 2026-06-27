import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/settings/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/location_info_update.dart';
import 'package:demo_app/features/settings/core_widgets/form_fields/profile_textfield.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/enums/enum.dart';


import 'package:demo_app/core/constants/nationalities_list.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/personal_info_screen.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

import 'package:demo_app/features/settings/presentation/ui/pages/profile_screen.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';

class PersonalDataUpdate extends StatefulWidget {
  const PersonalDataUpdate({super.key});

  @override
  State<PersonalDataUpdate> createState() => _PersonalDataUpdateState();
}

class _PersonalDataUpdateState extends State<PersonalDataUpdate> {
  final List<String> gender = [
    'Male'.tr,
    'Female'.tr,
    'Rather Not Say'.tr,
  ];

  final List<String> maritalStatus = [
    "Single".tr,
    "Married".tr,
    "Divorced".tr,
    "Widowed".tr,
    "Separated".tr,
    "Engaged".tr
  ];

  void initState() {
  /*  firstName2 = null;
    middleName2 = null;
    lastName2 = null;
    selectedGender = null;
    selectedNationality = null;
    selectedMaritalStatus = null;
    birthDate2 = null;*/
    super.initState();
  }
  SettingsController settingsController = Get.find();

  @override
  Widget build(BuildContext context) {
    final isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    DateTime? selectedDate;
    List<DateTime?> rangeDatePickerValueWithDefaultValue = [];
    Future<void> _selectDate(BuildContext context) async {
      final List<DateTime?>? picked = await DatePicker().showDatePicker(
          context,
          rangeDatePickerValueWithDefaultValue,
          DateTime.now(),
          CalendarDatePicker2Type.single);

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked[0];
          final DateFormat formatter = DateFormat('MM/dd/yyyy');
          String formattedDate = formatter.format(picked[0] as DateTime);

        //  birthDate2 = formattedDate;
         // birthDate2 = formattedDate;
        });
      }
    }

    final orientation = MediaQuery.of(context).orientation;
    Color backColor = themeController.currentTheme == AppColors.lightTheme
        ? const Color(0xFFF6F6F6)
        : const Color(0xFF545454);

    Color buttonColor = themeController.currentTheme == AppColors.lightTheme
        ? const Color(0xFFF6F6F6)
        : const Color(0xFF545454);

    EdgeInsets dropdownPadding = EdgeInsets.symmetric(
      horizontal: orientation == Orientation.portrait ? 0.04.w : 0.01.w,
    );

    TextStyle dropDownTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isTablet
          ? (orientation == Orientation.portrait
              ? FontConstants.fontSize016.h
              : FontConstants.fontSize023.h)
          : FontConstants.fontSize017.h,
      color: AppColors.colorGrey,
      fontWeight: FontWeight.w400,
      height: orientation == Orientation.portrait ? 0.0014.h : 0.002.h,
    );

    double buttonWidth = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.620.w : 0.32.w)
        : double.infinity;

    double dropdownWidth = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.35.w : 0.32.w)
        : 0.4.w;

    double buttonHeight = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.04.h : 0.05.h)
        : 0.05.h;

    double? dropdownHeight =
        MediaQuery.of(context).size.shortestSide > 600 ? null : 0.2.h;

    EdgeInsets? itemPadding = MediaQuery.of(context).size.shortestSide > 600
        ? null
        : EdgeInsets.symmetric(vertical: 0.0.h);

   /* selectedGender != null
        ? selectedGender = selectedGender!.tr
        : selectedGender = null;*/

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  isRequestDialog: true,
                  (value) {
                    //     firstName2 = value.trim().toLowerCase();
                  },
                  (value) {},
                  'Enter Your First Name'.tr, // hintText
                  capitalize('${employee!.firstName!.last}'),
                  //  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  (value) {
                //    firstName2 = value.trim().toLowerCase();
                  },
                  (value) {
                    return Validator.name(
                      value,
                      Get.locale.toString().contains('en')
                          ? "Invalid First Name"
                          : "الاسم الأول غير صالح",
                    );
                  },
                  isRequestDialog: true,
                  'Enter Your First Name'.tr, // hintText
                  null,
                  //  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  isRequestDialog: true,
                  (value) {
                  //  middleName2 = value.trim().toLowerCase();
                  },
                  (value) {
                    return Validator.name(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Middle Name"
                            : "الاسم الاوسط غير صالح");
                  },
                  'Enter Your Middle Name'.tr, // hintText
                  capitalize('${employee!.middleName!.last}'),
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) {
                 //   middleName2 = value.trim().toLowerCase();
                  },
                  (value) {
                    return Validator.name(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Middle Name"
                            : "الاسم الاوسط غير صالح");
                  },
                  'Enter Your Middle Name'.tr, // hintText
                  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  context,
                  (value) {},
                  (value) {},
                  'Enter Your Last Name'.tr, // hintText
                  capitalize('${employee!.lastName!.last}'),
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  context,
                  isRequestDialog: true,
                  (value) {
                 //   lastName2 = value.trim().toLowerCase();
                  },
                  (value) {
                    return Validator.name(
                        value,
                        Get.locale.toString().contains('en')
                            ? "Invalid Last Name"
                            : "اسم العائلة غير صالح");
                  },
                  'Enter Your Last Name'.tr, // hintText
                  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: false,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: isVertical
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: textfieled(
                context,
                isRequestDialog: true,
                (value) {},
                (value) {},
                'Nationality'.tr, // hintText
                capitalize(employee!.nationality?.lastOrNull ?? '')
                    .tr,
                //  null,
                null, // prefixIcon
                controller: null,
                isReadOnly: true,
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomDropdownButton2(
              
                dropdownPadding: dropdownPadding,
                dropDownTextStyle: dropDownTextStyle,
                buttonWidth: buttonWidth,
                dropdownWidth: dropdownWidth,
                buttonHeight: buttonHeight,
                dropdownHeight: dropdownHeight,
                itemPadding: itemPadding,
                hint: 'Nationality'.tr,
                borded: false,
                dropdownItems: nationality,
                buttonPadding: EdgeInsets.symmetric(
                    horizontal: orientation == Orientation.landscape
                        ? 0.022.h
                        : 0.015.h),
               value: nationality.first,
                onChanged: (value) {
                  setState(() {
                   // selectedNationality = value;
                  });
                },
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isReadOnly: true,
                  context,
                  (value) async {
                    //  await _selectDate(context);
                  },
                  (value) {
                    return Validator.date(value);
                  },
                  'Enter Your Birth Date'.tr,
                  isRequestDialog: true,
    settingsController.personalInformationController.   birthDate.text.isEmpty
                      ? Get.locale.toString().contains('en')
                          ? employee!.birthDay?.lastOrNull
                          : convertNumberToArabic(
                              employee!.birthDay?.lastOrNull ?? '')
                      : settingsController.personalInformationController.birthDate.text,
                  null,
                  controller: null,
                ),
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: SizedBox(
                width: 0.32.w,
                child: textfieled(
                  isRequestDialog: true,
                  isReadOnly: true,
                  context,
                  (value) async {
                    await _selectDate(context);
                  },
                  (value) {
                    return Validator.date(value);
                  },
                  'Enter Your Birth Date'.tr,
                  /*birthDate2*/ "",
                  null,
                  controller: null,
                  suffixIcon: InkWell(
                    onTap: () {
                      _selectDate(context);
           /*           hapticController.triggerHapticFeedback(
                          vibration: VibrateType.lightImpact,
                          hapticFeedback: HapticFeedback.lightImpact);*/
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: (isTablet
                            ? (isVertical ? 0.025.w : 0.014.w)
                            : 0.038.w),
                        left: (isTablet
                            ? (isVertical ? 0.025.w : 0.014.w)
                            : 0.038.w),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/newCalenderFixed.svg',
                        color: birthDate2?.isEmpty ??
                                true  
                            ? null
                            : (themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhite),
                        height: isVertical ? 0.02.h : 0.03.h,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: isVertical
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: textfieled(
                context,
                isRequestDialog: true,
                (value) {},
                (value) {},
                'Select Gender'.tr, // hintText
                capitalize(employee!.gender?.lastOrNull ?? '').tr,
                //  null,
                null, // prefixIcon
                controller: null,
                isReadOnly: true,
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomDropdownButton2(
             
                dropdownPadding: dropdownPadding,
                dropDownTextStyle: dropDownTextStyle,
                buttonWidth: buttonWidth,
                dropdownWidth: dropdownWidth,
                buttonHeight: buttonHeight,
                dropdownHeight: dropdownHeight,
                itemPadding: itemPadding,
                hint: 'Select Gender'.tr,
                borded: false,
                dropdownItems: gender,
                buttonPadding: EdgeInsets.symmetric(
                    horizontal: orientation == Orientation.landscape
                        ? 0.022.h
                        : 0.015.h),
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 0.0.h),
          child: Row(
            crossAxisAlignment: isVertical
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: textfieled(
                  context,
                  isRequestDialog: true,
                  (value) {},
                  (value) {},
                  'Marital Status'.tr, // hintText
                  capitalize(
                          employee!.maritalStatus?.lastOrNull ??
                              '')
                      .tr,
                  //  null,
                  null, // prefixIcon
                  controller: null,
                  isReadOnly: true,
                ),
              ),
              SizedBox(width: spaceWidth),
              Expanded(
                child: CustomDropdownButton2(
                
                  dropdownPadding: dropdownPadding,
                  dropDownTextStyle: dropDownTextStyle,
                  buttonWidth: buttonWidth,
                  dropdownWidth: dropdownWidth,
                  buttonHeight: buttonHeight,
                  dropdownHeight: dropdownHeight,
                  itemPadding: itemPadding,
                  hint: 'Marital Status'.tr,
                  borded: false,
                  dropdownItems: maritalStatus,
                  buttonPadding: EdgeInsets.symmetric(
                      horizontal: orientation == Orientation.landscape
                          ? 0.022.h
                          : 0.015.h),
                  value: selectedMaritalStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedMaritalStatus = value;
                    });
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
