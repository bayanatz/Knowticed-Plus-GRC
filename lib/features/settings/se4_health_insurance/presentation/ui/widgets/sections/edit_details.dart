///******************** FILE INFO ********************///
/// Purpose: Editable version of emergency contact information section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for emergency contact information with controllers passed from parent
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/controller/health_insurance_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

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
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Column(
      children: [

        isMobile ? SizedBox(height: 15.sp) : SizedBox(),

        SettingsHeader(
          imagePath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
          text: headerText,
        ),
        SizedBox(height: 15.sp),

        // First Row/Column: First Name, Last Name, Relationship
        isMobile
            ? Column(
          children: [


            CustomTextField(
              label: S.of(context).firstName,
              hint: S.of(context).enterYourFirstName,
              fillColor: AppColors.card,
              controller: firstNameController,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 10),
            CustomTextField(
              label: S.of(context).lastName,
              fillColor: AppColors.card,
              hint: S.of(context).enterYourLastName,
              controller: lastNameController,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 10),
            CustomTextField(
              label: S.of(context).relationship,
              fillColor: AppColors.card,
              hint: S.of(context).enterContactRelation,
              controller: relationshipController,
              enabled: true,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).firstName,
                hint: S.of(context).enterYourFirstName,
                controller: firstNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).lastName,
                hint: S.of(context).enterYourLastName,
                controller: lastNameController,
                fillColor: AppColors.card,
                enabled: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).relationship,
                hint: S.of(context).enterContactRelation,
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
              label: S.of(context).email,
              hint: S.of(context).enterYourEmail,
              controller: emailController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).phoneNumber,
              hint: S.of(context).enterYourMobilePhone,
              controller: mobilePhoneController,
              fillColor: AppColors.card,
              enabled: true,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).language,
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
                label: S.of(context).email,
                hint: S.of(context).enterYourEmail,
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
                label: S.of(context).language,
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
              label: S.of(context).country,
              hint: S.of(context).enterYourCountry,
              controller: countryController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).province,
              hint: S.of(context).enterYourStateOrProvince,
              controller: provinceController,
              enabled: true,
              fillColor: AppColors.card,
            ),
            isMobile ? SizedBox(height: 0,) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).city,
              hint: S.of(context).enterYourCity,
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
                label: S.of(context).country,
                hint: S.of(context).enterYourCountry,
                controller: countryController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).province,
                hint: S.of(context).enterYourStateOrProvince,
                controller: provinceController,
                enabled: true,
                fillColor: AppColors.card,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).city,
                hint: S.of(context).enterYourCity,
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
          hint: S.of(context).enterYourStreetAddress,
          controller: streetController,
          fillColor: AppColors.card,
          enabled: true,
        ),
      ],
    );
  }
}