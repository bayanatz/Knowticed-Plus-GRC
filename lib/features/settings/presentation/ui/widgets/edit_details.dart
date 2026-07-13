///******************** FILE INFO ********************///
/// Purpose: Editable version of emergency contact information section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for emergency contact information with controllers passed from parent
import '../../../../../core/theme/app_colors.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/presentation/controller/settings_controller.dart';
import '../../../../../generated/l10n.dart';
import '../../controller/health_insurance_controller.dart';
import 'settings_header.dart';

class EditableEmergencyContactInformationSection extends StatelessWidget {
  final bool isFirstContact; // true for 1st contact, false for 2nd contact

  // Controllers passed from parent
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController relationshipController;
  final TextEditingController emailController;
  final TextEditingController mobilePhoneController;
  final TextEditingController languageController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;

  const EditableEmergencyContactInformationSection({
    super.key,
    this.isFirstContact = true,
    required this.firstNameController,
    required this.lastNameController,
    required this.relationshipController,
    required this.emailController,
    required this.mobilePhoneController,
    required this.languageController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Column(
      children: [

        isMobile ? SizedBox(height: 15.sp) : SizedBox(),

        SettingsHeader(
          imagePath: 'assets/icons_assets/main_icons_assets/Emergency Contact.svg',
          text: headerText,
        ),
        SizedBox(height: 15.sp),

        // First Row/Column: First Name, Last Name, Relationship
        isMobile
            ? Column(
          children: [


            CustomTextField(
              label: 'First Name'.tr,
              hint: 'Enter Your First Name'.tr,
              fillColor: AppColors.card,
              controller: firstNameController,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 10),
            CustomTextField(
              label: 'Last Name'.tr,
              fillColor: AppColors.card,
              hint: 'Enter Your Last Name'.tr,
              controller: lastNameController,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 10),
            CustomTextField(
              label: 'Relationship'.tr,
              fillColor: AppColors.card,
              hint: 'Enter Contact Relation'.tr,
              controller: relationshipController,
              enabled: true,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'First Name'.tr,
                hint: 'Enter Your First Name'.tr,
                controller: firstNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Last Name'.tr,
                hint: 'Enter Your Last Name'.tr,
                controller: lastNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Relationship'.tr,
                hint: 'Enter Contact Relation'.tr,
                controller: relationshipController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
          ],
        ),

        // Second Row/Column: Email, Mobile Phone, Language
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: 'Email'.tr,
              hint: 'Enter Your Email'.tr,
              controller: emailController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).phoneNumber,
              hint: 'Enter Your Mobile Phone'.tr,
              controller: mobilePhoneController,
              fillColor: AppColors.card,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: 'Language'.tr,
              hint: S.of(context).enterLanguage,
              controller: languageController,
              enabled: true,
              fillColor: AppColors.card,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Email'.tr,
                hint: 'Enter Your Email'.tr,
                controller: emailController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).phoneNumber,
                hint: S.of(context).enterPhoneNumber,
                fillColor: AppColors.card,
                controller: mobilePhoneController,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Language'.tr,
                hint: S.of(context).enterLanguage,
                fillColor: AppColors.card,
                controller: languageController,
                enabled: true,
              ),
            ),
          ],
        ),

        // Third Row/Column: Country, Province, City
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: 'Country'.tr,
              hint: 'Enter Your Country'.tr,
              controller: countryController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: 'Province'.tr,
              hint: 'Enter Your State Or Province'.tr,
              controller: provinceController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: 'City'.tr,
              hint: 'Enter Your City'.tr,
              controller: cityController,
              enabled: true,
              fillColor: AppColors.card,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Country'.tr,
                hint: 'Enter Your Country'.tr,
                controller: countryController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Province'.tr,
                hint: 'Enter Your State Or Province'.tr,
                controller: provinceController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'City'.tr,
                hint: 'Enter Your City'.tr,
                controller: cityController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
          ],
        ),

        // Fourth Row: Street (full width on both mobile and desktop)
        CustomTextField(
          label: S.of(context).street,
          hint: 'Enter Your Street Address'.tr,
          controller: streetController,
          fillColor: AppColors.card,
          enabled: true,
        ),
      ],
    );
  }
}