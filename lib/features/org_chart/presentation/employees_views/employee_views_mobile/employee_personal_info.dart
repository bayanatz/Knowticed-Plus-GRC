import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_intl_phone_field.dart';
import 'package:knowticed_plus/core/helper/validation/validator.dart';
import 'package:knowticed_plus/core/extensions/screen_fraction_extension.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employee_views_mobile/subwidgets/indicator_screen_container.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

import 'package:knowticed_plus/core/constants/nationalities_list.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_appbar_mobile.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// Helper function to get last value from history list
String _getLastValue(List<String> list) {
  return list.isEmpty ? '' : list.last;
}

// Helper function to capitalize string
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// ignore: must_be_immutable
class PersonalInfoMobileNew extends StatefulWidget {
  PersonalInfoMobileNew({
    super.key,
    required this.value,
    required this.valueState,
    required this.address,
    required this.birthdate,
    required this.city,
    required this.country,
    required this.email,
    required this.firstName,
    required this.gender,
    required this.lastName,
    required this.maritalStatus,
    required this.middleName,
    required this.nationality,
    required this.phone,
    required this.state,
    required this.genderState,
    required this.maritalStatusState,
    required this.nationalityState,
    required this.language,
    required this.languageState,
    required this.natinalId,
    required this.nationalIdExpirDate,
    required this.passportExpirDate,
    required this.passportNumber,
    required this.postalCode,
    required this.firstNameArabic,
    required this.lastNameArabic,
    required this.middleNameArabic,
    this.employeeHistory,
  });

  double value = 0;
  ValueChanged<double> valueState;
  TextEditingController firstName;
  TextEditingController middleName;
  TextEditingController lastName;
  TextEditingController firstNameArabic;
  TextEditingController middleNameArabic;
  TextEditingController lastNameArabic;
  TextEditingController birthdate;
  TextEditingController email;
  TextEditingController phone;
  TextEditingController country;
  TextEditingController city;
  TextEditingController state;
  TextEditingController address;
  String? nationality;
  ValueChanged<String?> nationalityState;
  String? gender;
  ValueChanged<String?> genderState;
  String? maritalStatus;
  ValueChanged<String?> maritalStatusState;
  String? language;
  ValueChanged<String?> languageState;
  TextEditingController? natinalId;
  TextEditingController? nationalIdExpirDate;
  TextEditingController? passportNumber;
  TextEditingController? passportExpirDate;
  TextEditingController? postalCode;
  NewEmployeeModelHistory? employeeHistory;

  @override
  State<PersonalInfoMobileNew> createState() => _PersonalInfoMobileNewState();
}

class _PersonalInfoMobileNewState extends State<PersonalInfoMobileNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBarMobile(
                showIcon: true,
                showMoreIcon: false,
                title: "Personal Information",
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IndicatorContainerScreen(value: widget.value),
                    PersonalInformationFieldsMobile(
                      isNew: widget.employeeHistory == null,
                      employeeHistory: widget.employeeHistory,
                      firstName: widget.firstName,
                      firstNameArabic: widget.firstNameArabic,
                      lastNameArabic: widget.lastNameArabic,
                      middleNameArabic: widget.middleNameArabic,
                      natinalId: widget.natinalId,
                      passportNumber: widget.passportNumber,
                      postalCode: widget.postalCode,
                      nationalIdExpirDate: widget.nationalIdExpirDate,
                      passportExpirDate: widget.passportExpirDate,
                      birthdate: widget.birthdate,
                      city: widget.city,
                      country: widget.country,
                      language: widget.language,
                      languageState: (value) {
                        setState(() {
                          widget.language = value;
                          widget.languageState(widget.language);
                        });
                      },
                      email: widget.email,
                      lastName: widget.lastName,
                      middleName: widget.middleName,
                      phone: widget.phone,
                      state: widget.state,
                      street: widget.address,
                      value: widget.value,
                      gender: widget.gender,
                      maritalStatus: widget.maritalStatus,
                      nationality: widget.nationality,
                      nationalityState: (value) {
                        setState(() {
                          widget.nationality = value;
                          widget.nationalityState(widget.nationality);
                        });
                      },
                      genderState: (value) {
                        setState(() {
                          widget.gender = value;
                          widget.genderState(widget.gender);
                        });
                      },
                      maritalStatusState: (value) {
                        setState(() {
                          widget.maritalStatus = value;
                          widget.maritalStatusState(widget.maritalStatus);
                        });
                      },
                      valueState: (value1) {
                        setState(() {
                          widget.value = value1;
                          widget.valueState(widget.value);
                        });
                      },
                    ),
                    SizedBox(height: 0.04.h)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PersonalInformationFieldsMobile extends StatefulWidget {
  const PersonalInformationFieldsMobile({
    super.key,
    this.isNew = false,
    this.city,
    this.country,
    this.email,
    this.firstName,
    this.firstNameArabic,
    this.lastName,
    this.lastNameArabic,
    this.middleName,
    this.middleNameArabic,
    this.phone,
    this.state,
    this.street,
    this.valueState,
    this.birthdate,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.nationalityState,
    this.genderState,
    this.maritalStatusState,
    this.natinalId,
    this.nationalIdExpirDate,
    this.passportExpirDate,
    this.passportNumber,
    this.postalCode,
    this.language,
    this.languageState,
    this.value = 0,
    this.employeeHistory,
  });

  final bool isNew;
  final TextEditingController? firstName;
  final TextEditingController? firstNameArabic;
  final TextEditingController? middleName;
  final TextEditingController? middleNameArabic;
  final TextEditingController? lastName;
  final TextEditingController? lastNameArabic;
  final TextEditingController? email;
  final TextEditingController? phone;
  final TextEditingController? birthdate;
  final TextEditingController? country;
  final TextEditingController? state;
  final TextEditingController? city;
  final TextEditingController? street;
  final TextEditingController? natinalId;
  final TextEditingController? nationalIdExpirDate;
  final TextEditingController? passportNumber;
  final TextEditingController? passportExpirDate;
  final TextEditingController? postalCode;
  final String? language;
  final ValueChanged<String?>? languageState;
  final double value;
  final ValueChanged<double>? valueState;
  final String? nationality;
  final ValueChanged<String?>? nationalityState;
  final String? gender;
  final ValueChanged<String?>? genderState;
  final String? maritalStatus;
  final ValueChanged<String?>? maritalStatusState;
  final NewEmployeeModelHistory? employeeHistory;

  @override
  State<PersonalInformationFieldsMobile> createState() =>
      _PersonalInformationFieldsMobileState();
}

class _PersonalInformationFieldsMobileState
    extends State<PersonalInformationFieldsMobile> {
  // Working copies of the widget's values. They change while the user
  // fills the form and are re-read from the widget when the parent rebuilds it.
  late double _value = widget.value;
  late String? _nationality = widget.nationality;
  late String? _gender = widget.gender;
  late String? _maritalStatus = widget.maritalStatus;
  late String? _language = widget.language;

  @override
  void didUpdateWidget(covariant PersonalInformationFieldsMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
    _nationality = widget.nationality;
    _gender = widget.gender;
    _maritalStatus = widget.maritalStatus;
    _language = widget.language;
  }

  final List<String> gender = [
    S.current.male,
    S.current.female,
    S.current.ratherNotSay
  ];

  final List<String> maritalStatus = [
    S.current.single,
    S.current.married,
    S.current.divorced,
    S.current.widowed,
    S.current.separated,
    S.current.engaged
  ];

  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());
  final ThemeController themeController = Get.find();
  String? _errorMessage;
  String? birthDate2;
  String? firstName2;
  String? middleName2;
  String? lastName2;
  String? email2;
  String? country2;
  String? city2;
  String? province2;
  String? address2;
  dynamic phone2;
  String? selectedGender;
  String? selectedNationality;
  String? selectedMaritalStatus;

  @override
  void initState() {
    super.initState();
    if (!widget.isNew && widget.employeeHistory != null) {
      _initializeFromHistory();
    }
  }

  void _initializeFromHistory() {
    final history = widget.employeeHistory!;
    selectedGender = _getLastValue(history.gender);
    selectedNationality = _getLastValue(history.nationality);
    selectedMaritalStatus = _getLastValue(history.maritalStatus);
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime?> rangeDatePickerValueWithDefaultValue = [];

    Future<void> selectDate(BuildContext context, String type) async {
      final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.single,
      );

      if (picked != null && picked.first != null) {
        setState(() {
          final DateFormat formatter = DateFormat('MM/dd/yyyy');
          String formattedDate = formatter.format(picked[0]!);

          if (type == 'birthDate') {
            birthDate2 = formattedDate;
            widget.birthdate!.text = birthDate2!;
            if (widget.isNew) {
              addEmployeeController.employeePhone = addEmployeeController
                  .employeePhone
                  .copyWithUpdateSynchronized(birthDay: formattedDate);
            } else {
              addEmployeeController.employeePhone = addEmployeeController
                  .employeePhone
                  .updateFieldSynchronized('birthDay', formattedDate);
            }
          }

          if (type == 'iD') {
            widget.nationalIdExpirDate!.text = formattedDate;
            if (widget.isNew) {
              addEmployeeController.employeePhone = addEmployeeController
                  .employeePhone
                  .copyWithUpdateSynchronized(
                      nationalIdExpirationDate: formattedDate);
            } else {
              addEmployeeController.employeePhone =
                  addEmployeeController.employeePhone.updateFieldSynchronized(
                      'nationalIdExpirationDate', formattedDate);
            }
          }

          if (type == 'passPort') {
            widget.passportExpirDate!.text = formattedDate;
            if (widget.isNew) {
              addEmployeeController.employeePhone = addEmployeeController
                  .employeePhone
                  .copyWithUpdateSynchronized(
                      passportExpirationDate: formattedDate);
            } else {
              addEmployeeController.employeePhone =
                  addEmployeeController.employeePhone.updateFieldSynchronized(
                      'passportExpirationDate', formattedDate);
            }
          }
        });
      }
    }

    bool isTablet = !kpIsPhoneLayout(context);
    final orientation = MediaQuery.of(context).orientation;

    EdgeInsets.symmetric(
      horizontal: orientation == Orientation.portrait ? 0.04.w : 0.01.w,
    );

    TextStyle dropDownTextStyle = StyleText.fontSize16Weight400.copyWith(
      fontSize: isTablet
          ? orientation == Orientation.portrait
              ? 12.sp
              : 18.sp
          : 14.sp,
      color: AppColors.colorGrey,
      fontWeight: FontWeight.w400,
      height: orientation == Orientation.portrait ? 0.0014.h : 0.002.h,
    );

    !kpIsPhoneLayout(context)
        ? (orientation == Orientation.portrait ? 0.620.w : 0.850.h)
        : double.infinity;

    double buttonHeight = !kpIsPhoneLayout(context)
        ? (orientation == Orientation.portrait ? 0.04.h : 0.04.w)
        : 0.05.h;
    double? dropdownHeight = !kpIsPhoneLayout(context) ? null : 0.2.h;
    !kpIsPhoneLayout(context) ? null : EdgeInsets.symmetric(vertical: 0.003.h);

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double heightSpacer = isPortrait ? 0.007.h : 0.013.h;
    double heightSpacerTextField = 0.003.h;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 0.01.h),
                  child: SettingsHeader(
                    imagePath:
                        'assets/icons_assets/org_chart_assets/ic_user_person_bold.svg',
                    text: S.of(context).personalData,
                  ),
                ),

                // First Name
                CustomTextField(
                  onChanged: (value) {
                    firstName2 = value.trim().toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  firstName: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'firstName', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheFirstName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.firstName)),
                  controller: widget.isNew ? widget.firstName : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.firstName!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Middle Name
                CustomTextField(
                  onChanged: (value) {
                    middleName2 = value.trim().toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  middleName: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'middleName', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheMiddleName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.middleName)),
                  controller: widget.isNew ? widget.middleName : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.middleName!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Last Name
                CustomTextField(
                  onChanged: (value) {
                    lastName2 = value.trim().toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  lastName: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'lastName', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheLastName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.lastName)),
                  controller: widget.isNew ? widget.lastName : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.lastName!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Arabic First Name
                CustomTextField(
                  onChanged: (value) {
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  firstNameInArabic: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'firstNameInArabic', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheArabicFirstName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(_getLastValue(
                          widget.employeeHistory!.firstNameInArabic)),
                  controller: widget.isNew ? widget.firstNameArabic : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.firstNameArabic!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Arabic Middle Name
                CustomTextField(
                  onChanged: (value) {
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  middleNameInArabic: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'middleNameInArabic', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheArabicMiddleName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(_getLastValue(
                          widget.employeeHistory!.middleNameInArabic)),
                  controller: widget.isNew ? widget.middleNameArabic : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.middleNameArabic!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Arabic Last Name
                CustomTextField(
                  onChanged: (value) {
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  lastNameInArabic: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'lastNameInArabic', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheArabicLastName,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(_getLastValue(
                          widget.employeeHistory!.lastNameInArabic)),
                  controller: widget.isNew ? widget.lastNameArabic : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.lastNameArabic!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // National ID
                CustomTextField(
                  onChanged: (value) {
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  nationalId: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'nationalId', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheNationalID,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.nationalId)),
                  controller: widget.isNew ? widget.natinalId : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.natinalId!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // National ID Expiration Date
                CustomTextField(
                  onChanged: (value) async {
                    await selectDate(context, 'iD');
                  },
                  hint: S.of(context).enterTheNationalIDExpirationDate,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(_getLastValue(
                          widget.employeeHistory!.nationalIdExpirationDate)),
                  controller: widget.isNew ? widget.nationalIdExpirDate : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.nationalIdExpirDate!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: true,
                  suffixIcon: InkWell(
                    onTap: () {
                      HapticController.low(); // list row: on the tap (X-117)
                      selectDate(context, 'iD');
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: (isTablet ? 0.022.w : 0.038.w)),
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                        height: 0.02.h,
                        color:
                            (widget.employeeHistory?.birthDay.isEmpty ?? true)
                                ? AppColors.colorGrey
                                : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: heightSpacerTextField),

                // Nationality Dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).nationality,
                  items: (nationality)
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? (orientation == Orientation.landscape
                              ? 0.022.h
                              : 0.015.h)
                          : 0.025.w),
                  value: widget.isNew
                      ? _nationality
                      : selectedNationality == null &&
                              _getLastValue(widget.employeeHistory!.nationality)
                                  .isNotEmpty
                          ? capitalize(_getLastValue(
                              widget.employeeHistory!.nationality))
                          : selectedNationality,
                  onChanged: (value) {
                    setState(() {
                      selectedNationality = value;
                      _nationality = selectedNationality;
                      widget.nationalityState!(_nationality);
                      widget.isNew ? _value += (1 / 13) : null;
                      widget.isNew ? widget.valueState!(_value) : null;

                      if (widget.isNew) {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .copyWithUpdateSynchronized(
                                    nationality: value.toLowerCase());
                      } else {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .updateFieldSynchronized(
                                    'nationality', value.toLowerCase());
                      }
                    });
                  },
                ),
                SizedBox(height: heightSpacer),

                // Gender Dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).selectGender,
                  items: (gender)
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? (orientation == Orientation.landscape
                              ? 0.022.h
                              : 0.015.h)
                          : 0.025.w),
                  value: widget.isNew
                      ? _gender
                      : selectedGender == null &&
                              _getLastValue(widget.employeeHistory!.gender)
                                  .isNotEmpty
                          ? capitalize(
                              _getLastValue(widget.employeeHistory!.gender))
                          : selectedGender.toString(),
                  onChanged: (value) {
                    setState(() {
                      widget.isNew ? _gender = value : selectedGender = value;
                      widget.genderState!(_gender);
                      widget.isNew ? _value += (1 / 13) : null;
                      widget.isNew ? widget.valueState!(_value) : null;

                      if (widget.isNew) {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .copyWithUpdateSynchronized(
                                    gender: value.toLowerCase());
                      } else {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .updateFieldSynchronized(
                                    'gender', value.toLowerCase());
                      }
                    });
                  },
                ),
                SizedBox(height: heightSpacer),

                // Marital Status Dropdown
                CustomDropdown<String>(
                  valueStyle: dropDownTextStyle,
                  maxOverlayHeight: dropdownHeight,
                  hint: S.of(context).maritalStatus,
                  items: (maritalStatus)
                      .map((e) => DropdownItem<String>(value: e, label: e))
                      .toList(),
                  triggerPadding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? (orientation == Orientation.landscape
                              ? 0.022.h
                              : 0.015.h)
                          : 0.025.w),
                  value: widget.isNew
                      ? _maritalStatus
                      : selectedMaritalStatus == null &&
                              _getLastValue(
                                      widget.employeeHistory!.maritalStatus)
                                  .isNotEmpty
                          ? capitalize(_getLastValue(
                              widget.employeeHistory!.maritalStatus))
                          : capitalize(selectedMaritalStatus!),
                  onChanged: (value) {
                    setState(() {
                      widget.isNew
                          ? _maritalStatus = value
                          : selectedMaritalStatus = value;
                      widget.maritalStatusState!(_maritalStatus);
                      widget.isNew ? _value += (1 / 13) : null;
                      widget.isNew ? widget.valueState!(_value) : null;

                      if (widget.isNew) {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .copyWithUpdateSynchronized(
                                    maritalStatus: value.toLowerCase());
                      } else {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .updateFieldSynchronized(
                                    'maritalStatus', value.toLowerCase());
                      }
                    });
                  },
                ),
                SizedBox(height: heightSpacer),
              ],
            ),
          ),
          SizedBox(
            height: isTablet
                ? orientation == Orientation.portrait
                    ? 0.0.h
                    : 0.02.h
                : 0.02.h,
          ),

          // Contact Information Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.025.w, vertical: 0.0.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.01.h),
                  child: SettingsHeader(
                    imagePath:
                        'assets/icons_assets/org_chart_assets/ic_new_contact_info.svg',
                    text: S.of(context).contactInformation,
                  ),
                ),

                // Email
                Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: CustomTextField(
                    onChanged: (value) {
                      email2 = value.trim();
                      if (widget.isNew) {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .copyWithUpdateSynchronized(email: value);
                      } else {
                        addEmployeeController.employeePhone =
                            addEmployeeController.employeePhone
                                .updateFieldSynchronized('email', value);
                      }
                    },
                    hint: S.of(context).enterTheEmail,
                    initialValue: widget.isNew
                        ? null
                        : _getLastValue(widget.employeeHistory!.email),
                    controller: widget.isNew ? widget.email : null,
                    onSubmitted: widget.isNew
                        ? (value) {
                            setState(() {
                              widget.email!.text = value;
                              _value += (1 / 13);
                              widget.valueState!(_value);
                            });
                          }
                        : null,
                    readOnly: false,
                  ),
                ),

                // Phone Number
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.004.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: buttonHeight,
                        child: IntlPhoneField(
                          controller: widget.phone,
                          textAlign: Get.locale.toString().contains('ar')
                              ? TextAlign.start
                              : TextAlign.start,
                          flagsButtonPadding: const EdgeInsets.only(left: 5),
                          showDropdownIcon: false,
                          disableLengthCheck: true,
                          style: StyleText.fontSize16Weight400.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.text,
                              fontWeight: FontWeight.w400),
                          dropdownTextStyle: StyleText.fontSize16Weight400
                              .copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3),
                          decoration: InputDecoration(
                            filled: true,
                            focusColor: const Color.fromRGBO(246, 246, 246, 1),
                            hoverColor: const Color.fromRGBO(246, 246, 246, 1),
                            hintText: S.of(context).enterThePhoneNumber,
                            prefix: const SizedBox(height: 22),
                            hintStyle: StyleText.fontSize16Weight400.copyWith(
                                fontSize: orientation == Orientation.portrait
                                    ? isTablet
                                        ? 12.sp
                                        : 14.sp
                                    : 16.sp,
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
                            fillColor: !AppTheme.isDark
                                ? const Color(0xFFF6F6F6)
                                : AppColors.colorBlack,
                          ),
                          onCountryChanged: (value) {},
                          initialCountryCode: 'EG',
                          initialValue: widget.isNew
                              ? null
                              : widget.employeeHistory!.mobilePhone.isEmpty
                                  ? null
                                  : widget.employeeHistory!.mobilePhone.last
                                          .phones?.last ??
                                      '',
                          onChanged: (value) {
                            setState(() {
                              _errorMessage =
                                  Validator.number(value.completeNumber);
                            });

                            phone2 = value;
                            if (widget.isNew) {
                              addEmployeeController.employeeModel.value =
                                  addEmployeeController.employeeModel.value
                                      .copyWithUpdateSynchronized(
                                mobilePhone: MobilePhone(
                                  phones: [value.number],
                                  countryCode: [value.countryCode],
                                  countryApp: [value.countryISOCode],
                                  timestamps: [
                                    Timestamp.fromMillisecondsSinceEpoch(
                                        DateTime.now().millisecondsSinceEpoch)
                                  ],
                                ),
                                addTimestamp:
                                    DateTime.now().millisecondsSinceEpoch,
                              );
                            } else {
                              addEmployeeController.employeePhone =
                                  addEmployeeController.employeePhone
                                      .updateFieldSynchronized('mobilePhone', {
                                'number': value.number,
                                'countryApp': value.countryCode,
                                'countryCode': value.countryISOCode,
                              });
                            }
                          },
                        ),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: StyleText.fontSize16Weight400.copyWith(
                              fontSize: orientation == Orientation.portrait
                                  ? 12.sp
                                  : 14.sp,
                              color: AppColors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: isTablet
                      ? (orientation == Orientation.portrait ? .0.h : 0.0.h)
                      : 0.01.h,
                ),
              ],
            ),
          ),
          SizedBox(
            height: isTablet
                ? (orientation == Orientation.portrait ? .0.h : 0.02.h)
                : 0.02.h,
          ),

          // Location Information Section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.025.w, vertical: 0.0.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.01.h),
                  child: SettingsHeader(
                    imagePath:
                        'assets/icons_assets/main_icons_assets/ic_place_pin.svg',
                    text: S.of(context).locationInformation,
                  ),
                ),

                // Country
                CustomTextField(
                  onChanged: (value) async {
                    country2 = value.toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  country: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'country', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheCountry,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.country)),
                  controller: widget.isNew ? widget.country : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.country!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // City
                CustomTextField(
                  onChanged: (value) async {
                    city2 = value.toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  city: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'city', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheCity,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(_getLastValue(widget.employeeHistory!.city)),
                  controller: widget.isNew ? widget.city : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.city!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Province/State
                CustomTextField(
                  onChanged: (value) async {
                    province2 = value.toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  province: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'province', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterTheStateOrProvince,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.province)),
                  controller: widget.isNew ? widget.state : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.state!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Street Address
                CustomTextField(
                  onChanged: (value) {
                    address2 = value.toLowerCase();
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  street: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'street', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterYourStreetAddress,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.street)),
                  controller: widget.isNew ? widget.street : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {
                            widget.street!.text = value;
                            _value += (1 / 13);
                            widget.valueState!(_value);
                          });
                        }
                      : null,
                  readOnly: false,
                ),

                // Postal Code
                CustomTextField(
                  onChanged: (value) async {
                    if (widget.isNew) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                                  postalCode: value.toLowerCase());
                    } else {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .updateFieldSynchronized(
                                  'postalCode', value.toLowerCase());
                    }
                  },
                  hint: S.of(context).enterThePostalCode,
                  initialValue: widget.isNew
                      ? null
                      : capitalize(
                          _getLastValue(widget.employeeHistory!.postalCode)),
                  controller: widget.isNew ? widget.postalCode : null,
                  onSubmitted: widget.isNew
                      ? (value) {
                          setState(() {});
                        }
                      : null,
                  readOnly: false,
                ),

                // Language Dropdown
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.004.h),
                  child: CustomDropdown<String>(
                    valueStyle: dropDownTextStyle,
                    maxOverlayHeight: dropdownHeight,
                    hint: S.of(context).language,
                    items: ([
                      S.of(context).arabic,
                      S.of(context).english,
                      S.of(context).mandarinChinese,
                      S.of(context).spanish,
                      S.of(context).hindi,
                      S.of(context).french,
                      S.of(context).german,
                      S.of(context).russian,
                      S.of(context).other,
                    ])
                        .map((e) => DropdownItem<String>(value: e, label: e))
                        .toList(),
                    triggerPadding: EdgeInsets.symmetric(
                        horizontal: isTablet
                            ? (orientation == Orientation.landscape
                                ? 0.022.h
                                : 0.015.h)
                            : 0.025.w),
                    value: widget.isNew
                        ? _language
                        : capitalize(
                            _getLastValue(widget.employeeHistory!.language)),
                    onChanged: (value) {
                      setState(() {
                        widget.isNew ? _language = value : null;
                        widget.languageState!(_language);
                        widget.isNew ? _value += (1 / 13) : null;
                        widget.isNew ? widget.valueState!(_value) : null;

                        if (widget.isNew) {
                          addEmployeeController.employeePhone =
                              addEmployeeController.employeePhone
                                  .copyWithUpdateSynchronized(
                                      language: value.toLowerCase());
                        } else {
                          addEmployeeController.employeePhone =
                              addEmployeeController.employeePhone
                                  .updateFieldSynchronized(
                                      'language', value.toLowerCase());
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 0.01.h),
              ],
            ),
          ),
          SizedBox(height: 0.02.h),
        ],
      ),
    );
  }
}
