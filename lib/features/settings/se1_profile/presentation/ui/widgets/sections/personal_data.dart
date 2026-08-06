///********************** FILE INFO ********************///
/// Purpose: This file contains the PersonalData widget in personal information page .
/// Created By: Mohamed Elrashidy
/// Creation Date: 10/11/2024
/// Refactored Date: 11/04/2025

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/helper/role/validator.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';
import 'package:grc_module/features/settings/se1_profile/presentation/ui/widgets/sections/name_section.dart';
// REMOVED: import '../../../settings_screen/views/personal_info_screens/personal_info_tablet/nationality_and_birth_section.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/helper/main_helper/arabic_number_format.dart';
import 'package:grc_module/core/helper/main_helper/extensions.dart';
class PersonalData extends StatelessWidget {
  final bool isReadOnly;
  PersonalData({super.key, required this.isReadOnly});

  HapticController hapticController = Get.find();
  SettingsController settingsController = Get.find();

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final personalDataController = settingsController.personalInformationController;
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      decoration: isMobile
          ? BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.card

      )
          : BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r),topRight: Radius.circular(8.r)),
        color: AppColors.card

      ),
      child: Padding(
        padding: EdgeInsets.only(top: 15.sp,right: 15.sp,left: 15.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and hire on
            Row(
              children: [
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: (employee?.photo != null &&
                          employee!.photo!.isNotEmpty)
                          ? Colors.transparent
                          : AppColors.grey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32.r),
                        child: (employee?.photo != null &&
                            employee!.photo!.isNotEmpty)
                            ? Image.network(
                          employee!.photo!.last!,
                          fit: BoxFit.cover,
                          width: 64.r,
                          height: 64.r,
                          errorBuilder: (context, error, stackTrace) {
                            return SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/male_avatar.svg",
                              width: 64.r,
                              height: 64.r,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : SvgPicture.asset(
                          "assets/icons_assets/main_icons_assets/male_avatar.svg",
                          width: 64.r,
                          height: 64.r,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10.sp),
            SizedBox(height: 10.sp),

            // First Row: First Name, Middle Name, Last Name
            NameSection(

              isReadOnly: isReadOnly,
              firstNameHint: 'Enter Your First Name',
              firstNameInitialValue: FormatHelper.localizedString(
                  englishName: employee!.firstName!.last!,
                  arabicName: employee!.firstNameInArabic!.last),
              middleNameHint: 'Enter Your Middle Name',
              middleNameInitialValue: FormatHelper.localizedString(
                englishName: employee!.middleName!.last!,
                arabicName: employee!.middleNameInArabic!.last,
              ),
              lastNameHint: 'Enter Your Last Name',
              lastNameInitialValue: FormatHelper.localizedString(
                  englishName: employee!.lastName!.last!,
                  arabicName: employee!.lastNameInArabic!.last),
            ),

         //   SizedBox(height: 10.h),

            // Second Row: Gender, Birthday, Material Status
        ThreeTextSection(
          firstHint: S.of(context).selectGender,
          firstInitialValue: personalDataController.selectedGender == null &&
              employee!.gender?.lastOrNull != null
              ? FormatHelper.capitalize(employee!.gender?.lastOrNull ?? '')
              : personalDataController.selectedGender.toString(),
          secondHint: S.of(context).enterbirthday,
          secondInitialValue: settingsController
              .personalInformationController.birthDate.text.isEmpty
              ? formatDate(employee!.birthDay?.lastOrNull)  // Updated to use formatDate
              : settingsController.personalInformationController.birthDate.text,
          secondSuffixIcon: Padding(
            padding: EdgeInsets.only(
                right: 0.011.w,
                left: 0.011.w,
                top: 0.012.h,
                bottom: 0.012.h),
            child: SvgPicture.asset(
              'assets/icons_assets/roles_assets/calendar.svg',
              color: themeController.currentTheme.value == AppColors.lightTheme
                  ? AppColors.colorBlack
                  : AppColors.colorWhite,
              height: 0.022.h,
            ),
          ),
          thirdHint: S.of(context).maritalStatus,
          thirdInitialValue: personalDataController.selectedMaritalStatus == null &&
              employee!.maritalStatus?.lastOrNull != null
              ? FormatHelper.capitalize(employee!.maritalStatus?.lastOrNull ?? '')
              : FormatHelper.capitalize(personalDataController.selectedMaritalStatus ?? ""),
          isReadOnly: isReadOnly,
        ),

          ],
        ),
      ),
    );
  }

  // Updated formatDate method for Arabic date format (yyyy/MM/dd)
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      DateTime date;

      // Try to parse the date in different formats
      if (dateString.contains('-')) {
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        // If already in slash format, just convert numbers if needed
        if (Get.locale.toString().contains('ar')) {
          return ArabicDigits(dateString).toArabicNumbers();
        }
        return dateString;
      } else {
        // Try parsing with DateFormat
        date = DateFormat('dd MMM yyyy').parse(dateString);
      }

      // Format as yyyy/MM/dd
      String formattedDate = DateFormat('yyyy/MM/dd').format(date);

      // Convert to Arabic numerals if locale is Arabic
      if (Get.locale.toString().contains('ar')) {
        formattedDate = ArabicDigits(formattedDate).toArabicNumbers();
      }

      return formattedDate;
    } catch (e) {
      print('Date parsing error: $e for date: $dateString');
      // If parsing fails, return the original date string
      // and convert to Arabic if needed
      if (Get.locale.toString().contains('ar')) {
        return ArabicDigits(dateString).toArabicNumbers();
      }
      return dateString;
    }
  }

// Helper method to convert English numbers to Arabic (if not already in your codebase)
  // Helper method to convert English numbers to Arabic (if not already in your codebase)

}

// Refactored widget for three fields in a row (Gender, Birthday, Marital Status)
class ThreeTextSection extends StatefulWidget {
  final Function(String)? firstOnChanged;
  final String? Function(String?)? firstValidator;
  final String? firstInitialValue;
  final String firstHint;

  final Function(String)? secondOnChanged;
  final String? Function(String?)? secondValidator;
  final String? secondInitialValue;
  final String secondHint;
  final bool isReadOnly;
  final Widget? secondSuffixIcon;

  final Function(String)? thirdOnChanged;
  final String? Function(String?)? thirdValidator;
  final String? thirdInitialValue;
  final String thirdHint;

  final bool submitted;

  const ThreeTextSection({
    Key? key,
    this.firstOnChanged,
    this.firstValidator,
    this.firstInitialValue,
    required this.firstHint,
    this.secondOnChanged,
    this.secondValidator,
    this.secondInitialValue,
    required this.secondHint,
    required this.isReadOnly,
    this.secondSuffixIcon,
    this.thirdOnChanged,
    this.thirdValidator,
    this.thirdInitialValue,
    required this.thirdHint,
    this.submitted = false,
  }) : super(key: key);

  @override
  State<ThreeTextSection> createState() => _ThreeTextSectionState();
}

class _ThreeTextSectionState extends State<ThreeTextSection> {
  late TextEditingController _firstController;
  late TextEditingController _secondController;
  late TextEditingController _thirdController;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController(text: widget.firstInitialValue ?? '');
    _secondController = TextEditingController(text: widget.secondInitialValue ?? '');
    _thirdController = TextEditingController(text: widget.thirdInitialValue ?? '');
  }

  @override
  void didUpdateWidget(ThreeTextSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.firstInitialValue != widget.firstInitialValue) {
      _firstController.text = widget.firstInitialValue ?? '';
    }
    if (oldWidget.secondInitialValue != widget.secondInitialValue) {
      _secondController.text = widget.secondInitialValue ?? '';
    }
    if (oldWidget.thirdInitialValue != widget.thirdInitialValue) {
      _thirdController.text = widget.thirdInitialValue ?? '';
    }
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
      ),
      child: isVertical
          ? _buildVerticalLayout(context, lightMode)
          : _buildHorizontalLayout(context, lightMode ),
    );
  }

  Widget _buildVerticalLayout(
      BuildContext context, bool lightMode,) {
    var isPhone = ContextExtension(context).isPhone;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender Field
        CustomTextField(
          label: S.of(context).gender,
          hint: widget.firstHint,
          controller: _firstController,
          textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
          maxLines: 1,
          enabled: false,
          onChanged: (value) {
            if (widget.firstOnChanged != null) {
              widget.firstOnChanged!(value);
            }
          },
        ),

        isPhone ? SizedBox() : SizedBox(height: 16.h),

        // Birthday Field
        _buildBirthdayField(),

        isPhone ? SizedBox() : SizedBox(height: 16.h),

        // Marital Status Field
        CustomTextField(
          label: S.of(context).status,
          hint: widget.thirdHint,
          textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
          controller: _thirdController,
          enabled: !widget.isReadOnly,
          onChanged: (value) {
            if (widget.thirdOnChanged != null) {
              widget.thirdOnChanged!(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
      BuildContext context, bool lightMode,)
  {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: isArabic ? 0 : 12.w,
                left: isArabic ? 12.w : 0,
              ),
              child: CustomTextField(
                label: S.of(context).gender,
                hint: widget.firstHint,
                controller: _firstController,
                textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
                maxLines: 1,
                enabled: false,
                onChanged: (value) {
                  if (widget.firstOnChanged != null) {
                    widget.firstOnChanged!(value);
                  }
                },
              ),
            ),
          ),

          // Birthday
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: isArabic ? 0 : 12.w,
                left: isArabic ? 12.w : 0,
              ),
              child: _buildBirthdayField(),
            ),
          ),

          // Marital Status
          Expanded(
            child: CustomTextField(
              label: S.of(context).status,
              hint: widget.thirdHint,
              controller: _thirdController,
              textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
              enabled: !widget.isReadOnly,
              onChanged: (value) {
                if (widget.thirdOnChanged != null) {
                  widget.thirdOnChanged!(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayField() {
    var isPhone = ContextExtension(context).isPhone;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).birthday,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text
          ),
        ),
        SizedBox(height: 6.h),
        CustomTextField(
          hint: widget.secondHint,
          controller: _secondController,
          textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
          enabled: !widget.isReadOnly,
          valueStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.text
          ),
          hintStyle: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText
          ),
        ),
        isPhone ? SizedBox() : SizedBox(height: 16.h),
      ],
    );
  }
}

// Refactored widget for single nationality field
class NationalitySection extends StatefulWidget {
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final String hint;
  final bool isReadOnly;
  final bool submitted;

  const NationalitySection({
    Key? key,
    this.onChanged,
    this.validator,
    this.initialValue,
    required this.hint,
    this.isReadOnly = true,
    this.submitted = false,
  }) : super(key: key);

  @override
  State<NationalitySection> createState() => _NationalitySectionState();
}

class _NationalitySectionState extends State<NationalitySection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(NationalitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
      ),
      child: CustomTextField(
        label: widget.hint,
        hint: 'Select ${widget.hint}',
        controller: _controller,
        enabled: !widget.isReadOnly,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }
}