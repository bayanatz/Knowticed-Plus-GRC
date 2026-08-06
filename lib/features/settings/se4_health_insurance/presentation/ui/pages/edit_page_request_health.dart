///********************* FILE INFO ***********************///
/// Purpose: Edit page for health insurance settings with exact same UI as view page
/// Author: Assistant
/// Created: 2025
/// Updated: 31/10/2025
/// Updated By: Claude AI Assistant
/// Changes: Updated to fetch data from NewEmployeeModelHistory model
/// Description: Allows users to edit health insurance and emergency contact information

// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, sdk_version_since, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/settings/se6_requests/presentation/controller/request_controller.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/pages/preview_health_changes_page.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart' show SettingsController;

import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_details.dart';
import 'package:grc_module/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_heath.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
class EditPageRequestHealth extends StatefulWidget {
  const EditPageRequestHealth({super.key});

  @override
  _EditPageRequestHealthState createState() => _EditPageRequestHealthState();
}

class _EditPageRequestHealthState extends State<EditPageRequestHealth> {
  bool isEnglish = Get.locale.toString().contains('en');
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
  NewEmployeeModelHistory? currentEmployeeHistory;

  // Health Insurance Controllers
  late TextEditingController insuranceNameController;
  late TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  late TextEditingController firstContact_FirstNameController;
  late TextEditingController firstContact_LastNameController;
  late TextEditingController firstContact_RelationshipController;
  late TextEditingController firstContact_EmailController;
  late TextEditingController firstContact_PhoneController;
  late TextEditingController firstContact_LanguageController;
  late TextEditingController firstContact_CountryController;
  late TextEditingController firstContact_ProvinceController;
  late TextEditingController firstContact_CityController;
  late TextEditingController firstContact_StreetController;

  // 2nd Emergency Contact Controllers
  late TextEditingController secondContact_FirstNameController;
  late TextEditingController secondContact_LastNameController;
  late TextEditingController secondContact_RelationshipController;
  late TextEditingController secondContact_EmailController;
  late TextEditingController secondContact_PhoneController;
  late TextEditingController secondContact_LanguageController;
  late TextEditingController secondContact_CountryController;
  late TextEditingController secondContact_ProvinceController;
  late TextEditingController secondContact_CityController;
  late TextEditingController secondContact_StreetController;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    // Get current employee's history data
    String currentUserEmail = Get.find<EmployeeController>().employee!.email?.last ?? '';

    // Find the current employee from the history model
    currentEmployeeHistory = employeeController.allNewEmployees?.firstWhereOrNull(
            (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail
    );

    // Initialize Health Insurance Controllers
    String insuranceName = '';
    String policyNumber = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.insuranceName.isNotEmpty) {
        insuranceName = currentEmployeeHistory!.insuranceName.last;
      }
      if (currentEmployeeHistory!.insurancePolicyNumber.isNotEmpty) {
        policyNumber = currentEmployeeHistory!.insurancePolicyNumber.last;
      }
    }

    insuranceNameController = TextEditingController(text: insuranceName);
    insurancePolicyNumberController = TextEditingController(text: policyNumber);

    // Initialize 1st Emergency Contact Controllers
    String firstContactFirstName = '';
    String firstContactLastName = '';
    String firstContactRelationship = '';
    String firstContactEmail = '';
    String firstContactPhone = '';
    String firstContactLanguage = '';
    String firstContactCountry = '';
    String firstContactProvince = '';
    String firstContactCity = '';
    String firstContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.firstContactFirstName.isNotEmpty) {
        firstContactFirstName = currentEmployeeHistory!.firstContactFirstName.last;
      }
      if (currentEmployeeHistory!.firstContactLastName.isNotEmpty) {
        firstContactLastName = currentEmployeeHistory!.firstContactLastName.last;
      }
      if (currentEmployeeHistory!.firstContactRelationship.isNotEmpty) {
        firstContactRelationship = currentEmployeeHistory!.firstContactRelationship.last;
      }
      if (currentEmployeeHistory!.firstContactEmail.isNotEmpty) {
        firstContactEmail = currentEmployeeHistory!.firstContactEmail.last;
      }
      if (currentEmployeeHistory!.firstContactPhone.isNotEmpty) {
        firstContactPhone = currentEmployeeHistory!.firstContactPhone.last;
      }
      if (currentEmployeeHistory!.firstContactLanguage.isNotEmpty) {
        firstContactLanguage = currentEmployeeHistory!.firstContactLanguage.last;
      }
      if (currentEmployeeHistory!.firstContactCountry.isNotEmpty) {
        firstContactCountry = currentEmployeeHistory!.firstContactCountry.last;
      }
      if (currentEmployeeHistory!.firstContactProvince.isNotEmpty) {
        firstContactProvince = currentEmployeeHistory!.firstContactProvince.last;
      }
      if (currentEmployeeHistory!.firstContactCity.isNotEmpty) {
        firstContactCity = currentEmployeeHistory!.firstContactCity.last;
      }
      if (currentEmployeeHistory!.firstContactStreet.isNotEmpty) {
        firstContactStreet = currentEmployeeHistory!.firstContactStreet.last;
      }
    }

    firstContact_FirstNameController = TextEditingController(text: firstContactFirstName);
    firstContact_LastNameController = TextEditingController(text: firstContactLastName);
    firstContact_RelationshipController = TextEditingController(text: firstContactRelationship);
    firstContact_EmailController = TextEditingController(text: firstContactEmail);
    firstContact_PhoneController = TextEditingController(text: firstContactPhone);
    firstContact_LanguageController = TextEditingController(text: firstContactLanguage);
    firstContact_CountryController = TextEditingController(text: firstContactCountry);
    firstContact_ProvinceController = TextEditingController(text: firstContactProvince);
    firstContact_CityController = TextEditingController(text: firstContactCity);
    firstContact_StreetController = TextEditingController(text: firstContactStreet);

    // Initialize 2nd Emergency Contact Controllers
    String secondContactFirstName = '';
    String secondContactLastName = '';
    String secondContactRelationship = '';
    String secondContactEmail = '';
    String secondContactPhone = '';
    String secondContactLanguage = '';
    String secondContactCountry = '';
    String secondContactProvince = '';
    String secondContactCity = '';
    String secondContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.secondContactFirstName.isNotEmpty) {
        secondContactFirstName = currentEmployeeHistory!.secondContactFirstName.last;
      }
      if (currentEmployeeHistory!.secondContactLastName.isNotEmpty) {
        secondContactLastName = currentEmployeeHistory!.secondContactLastName.last;
      }
      if (currentEmployeeHistory!.secondContactRelationship.isNotEmpty) {
        secondContactRelationship = currentEmployeeHistory!.secondContactRelationship.last;
      }
      if (currentEmployeeHistory!.secondContactEmail.isNotEmpty) {
        secondContactEmail = currentEmployeeHistory!.secondContactEmail.last;
      }
      if (currentEmployeeHistory!.secondContactPhone.isNotEmpty) {
        secondContactPhone = currentEmployeeHistory!.secondContactPhone.last;
      }
      if (currentEmployeeHistory!.secondContactLanguage.isNotEmpty) {
        secondContactLanguage = currentEmployeeHistory!.secondContactLanguage.last;
      }
      if (currentEmployeeHistory!.secondContactCountry.isNotEmpty) {
        secondContactCountry = currentEmployeeHistory!.secondContactCountry.last;
      }
      if (currentEmployeeHistory!.secondContactProvince.isNotEmpty) {
        secondContactProvince = currentEmployeeHistory!.secondContactProvince.last;
      }
      if (currentEmployeeHistory!.secondContactCity.isNotEmpty) {
        secondContactCity = currentEmployeeHistory!.secondContactCity.last;
      }
      if (currentEmployeeHistory!.secondContactStreet.isNotEmpty) {
        secondContactStreet = currentEmployeeHistory!.secondContactStreet.last;
      }
    }

    secondContact_FirstNameController = TextEditingController(text: secondContactFirstName);
    secondContact_LastNameController = TextEditingController(text: secondContactLastName);
    secondContact_RelationshipController = TextEditingController(text: secondContactRelationship);
    secondContact_EmailController = TextEditingController(text: secondContactEmail);
    secondContact_PhoneController = TextEditingController(text: secondContactPhone);
    secondContact_LanguageController = TextEditingController(text: secondContactLanguage);
    secondContact_CountryController = TextEditingController(text: secondContactCountry);
    secondContact_ProvinceController = TextEditingController(text: secondContactProvince);
    secondContact_CityController = TextEditingController(text: secondContactCity);
    secondContact_StreetController = TextEditingController(text: secondContactStreet);
  }

  @override
  void dispose() {
    // Dispose Health Insurance Controllers
    insuranceNameController.dispose();
    insurancePolicyNumberController.dispose();

    // Dispose 1st Emergency Contact Controllers
    firstContact_FirstNameController.dispose();
    firstContact_LastNameController.dispose();
    firstContact_RelationshipController.dispose();
    firstContact_EmailController.dispose();
    firstContact_PhoneController.dispose();
    firstContact_LanguageController.dispose();
    firstContact_CountryController.dispose();
    firstContact_ProvinceController.dispose();
    firstContact_CityController.dispose();
    firstContact_StreetController.dispose();

    // Dispose 2nd Emergency Contact Controllers
    secondContact_FirstNameController.dispose();
    secondContact_LastNameController.dispose();
    secondContact_RelationshipController.dispose();
    secondContact_EmailController.dispose();
    secondContact_PhoneController.dispose();
    secondContact_LanguageController.dispose();
    secondContact_CountryController.dispose();
    secondContact_ProvinceController.dispose();
    secondContact_CityController.dispose();
    secondContact_StreetController.dispose();

    super.dispose();
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      // Collect all changes by comparing old vs new values
      Map<String, dynamic> changes = {};

      if (currentEmployeeHistory == null) {
        Get.snackbar(
          'Error',
          'Unable to load employee data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Helper function to get last value safely
      String getLastValue(List<String> list) => list.isNotEmpty ? list.last : '';

      // Health Insurance Changes
      String oldInsuranceName = getLastValue(currentEmployeeHistory!.insuranceName);
      String newInsuranceName = insuranceNameController.text.trim();
      if (oldInsuranceName != newInsuranceName) {
        changes['insuranceName'] = {
          'oldValue': oldInsuranceName,
          'newValue': newInsuranceName,
        };
      }

      String oldPolicyNumber = getLastValue(currentEmployeeHistory!.insurancePolicyNumber);
      String newPolicyNumber = insurancePolicyNumberController.text.trim();
      if (oldPolicyNumber != newPolicyNumber) {
        changes['insurancePolicyNumber'] = {
          'oldValue': oldPolicyNumber,
          'newValue': newPolicyNumber,
        };
      }

      // 1st Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.firstContactFirstName) != firstContact_FirstNameController.text.trim()) {
        changes['firstContact_firstName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactFirstName),
          'newValue': firstContact_FirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLastName) != firstContact_LastNameController.text.trim()) {
        changes['firstContact_lastName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactLastName),
          'newValue': firstContact_LastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactRelationship) != firstContact_RelationshipController.text.trim()) {
        changes['firstContact_relationship'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactRelationship),
          'newValue': firstContact_RelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactEmail) != firstContact_EmailController.text.trim()) {
        changes['firstContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactEmail),
          'newValue': firstContact_EmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactPhone) != firstContact_PhoneController.text.trim()) {
        changes['firstContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactPhone),
          'newValue': firstContact_PhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLanguage) != firstContact_LanguageController.text.trim()) {
        changes['firstContact_language'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactLanguage),
          'newValue': firstContact_LanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCountry) != firstContact_CountryController.text.trim()) {
        changes['firstContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCountry),
          'newValue': firstContact_CountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactProvince) != firstContact_ProvinceController.text.trim()) {
        changes['firstContact_province'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactProvince),
          'newValue': firstContact_ProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCity) != firstContact_CityController.text.trim()) {
        changes['firstContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCity),
          'newValue': firstContact_CityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactStreet) != firstContact_StreetController.text.trim()) {
        changes['firstContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactStreet),
          'newValue': firstContact_StreetController.text.trim(),
        };
      }

      // 2nd Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.secondContactFirstName) != secondContact_FirstNameController.text.trim()) {
        changes['secondContact_firstName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactFirstName),
          'newValue': secondContact_FirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLastName) != secondContact_LastNameController.text.trim()) {
        changes['secondContact_lastName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactLastName),
          'newValue': secondContact_LastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactRelationship) != secondContact_RelationshipController.text.trim()) {
        changes['secondContact_relationship'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactRelationship),
          'newValue': secondContact_RelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactEmail) != secondContact_EmailController.text.trim()) {
        changes['secondContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactEmail),
          'newValue': secondContact_EmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactPhone) != secondContact_PhoneController.text.trim()) {
        changes['secondContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactPhone),
          'newValue': secondContact_PhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLanguage) != secondContact_LanguageController.text.trim()) {
        changes['secondContact_language'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactLanguage),
          'newValue': secondContact_LanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCountry) != secondContact_CountryController.text.trim()) {
        changes['secondContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCountry),
          'newValue': secondContact_CountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactProvince) != secondContact_ProvinceController.text.trim()) {
        changes['secondContact_province'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactProvince),
          'newValue': secondContact_ProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCity) != secondContact_CityController.text.trim()) {
        changes['secondContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCity),
          'newValue': secondContact_CityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactStreet) != secondContact_StreetController.text.trim()) {
        changes['secondContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactStreet),
          'newValue': secondContact_StreetController.text.trim(),
        };
      }

      // Check if there are any changes
      if (changes.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            var lightMode = Theme.of(context).brightness == Brightness.light;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                width: 411.w,
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/lottie_assets/main_lottie_assets/attention.json',
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    // Error Message
                    Text(
                      S.of(context).noChangeFound,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      // Navigate to Preview Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewHealthInsuranceChangesPage(
            changes: changes,
            insuranceNameController: TextEditingController(
                text: FormatHelper.capitalize(insuranceNameController.text)
            ),
            insurancePolicyNumberController: TextEditingController(
                text: FormatHelper.capitalize(insurancePolicyNumberController.text)
            ),
            firstContact_FirstNameController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_FirstNameController.text)
            ),
            firstContact_LastNameController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_LastNameController.text)
            ),
            firstContact_RelationshipController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_RelationshipController.text)
            ),
            firstContact_EmailController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_EmailController.text)
            ),
            firstContact_PhoneController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_PhoneController.text)
            ),
            firstContact_LanguageController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_LanguageController.text)
            ),
            firstContact_CountryController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_CountryController.text)
            ),
            firstContact_ProvinceController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_ProvinceController.text)
            ),
            firstContact_CityController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_CityController.text)
            ),
            firstContact_StreetController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_StreetController.text)
            ),
            secondContact_FirstNameController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_FirstNameController.text)
            ),
            secondContact_LastNameController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_LastNameController.text)
            ),
            secondContact_RelationshipController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_RelationshipController.text)
            ),
            secondContact_EmailController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_EmailController.text)
            ),
            secondContact_PhoneController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_PhoneController.text)
            ),
            secondContact_LanguageController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_LanguageController.text)
            ),
            secondContact_CountryController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_CountryController.text)
            ),
            secondContact_ProvinceController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_ProvinceController.text)
            ),
            secondContact_CityController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_CityController.text)
            ),
            secondContact_StreetController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_StreetController.text)
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    return Scaffold(
      body: isMobile ?

      SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: (){
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingHealthInsurance,
        child: GetBuilder<RequestController>(
          init: Get.find<RequestController>(),
          builder: (requestController) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: lightMode ? AppColors.background : AppColors.chatBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Health Insurance Section (Editable)
                              Container(
                                decoration: !isTablet
                                    ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                                )
                                    : null,
                                child: Padding(
                                  padding:  EdgeInsets.only(right: 15.sp,left: 15.sp,top: 15.sp),
                                  child: EditableHealthInsuranceSection(
                                    insuranceNameController: insuranceNameController,
                                    insurancePolicyNumberController: insurancePolicyNumberController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // 1st Emergency Contact Section (Editable)
                        Container(
                          padding: EdgeInsets.only(
                            left: !isTablet ? 15.sp : 0,
                            right: !isTablet ? 15.sp : 0,
                            top: !isTablet ? 15.sp : 0,
                            bottom: !isTablet ? 15.sp : 0,
                          ),
                          decoration: !isTablet
                              ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: lightMode ? AppColors.white : AppColors.chatBackground,
                          )
                              : null,
                          child: EditableEmergencyContactInformationSection(
                            isFirstContact: true,
                            firstNameController: firstContact_FirstNameController,
                            lastNameController: firstContact_LastNameController,
                            relationshipController: firstContact_RelationshipController,
                            emailController: firstContact_EmailController,
                            mobilePhoneController: firstContact_PhoneController,
                            languageController: firstContact_LanguageController,
                            countryController: firstContact_CountryController,
                            provinceController: firstContact_ProvinceController,
                            cityController: firstContact_CityController,
                            streetController: firstContact_StreetController,
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // 2nd Emergency Contact Section (Editable)
                        Container(
                          padding: EdgeInsets.only(
                            left: !isTablet ? 15.sp : 0,
                            right: !isTablet ? 15.sp : 0,
                            top: !isTablet ? 15.sp : 0,
                            bottom: !isTablet ? 15.sp : 0,
                          ),
                          decoration: !isTablet
                              ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: lightMode ? AppColors.white : AppColors.chatBackground,
                          )
                              : null,
                          child: EditableEmergencyContactInformationSection(
                            isFirstContact: false,
                            firstNameController: secondContact_FirstNameController,
                            lastNameController: secondContact_LastNameController,
                            relationshipController: secondContact_RelationshipController,
                            emailController: secondContact_EmailController,
                            mobilePhoneController: secondContact_PhoneController,
                            languageController: secondContact_LanguageController,
                            countryController: secondContact_CountryController,
                            provinceController: secondContact_ProvinceController,
                            cityController: secondContact_CityController,
                            streetController: secondContact_StreetController,
                          ),
                        ),

                        SizedBox(height: 15.sp),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Discard Changes Button
                            customButton(
                              title: S.of(context).discardChange,
                              function: (){
                                Navigator.pop(context);
                              },
                              color: Colors.grey[700],
                              width: 150.w,
                              height: 38.h,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: Colors.white,
                              ),
                              radius: 8.r,
                            ),
                            Spacer(),

                            // Submit Button (Now goes to Preview)
                            customButton(
                              title: S.of(context).preview,
                              function: _submitRequest,
                              color: AppColors.primary,
                              width: 150.w,
                              height: 38.h,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,

                            ),
                          ],
                        ),

                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ) :

      SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: (){
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingHealthInsurance,
        child: GetBuilder<RequestController>(
          init: Get.find<RequestController>(),
          builder: (requestController) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: lightMode ? AppColors.background : AppColors.chatBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(15.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Health Insurance Section (Editable)
                                  EditableHealthInsuranceSection(
                                    insuranceNameController: insuranceNameController,
                                    insurancePolicyNumberController: insurancePolicyNumberController,
                                  ),
                                  SizedBox(height: 20.h),

                                  // 1st Emergency Contact Section (Editable)
                                  EditableEmergencyContactInformationSection(
                                    isFirstContact: true,
                                    firstNameController: firstContact_FirstNameController,
                                    lastNameController: firstContact_LastNameController,
                                    relationshipController: firstContact_RelationshipController,
                                    emailController: firstContact_EmailController,
                                    mobilePhoneController: firstContact_PhoneController,
                                    languageController: firstContact_LanguageController,
                                    countryController: firstContact_CountryController,
                                    provinceController: firstContact_ProvinceController,
                                    cityController: firstContact_CityController,
                                    streetController: firstContact_StreetController,
                                  ),
                                  SizedBox(height: 20.h),

                                  // 2nd Emergency Contact Section (Editable)
                                  EditableEmergencyContactInformationSection(
                                    isFirstContact: false,
                                    firstNameController: secondContact_FirstNameController,
                                    lastNameController: secondContact_LastNameController,
                                    relationshipController: secondContact_RelationshipController,
                                    emailController: secondContact_EmailController,
                                    mobilePhoneController: secondContact_PhoneController,
                                    languageController: secondContact_LanguageController,
                                    countryController: secondContact_CountryController,
                                    provinceController: secondContact_ProvinceController,
                                    cityController: secondContact_CityController,
                                    streetController: secondContact_StreetController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Discard Changes Button
                              customButton(
                                title: S.of(context).back,
                                function: (){
                                  Navigator.pop(context);
                                },
                                color: lightMode ? Colors.grey[400] : Colors.grey[700],
                                width: 150.w,
                                height: 38.h,
                                textStyle: StyleText.fontSize16Weight500.copyWith(
                                  color: lightMode ? Colors.black : Colors.white,
                                ),
                                radius: 8.r,
                              ),
                              Spacer(),

                              // Submit Button (Now goes to Preview)
                              customButton(
                                title: S.of(context).preview,
                                function: _submitRequest,
                                color: AppColors.primary,
                                width: 150.w,
                                height: 38.h,
                                textStyle: StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.textButton,
                                ),
                                radius: 8.r,

                              ),
                            ],
                          ),
                          SizedBox(height: 10.sp),

                          Row(
                            children: [
                              customButton(
                                title: S.of(context).discardChange,
                                function: (){
                                  Navigator.pop(context);
                                },
                                color: lightMode ? Colors.grey[400] : Colors.grey[700],
                                width: 150.w,
                                height: 38.h,
                                textStyle: StyleText.fontSize16Weight500.copyWith(
                                  color: lightMode ? Colors.black : Colors.white,
                                ),
                                radius: 8.r,
                              ),
                            ],
                          ),

                          SizedBox(height: 10.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}