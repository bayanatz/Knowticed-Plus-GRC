///******************** FILE INFO ********************///
/// Purpose: A reusable widget that displays emergency contact information in the settings health insurance screen.
/// Author: Amr Mesbah
/// Created At: 12/11/2024
/// Updated At: 31/10/2025
/// Updated By: Claude AI Assistant
/// Changes: Updated to fetch data from NewEmployeeModelHistory model
/// Description: Added support for both 1st and 2nd emergency contacts from history data

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/settings_header.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';

class EmergencyContactInformationSection extends StatelessWidget {
  final bool isFirstContact; // true for 1st contact, false for 2nd contact

  const EmergencyContactInformationSection({
    super.key,
    this.isFirstContact = true,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    // Controllers
    final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
    final SettingsController settingsController = Get.find();

    // Get current employee's history data
    String currentUserEmail = Get.find<EmployeeController>().employee!.email?.last ?? '';

    // Find the current employee from the history model
    NewEmployeeModelHistory? currentEmployeeHistory = employeeController.allNewEmployees?.firstWhereOrNull(
            (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail
    );
    if (currentEmployeeHistory != null) {
    //  print('\n========== ${isFirstContact ? "1ST" : "2ND"} CONTACT ==========');

      if (isFirstContact) {
        // print('📋 First Contact Arrays:');
        // print('  Names: ${currentEmployeeHistory.firstContactFirstName}');
        // print('  Email: ${currentEmployeeHistory.firstContactEmail}');
        // print('  Phone: ${currentEmployeeHistory.firstContactPhone}');
      } else {
        // print('📋 Second Contact Arrays:');
        // print('  Names: ${currentEmployeeHistory.secondContactFirstName}');
        // print('  Email: ${currentEmployeeHistory.secondContactEmail}');
        // print('  Phone: ${currentEmployeeHistory.secondContactPhone}');
      }
  //    print('=====================================\n');
    }

    // Initialize variables for contact data
    String firstName = '';
    String lastName = '';
    String relationship = '';
    String email = '';
    String phone = '';
    String language = '';
    String country = '';
    String province = '';
    String city = '';
    String street = '';

    // Get data based on which contact (1st or 2nd) from history
    if (currentEmployeeHistory != null) {
      if (isFirstContact) {
        // First contact data (get last value from arrays)
        if (currentEmployeeHistory.firstContactFirstName.isNotEmpty) {
          firstName = currentEmployeeHistory.firstContactFirstName.last;
        }
        if (currentEmployeeHistory.firstContactLastName.isNotEmpty) {
          lastName = currentEmployeeHistory.firstContactLastName.last;
        }
        if (currentEmployeeHistory.firstContactRelationship.isNotEmpty) {
          relationship = currentEmployeeHistory.firstContactRelationship.last;
        }
        if (currentEmployeeHistory.firstContactEmail.isNotEmpty) {
          email = currentEmployeeHistory.firstContactEmail.last;
        }
        if (currentEmployeeHistory.firstContactPhone.isNotEmpty) {
          phone = currentEmployeeHistory.firstContactPhone.last;
        }
        if (currentEmployeeHistory.firstContactLanguage.isNotEmpty) {
          language = currentEmployeeHistory.firstContactLanguage.last;
        }
        if (currentEmployeeHistory.firstContactCountry.isNotEmpty) {
          country = currentEmployeeHistory.firstContactCountry.last;
        }
        if (currentEmployeeHistory.firstContactProvince.isNotEmpty) {
          province = currentEmployeeHistory.firstContactProvince.last;
        }
        if (currentEmployeeHistory.firstContactCity.isNotEmpty) {
          city = currentEmployeeHistory.firstContactCity.last;
        }
        if (currentEmployeeHistory.firstContactStreet.isNotEmpty) {
          street = currentEmployeeHistory.firstContactStreet.last;
        }
      } else {
        // Second contact data (get last value from arrays)
        if (currentEmployeeHistory.secondContactFirstName.isNotEmpty) {
          firstName = currentEmployeeHistory.secondContactFirstName.last;
        }
        if (currentEmployeeHistory.secondContactLastName.isNotEmpty) {
          lastName = currentEmployeeHistory.secondContactLastName.last;
        }
        if (currentEmployeeHistory.secondContactRelationship.isNotEmpty) {
          relationship = currentEmployeeHistory.secondContactRelationship.last;
        }
        if (currentEmployeeHistory.secondContactEmail.isNotEmpty) {
          email = currentEmployeeHistory.secondContactEmail.last;
        }
        if (currentEmployeeHistory.secondContactPhone.isNotEmpty) {
          phone = currentEmployeeHistory.secondContactPhone.last;
        }
        if (currentEmployeeHistory.secondContactLanguage.isNotEmpty) {
          language = currentEmployeeHistory.secondContactLanguage.last;
        }
        if (currentEmployeeHistory.secondContactCountry.isNotEmpty) {
          country = currentEmployeeHistory.secondContactCountry.last;
        }
        if (currentEmployeeHistory.secondContactProvince.isNotEmpty) {
          province = currentEmployeeHistory.secondContactProvince.last;
        }
        if (currentEmployeeHistory.secondContactCity.isNotEmpty) {
          city = currentEmployeeHistory.secondContactCity.last;
        }
        if (currentEmployeeHistory.secondContactStreet.isNotEmpty) {
          street = currentEmployeeHistory.secondContactStreet.last;
        }
      }
    }

    // Controllers for all fields
    final firstNameController = TextEditingController(
      text: FormatHelper.capitalize(firstName),
    );
    final lastNameController = TextEditingController(
      text: FormatHelper.capitalize(lastName),
    );
    final relationshipController = TextEditingController(
      text: FormatHelper.capitalize(relationship),
    );
    final emailController = TextEditingController(
      text: email,
    );
    final mobilePhoneController = TextEditingController(
      text: phone,
    );
    final languageController = TextEditingController(
      text: FormatHelper.capitalize(language),
    );
    final countryController = TextEditingController(
      text: FormatHelper.capitalize(country),
    );
    final provinceController = TextEditingController(
      text: FormatHelper.capitalize(province),
    );
    final cityController = TextEditingController(
      text: FormatHelper.capitalize(city),
    );
    final streetController = TextEditingController(
      text: FormatHelper.capitalize(street),
    );

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Padding(
      padding: EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
      child: Column(
        children: [
          SettingsHeader(
            imagePath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
            text: headerText,
          ),
          !isMobile ?SizedBox(height: 10.sp,):SizedBox(height: 0,) ,
          SizedBox(height: isTablet ? 0 : 0.02.h),

          // First Row/Column: First Name, Last Name, Relationship
          isMobile
              ? Column(
            children: [
              CustomTextField(
                label: S.of(context).firstName,
                hint: '-',
                controller: firstNameController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).lastName,
                hint: '-',
                controller: lastNameController,
                enabled: false,
              ),
             isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).relationship,
                hint: '-',
                controller: relationshipController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).firstName,
                  hint: '-',
                  controller: firstNameController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).lastName,
                  hint: '-',
                  controller: lastNameController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).relationship,
                  hint: '-',
                  controller: relationshipController,
                  enabled: false,
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
                hint: '-',
                controller: emailController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).phoneNumber,
                hint: '-',
                controller: mobilePhoneController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).language,
                hint: '-',
                controller: languageController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).email,
                  hint: "-",
                  controller: emailController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).phoneNumber,
                  hint: '-',
                  controller: mobilePhoneController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).language,
                  hint: '-',
                  controller: languageController,
                  enabled: false,
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
                hint: '-',
                controller: countryController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).province,
                hint: '-',
                controller: provinceController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 0) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).city,
                hint: '-',
                controller: cityController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).country,
                  hint: '-',
                  controller: countryController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).province,
                  hint: '-',
                  controller: provinceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).city,
                  hint: '-',
                  controller: cityController,
                  enabled: false,
                ),
              ),
            ],
          ),


          // Fourth Row: Street (full width on both mobile and desktop)
          CustomTextField(
            label: S.of(context).street,
            hint: '-',
            controller: streetController,
            enabled: false,
          ),
        ],
      ),
    );
  }
}