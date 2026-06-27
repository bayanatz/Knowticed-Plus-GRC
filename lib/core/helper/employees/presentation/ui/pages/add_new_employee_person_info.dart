// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:demo_app/core/helper/employees/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/country_picker_dialog.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/intl_phone_field.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/phone_number.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/column_request_data.dart';

import 'package:demo_app/core/custom/loading.dart';

import 'package:demo_app/core/constants/nationalities_list.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/main_helper/validator.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/add_new_employee_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';

import 'package:demo_app/core/helper/employees/presentation/controller/add_new_employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_employee_page_widgets/add_employee_image.dart';

// ignore: must_be_immutable
class AddNewEmployeePersonInfo extends StatefulWidget {
  AddNewEmployeePersonInfo({
    super.key,
    required this.widthOfData,
    required this.firstNameState,
    required this.firstNameStateInArabic,
    required this.lastNameState,
    required this.lastNameStateInArabic,
    required this.gender,
    required this.genderState,
    required this.emailState,
    required this.phoneState,
    required this.postalState,
    required this.countryState,
    required this.addressState,
    required this.cityState,
    required this.provinceState,
    required this.nation,
    required this.nationState,
    required this.maritalStatus,
    required this.maritalStatusState,
    required this.language,
    required this.languageState,
    required this.cityfinishState,
    required this.countryfinishState,
    required this.addressfinishState,
    required this.provincefinishState,
    required this.emailfinishState,
    required this.firstNamefinishState,
    required this.lastNamefinishState,
    required this.phonefinishState,
    required this.personInfoCount,
    required this.personInfoState,
    required this.birthDateState,
    required this.nationalDateState,
    required this.passportDateState,
    required this.birthDatefinishState,
    this.isPreview = false,
    this.addEmployeeController,
    required this.MiddleNameState,
    required this.MiddleNameStateInArabic,
    required this.MiddlenNamefinishState,
    required this.nationalIdfinishState,
    required this.nationalIdState,
    required this.passportNumberState,
  });
  double widthOfData;

  ValueChanged<TextEditingController> firstNameState;
  ValueChanged<TextEditingController> firstNameStateInArabic;
  ValueChanged<TextEditingController> MiddleNameState;
  ValueChanged<TextEditingController> MiddleNameStateInArabic;
  ValueChanged? MiddlenNamefinishState;
  ValueChanged? firstNamefinishState;

  ValueChanged<String> birthDateState;
  ValueChanged<String> nationalDateState;
  ValueChanged<String> passportDateState;
  ValueChanged? birthDatefinishState;

  ValueChanged<TextEditingController> lastNameState;
  ValueChanged<TextEditingController> lastNameStateInArabic;
  ValueChanged? lastNamefinishState;
  ValueChanged<TextEditingController> emailState;
  ValueChanged? emailfinishState;
  ValueChanged<PhoneNumber> phoneState;
  ValueChanged? phonefinishState;
  String? gender;
  ValueChanged<String?> genderState;
  String? maritalStatus;
  ValueChanged<String?> maritalStatusState;
  ValueChanged<TextEditingController> nationalIdState;
  ValueChanged<TextEditingController> passportNumberState;
  String? nation;
  ValueChanged<String?> nationState;

  ValueChanged<TextEditingController> countryState;
  ValueChanged<TextEditingController> addressState;
  ValueChanged<TextEditingController> postalState;
  ValueChanged? countryfinishState;
  ValueChanged<TextEditingController> cityState;
  ValueChanged? cityfinishState;
  ValueChanged? addressfinishState;

  ValueChanged<TextEditingController> provinceState;
  ValueChanged? provincefinishState;
  String? language;
  ValueChanged<String?> languageState;
  double personInfoCount;
  ValueChanged<double> personInfoState;
  bool isPreview;
  EmployeeController? addEmployeeController;

  ValueChanged<TextEditingController> nationalIdfinishState;
  @override
  State<AddNewEmployeePersonInfo> createState() =>
      _AddNewEmployeePersonInfoState();
}

class _AddNewEmployeePersonInfoState extends State<AddNewEmployeePersonInfo> {
  final AddNewEmployeeController addNewEmployeeController = Get.find();

  bool hasSuffix1 = false;
  bool hasSuffix2 = false;
  bool hasSuffix3 = false;
  bool hasSuffix4 = false;
  bool hasSuffix5 = false;
  File? _image;
  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  Future<void> _selectDate(BuildContext context, String name) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.single);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != selectedDate) {
      setState(() {
        _rangeDatePickerValueWithDefaultValue = picked;
        selectedDate = picked[
            0]; // get the first element in the array which is the selected date
        final DateFormat formatter = DateFormat('dd/MM/yyyy');
        // String formattedDate = formatter.format(picked[0] as DateTime);
        // String formattedDate2 = formatter.format(picked.last as DateTime);

        widget.personInfoCount += 1 / 14;
        widget.personInfoState(widget.personInfoCount);
        if (name == 'birthDate') {
          addNewEmployeeController.birthDate.text =
              formatter.format(picked[0] as DateTime);
          widget.birthDateState(formatter.format(picked[0] as DateTime));
        } else if (name == 'National ID Expiration Date') {
          addNewEmployeeController.nationalDate.text =
              formatter.format(picked[0] as DateTime);
          widget.nationalDateState(formatter.format(picked[0] as DateTime));
        } else if (name == 'Passport Expiration Date') {
          addNewEmployeeController.passportDate.text =
              formatter.format(picked[0] as DateTime);
          widget.passportDateState(formatter.format(picked[0] as DateTime));
        }

        // widget.dateValueState(widget.dateValue);
      });
    }
  }

  double dropHeight = 0.055.h;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddNewEmployeeController>(
      builder: (_) {
        return
        Container();
        /* Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isPreview ? const SizedBox.shrink() : AddEmployeeImage(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.02.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "First Name",
                      isTextField: true,
                      hint: "Enter The First Name",
                      isOptional: false,
                      validator: (value) {
                        return Validator.work(value, "Invalid First Name".tr);
                      },
                      textController: addNewEmployeeController.firstName,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.firstNamefinishState!(
                              addNewEmployeeController.firstName);
                          widget.personInfoCount += 1 / 11;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          addNewEmployeeController.firstName.text = value!;
                          widget.firstNameState(
                              addNewEmployeeController.firstName);
                        });
                      },
                      isExpanded: true,
                      hasSuffix: hasSuffix1,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix1 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Middle Name",
                      isTextField: true,
                      validator: (value) {
                        return Validator
                            .work(value, "Invalid Middle Name".tr);
                      },
                      hint: "Enter The Middle Name",
                      textController: addNewEmployeeController.middleName,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.MiddlenNamefinishState!(
                              addNewEmployeeController.middleName);
                          widget.personInfoCount += 1 / 11;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget.MiddleNameState(
                              addNewEmployeeController.middleName);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: hasSuffix2,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix2 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Last Name",
                      isTextField: true,
                      validator: (value) {
                        return Validator.work(value, "Invalid Last Name".tr);
                      },
                      hint: "Enter The Last Name",
                      textController: addNewEmployeeController.lastName,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.lastNamefinishState!(
                              addNewEmployeeController.lastName);
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget
                              .lastNameState(addNewEmployeeController.lastName);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: hasSuffix2,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix2 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "First Name In Arabic",
                    isTextField: true,
                    hint: "Enter The First Name",
                    isOptional: false,
                    validator: (value) {
                      return Validator.work(value, "Invalid First Name".tr);
                    },
                    textController: addNewEmployeeController.firstNameInArabic,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.firstNamefinishState!(
                            addNewEmployeeController.firstName);
                        widget.personInfoCount += 1 / 11;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.firstNameStateInArabic(
                            addNewEmployeeController.firstNameInArabic);
                      });
                    },
                    isExpanded: true,
                    hasSuffix: hasSuffix1,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix1 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "Middle Name In Arabic",
                    isTextField: true,
                    validator: (value) {
                      return Validator.work(value, "Invalid Middle Name".tr);
                    },
                    hint: "Enter The Middle Name",
                    textController: addNewEmployeeController.middleNameInArabic,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.MiddlenNamefinishState!(
                            addNewEmployeeController.middleName);
                        widget.personInfoCount += 1 / 11;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.MiddleNameStateInArabic(
                            addNewEmployeeController.middleNameInArabic);
                      });
                    },
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: hasSuffix2,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix2 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "Last Name In Arabic",
                    isTextField: true,
                    validator: (value) {
                      return Validator.work(value, "Invalid Last Name".tr);
                    },
                    hint: "Enter The Last Name",
                    textController: addNewEmployeeController.lastNameInArabic,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.lastNamefinishState!(
                            addNewEmployeeController.lastName);
                        widget.personInfoCount += 1 / 14;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.lastNameStateInArabic(
                            addNewEmployeeController.lastNameInArabic);
                      });
                    },
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: hasSuffix2,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix2 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.03.h),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.02.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "National ID",
                      isTextField: true,
                      validator: (value) {
                        return Validator
                            .text(value, "Invalid National ID".tr);
                      },
                      hint: "Enter The National ID",
                      textController: addNewEmployeeController.nationalId,
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.nationalIdfinishState(
                              addNewEmployeeController.nationalId);
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget.nationalIdState(
                              addNewEmployeeController.nationalId);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, "National ID Expiration Date");
                    },
                    child: SizedBox(
                      width: widget.widthOfData,
                      child: ColumnRequestData(
                        isAddNew: true,
                        textController: addNewEmployeeController.nationalDate,
                        controllerfinishState: (value) {
                          setState(() {});
                        },
                        controllerState: (value) {
                          setState(() {
                            _selectDate(context, "National ID Expiration Date");
                          });
                        },
                        title: "National ID Expiration Date",
                        isTextField: true,
                        enabled: false,
                        fillColor: Theme.of(context).colorScheme.inversePrimary,
                        hint: "Enter The National ID Expiration Date",
                        isOptional: false,
                        isExpanded: true,
                        hasSuffix: true,
                        suffixUrl: "assets/icons/newCalenderFixed.svg",
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Passport Number",
                      isTextField: true,
                      validator: (value) {
                        return Validator
                            .text(value, "Invalid Passport Number".tr);
                      },
                      hint: "Enter The Passport Number",
                      textController: addNewEmployeeController.passportNumber,
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget.passportNumberState(
                              addNewEmployeeController.passportNumber);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.01.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, "Passport Expiration Date");
                    },
                    child: SizedBox(
                      width: widget.widthOfData,
                      child: ColumnRequestData(
                        isAddNew: true,
                        textController: addNewEmployeeController.passportDate,
                        controllerfinishState: (value) {
                          setState(() {});
                        },
                        controllerState: (value) {
                          setState(() {
                            _selectDate(context, "Passport Expiration Date");
                          });
                        },
                        title: "Passport Expiration Date",
                        isTextField: true,
                        enabled: false,
                        fillColor: Theme.of(context).colorScheme.inversePrimary,
                        hint: "Enter The Passport Expiration Date",
                        isOptional: false,
                        isExpanded: true,
                        hasSuffix: true,
                        suffixUrl: "assets/icons/newCalenderFixed.svg",
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Email",
                      isTextField: true,
                      validator: (value) {
                        return Validator.email(
                          value,
                        );
                      },
                      controllerfinishState: (value) {
                        setState(() {
                          widget.firstNamefinishState!(
                              addNewEmployeeController.email);
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      hint: "Enter The Email",
                      textController: addNewEmployeeController.email,
                      controllerState: (value) {
                        setState(() {
                          widget.emailState(addNewEmployeeController.email);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: hasSuffix3,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix3 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Phone'.tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: FontConstants.fontSize022.h,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  height: 1.6),
                            ),
                            SizedBox(
                              height: 0.055.h,
                              child: IntlPhoneField(
                                // autovalidateMode: AutovalidateMode.always,
                                pickerDialogStyle: PickerDialogStyle(
                                  searchFieldInputDecoration: InputDecoration(
                                    enabled: true,
                                    hintText: 'search',
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    hintStyle:
                                        AppFontStyle.cairoRegularStyle.copyWith(
                                      fontSize: FontConstants.fontSize020.h,
                                      fontWeight: FontWeight.w400,
                                      color: themeController.currentTheme ==
                                              AppColors.lightTheme
                                          ? Theme.of(context).colorScheme.scrim
                                          : AppColors.colorWhite,
                                    ),
                                  ),
                                  width: .45.w,
                                  backgroundColor: Colors.white,
                                  countryCodeStyle: TextStyle(
                                    fontSize: FontConstants.fontSize020.h,
                                    fontWeight: FontWeight.w400,
                                    color: themeController.currentTheme ==
                                            AppColors.lightTheme
                                        ? AppColors.colorBlack
                                        : AppColors.colorWhite,
                                  ),
                                ),
                                flagsButtonPadding:
                                    const EdgeInsets.only(left: 5),
                                showDropdownIcon: false,
                                disableLengthCheck: true,

                                style: AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize: FontConstants.fontSize020.h,
                                    color: themeController.currentTheme ==
                                            AppColors.lightTheme
                                        ? AppColors.colorBlack
                                        : AppColors.colorWhite,
                                    fontWeight: FontWeight.w400),
                                dropdownTextStyle:
                                    AppFontStyle.cairoRegularStyle.copyWith(
                                        fontSize: FontConstants.fontSize020.h,
                                        color: themeController.currentTheme ==
                                                AppColors.lightTheme
                                            ? AppColors.colorBlack
                                            : AppColors.colorWhite,
                                        fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                  filled: true,
                                  // contentPadding: Get.locale.toString().contains('en')
                                  //     ? const EdgeInsets.only(left: 10, top: 27)
                                  //     : const EdgeInsets.only(right: 10, top: 27),
                                  focusColor:
                                      const Color.fromRGBO(246, 246, 246, 1),
                                  hoverColor:
                                      const Color.fromRGBO(246, 246, 246, 1),
                                  hintText: 'Enter The Phone Number'.tr,
                                  prefix: const SizedBox(
                                    height: 22,
                                  ),
                                  hintStyle: AppFontStyle.cairoRegularStyle
                                      .copyWith(
                                          fontSize: FontConstants.fontSize020.h,
                                          color: AppColors.colorGrey,
                                          fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.scrim,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  fillColor: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? Colors.white
                                      : const Color(0xFF545454),
                                ),
                                onCountryChanged: (value) {},
                                initialCountryCode: 'EG',
                                onChanged: (value) {
                                  print(
                                      'countryISOCode ${value.countryISOCode}');
                                  print('number ${value.number}');
                                  print('countryCode ${value.countryCode}');
                                  print(
                                      'completeNumber ${value.completeNumber}');
                                  widget.phoneState(value);
                                },
                                validator: (value) {
                                  return Validator
                                      .number(value!.completeNumber);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.02.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectDate(context, "birthDate");
                    },
                    child: SizedBox(
                      width: widget.widthOfData,
                      child: ColumnRequestData(
                        isAddNew: true,
                        textController: addNewEmployeeController.birthDate,
                        controllerfinishState: (value) {
                          setState(() {
                            widget.birthDatefinishState!(
                                addNewEmployeeController.birthDate);
                          });
                        },
                        controllerState: (value) {
                          setState(() {
                            _selectDate(context, "birthDate");
                          });
                        },
                        title: "Birth Date",
                        isTextField: true,
                        enabled: false,
                        fillColor: Theme.of(context).colorScheme.inversePrimary,
                        hint: "Enter The Birth Date",
                        isOptional: false,
                        isExpanded: true,
                        hasSuffix: true,
                        suffixUrl: "assets/icons/newCalenderFixed.svg",
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Gender",
                      isTextField: false,
                      buttonHeight: dropHeight,
                      hint: "Enter The Gender",
                      buttonWidth: widget.widthOfData,
                      dropWidth: widget.widthOfData,
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: true,
                      dropDownItems: [
                        "Male".tr,
                        "Female".tr,
                        'Rather Not Say'.tr
                      ],
                      dropdownValue: widget.gender,
                      dropDownValueState: (value) {
                        setState(() {
                          widget.gender = value;
                          widget.genderState(widget.gender);
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Country",
                      isTextField: true,
                      validator: (value) {
                        return Validator.work(value, "Invalid Country".tr);
                      },
                      hint: "Enter The Country",
                      textController: addNewEmployeeController.country,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.countryfinishState!(
                              addNewEmployeeController.country);
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget.countryState(addNewEmployeeController.country);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: hasSuffix5,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix5 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 0.03.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "Province",
                    isTextField: true,
                    validator: (value) {
                      return Validator.work(value, "Invalid Province".tr);
                    },
                    hint: "Enter The Province",
                    textController: addNewEmployeeController.province,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.provincefinishState!(
                            addNewEmployeeController.province);
                        widget.personInfoCount += 1 / 14;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.provinceState(addNewEmployeeController.province);
                      });
                    },
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: hasSuffix5,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix5 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "City",
                    isTextField: true,
                    validator: (value) {
                      return Validator.work(value, "Invalid City".tr);
                    },
                    hint: "Enter The City",
                    textController: addNewEmployeeController.city,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.cityfinishState!(addNewEmployeeController.city);
                        widget.personInfoCount += 1 / 14;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.cityState(addNewEmployeeController.city);
                      });
                    },
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: hasSuffix5,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix5 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
                SizedBox(
                  width: widget.widthOfData,
                  child: ColumnRequestData(
                    isAddNew: true,
                    title: "Postal Code",
                    isTextField: true,
                    validator: (value) {
                      return Validator.zipCode(
                        value,
                      );
                    },
                    hint: "Enter The Postal Code",
                    textController: addNewEmployeeController.postal,
                    controllerfinishState: (value) {
                      setState(() {
                        widget.personInfoCount += 1 / 14;
                        widget.personInfoState(widget.personInfoCount);
                      });
                    },
                    controllerState: (value) {
                      setState(() {
                        widget.postalState(addNewEmployeeController.postal);
                      });
                    },
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: hasSuffix5,
                    hassSuffixState: (value) {
                      setState(() {
                        hasSuffix5 = value as bool;
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.02.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: widget.widthOfData,
                    child: ColumnRequestData(
                      isAddNew: true,
                      title: "Address",
                      isTextField: true,
                      validator: (value) {
                        return Validator.work(value, "Invalid Address".tr);
                      },
                      hint: "Enter The Address",
                      textController: addNewEmployeeController.address,
                      controllerfinishState: (value) {
                        setState(() {
                          widget.addressfinishState!(
                              addNewEmployeeController.country);
                          widget.personInfoCount += 1 / 14;
                          widget.personInfoState(widget.personInfoCount);
                        });
                      },
                      controllerState: (value) {
                        setState(() {
                          widget.addressState(addNewEmployeeController.address);
                        });
                      },
                      isOptional: false,
                      isExpanded: true,
                      hasSuffix: hasSuffix5,
                      hassSuffixState: (value) {
                        setState(() {
                          hasSuffix5 = value as bool;
                        });
                      },
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                      suffixUrl: "assets/images/closefield.svg",
                    ),
                  ),
                  ColumnRequestData(
                    isAddNew: true,
                    title: "Nationality",
                    isTextField: false,
                    hint: "Enter The Nationality",
                    buttonHeight: dropHeight,
                    buttonWidth: widget.widthOfData,
                    isOptional: false,
                    isExpanded: true,
                    hasSuffix: true,
                    dropWidth: widget.widthOfData,
                    dropDownItems: nationality,
                    dropdownValue: widget.nation,
                    dropDownValueState: (value) {
                      setState(() {
                        widget.nation = value;
                        widget.nationState(widget.nation);
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                  ColumnRequestData(
                    isAddNew: true,
                    title: "Marital Status",
                    isTextField: false,
                    hint: "Enter The Marital Status",
                    buttonWidth: widget.widthOfData,
                    buttonHeight: dropHeight,
                    isOptional: false,
                    isExpanded: true,
                    dropWidth: widget.widthOfData,
                    hasSuffix: true,
                    dropDownItems: [
                      "Single".tr,
                      "Married".tr,
                      "Divorced".tr,
                      "Widowed".tr,
                      "Separated".tr,
                      "Engaged".tr
                    ],
                    dropdownValue: widget.maritalStatus,
                    dropDownValueState: (value) {
                      setState(() {
                        widget.maritalStatus = value;
                        widget.maritalStatusState(widget.maritalStatus);
                      });
                    },
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    suffixUrl: "assets/images/closefield.svg",
                  ),
                ],
              ),
            ),
            ColumnRequestData(
              isAddNew: true,
              title: "Language",
              isTextField: false,
              hint: "Enter The Language",
              buttonWidth: widget.widthOfData,
              isOptional: false,
              isExpanded: true,
              buttonHeight: dropHeight,
              dropWidth: widget.widthOfData,
              hasSuffix: true,
              dropDownItems: [
                "Arabic".tr,
                "English".tr,
                'Mandarin Chinese'.tr,
                'Spanish'.tr,
                'Hindi'.tr,
                'French'.tr,
                'German'.tr,
                'Russian'.tr,
                'Other'.tr,
              ],
              dropdownValue: widget.language,
              dropDownValueState: (value) {
                setState(() {
                  widget.language = value;
                  widget.languageState(widget.language);
                });
              },
              fillColor: Theme.of(context).colorScheme.inversePrimary,
              suffixUrl: "assets/images/closefield.svg",
            ),
          ],
        );
      */},
    );
  }
}
