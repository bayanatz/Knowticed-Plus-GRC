///*************************** FILE INFO ****************************///
/// Purpose: Preview page for comparing old and new health insurance information
/// Author: Claude AI Assistant
/// Created At: 31/10/2025
/// Modified: Mobile responsive layout - vertical stacking on mobile, show only changed fields
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/grc/grc_module/grc_owner/presentation/ui/create_policy.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import '../../../../employee/data/models/emplyees_model/new_employee_model.dart';
import '../../../../employee/presentation/controller/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s3_services_requests/my_request_details/widget/dailog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import '../../controller/settings_controller.dart';
import 'request_page.dart';
import 'settings_screen.dart';

class PreviewHealthInsuranceChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;

  // Health Insurance Controllers
  final TextEditingController insuranceNameController;
  final TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  final TextEditingController firstContact_FirstNameController;
  final TextEditingController firstContact_LastNameController;
  final TextEditingController firstContact_RelationshipController;
  final TextEditingController firstContact_EmailController;
  final TextEditingController firstContact_PhoneController;
  final TextEditingController firstContact_LanguageController;
  final TextEditingController firstContact_CountryController;
  final TextEditingController firstContact_ProvinceController;
  final TextEditingController firstContact_CityController;
  final TextEditingController firstContact_StreetController;

  // 2nd Emergency Contact Controllers
  final TextEditingController secondContact_FirstNameController;
  final TextEditingController secondContact_LastNameController;
  final TextEditingController secondContact_RelationshipController;
  final TextEditingController secondContact_EmailController;
  final TextEditingController secondContact_PhoneController;
  final TextEditingController secondContact_LanguageController;
  final TextEditingController secondContact_CountryController;
  final TextEditingController secondContact_ProvinceController;
  final TextEditingController secondContact_CityController;
  final TextEditingController secondContact_StreetController;

  const PreviewHealthInsuranceChangesPage({
    super.key,
    required this.changes,
    required this.insuranceNameController,
    required this.insurancePolicyNumberController,
    required this.firstContact_FirstNameController,
    required this.firstContact_LastNameController,
    required this.firstContact_RelationshipController,
    required this.firstContact_EmailController,
    required this.firstContact_PhoneController,
    required this.firstContact_LanguageController,
    required this.firstContact_CountryController,
    required this.firstContact_ProvinceController,
    required this.firstContact_CityController,
    required this.firstContact_StreetController,
    required this.secondContact_FirstNameController,
    required this.secondContact_LastNameController,
    required this.secondContact_RelationshipController,
    required this.secondContact_EmailController,
    required this.secondContact_PhoneController,
    required this.secondContact_LanguageController,
    required this.secondContact_CountryController,
    required this.secondContact_ProvinceController,
    required this.secondContact_CityController,
    required this.secondContact_StreetController,
  });

  @override
  State<PreviewHealthInsuranceChangesPage> createState() => _PreviewHealthInsuranceChangesPageState();
}

class _PreviewHealthInsuranceChangesPageState extends State<PreviewHealthInsuranceChangesPage> {
  late TextEditingController requestNoteController;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).previewHealthInsuranceChanges,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Conditional based on device
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).current_details,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).current_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.sp),
                    Expanded(
                      child: Text(
                        S.of(context).new_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 10.sp),

              // Main Content - Conditional layout
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: true,
                    ),

                    SizedBox(height: 20.sp),

                    // New Details Header
                    Text(
                      S.of(context).new_details,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),

                    SizedBox(height: 10.sp),

                    // New Details
                    _buildDetailsColumn(
                      context,
                      lightMode,
                      isCurrentColumn: false,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Details Column
                    Expanded(
                      child: _buildDetailsColumn(
                        context,
                        lightMode,
                        isCurrentColumn: true,
                      ),
                    ),

                    SizedBox(width: 16.sp),

                    // New Details Column
                    Expanded(
                      child: _buildDetailsColumn(
                        context,
                        lightMode,
                        isCurrentColumn: false,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 30.sp),

              // Bottom Action Buttons
            isMobile ?   Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: customButton(
                      title: S.of(context).discardChange,
                      function: isSubmitting ? () {} : () {
                        Navigator.pop(context);
                      },
                      height: 38.h,
                      width: isMobile ? double.infinity : 150.sp,
                      color: Colors.grey[700],
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: Color(0xff2D2D2D),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: customButton(
                      title: isSubmitting ? "Submitting...".tr : "Submit".tr,
                      function: isSubmitting ? () {} : () {
                        _submitChanges(context);
                      },
                      height: 38.h,
                      width: isMobile ? double.infinity : 150.sp,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
                ],
              ) : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                customButton(
                  title: S.of(context).discardChange,
                  function: isSubmitting ? () {} : () {
                    Navigator.pop(context);
                  },
                  height: 38.h,
                  width:  150.sp,
                  color: lightMode ? Colors.grey[400] : Colors.grey[700],
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                customButton(
                  title: isSubmitting ? "Submitting...".tr : "Submit".tr,
                  function: isSubmitting ? () {} : () {
                    _submitChanges(context);
                  },
                  height: 38.h,
                  width: 150.sp,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                ),
              ],
            ),

              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsColumn(
      BuildContext context,
      bool lightMode, {
        required bool isCurrentColumn,
      }) {
    var isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final insuranceController = Get.find<SettingsController>().healthInsuranceController;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Helper function to check if field should be shown
    bool shouldShowField(String fieldKey) {
      if (!isMobile) return true; // Show all fields on tablet/desktop
      return widget.changes.containsKey(fieldKey); // Show only changed fields on mobile
    }

    // Helper to check if any insurance fields should be shown
    bool hasInsuranceFields = shouldShowField('insuranceName') ||
        shouldShowField('insurancePolicyNumber');

    // Helper to check if any first contact fields should be shown
    bool hasFirstContactFields = shouldShowField('firstContact_firstName') ||
        shouldShowField('firstContact_lastName') ||
        shouldShowField('firstContact_relationship') ||
        shouldShowField('firstContact_email') ||
        shouldShowField('firstContact_phone') ||
        shouldShowField('firstContact_language') ||
        shouldShowField('firstContact_country') ||
        shouldShowField('firstContact_province') ||
        shouldShowField('firstContact_city') ||
        shouldShowField('firstContact_street');

    // Helper to check if any second contact fields should be shown
    bool hasSecondContactFields = shouldShowField('secondContact_firstName') ||
        shouldShowField('secondContact_lastName') ||
        shouldShowField('secondContact_relationship') ||
        shouldShowField('secondContact_email') ||
        shouldShowField('secondContact_phone') ||
        shouldShowField('secondContact_language') ||
        shouldShowField('secondContact_country') ||
        shouldShowField('secondContact_province') ||
        shouldShowField('secondContact_city') ||
        shouldShowField('secondContact_street');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health Insurance Section
        if (hasInsuranceFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Insurance Section Header
                Row(
                  children: [
                    CustomSvg(
                      assetPath: 'assets/icons_assets/main_icons_assets/Insurance Details.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      'Health Insurance'.tr,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                // Insurance Name
                if (shouldShowField('insuranceName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insuranceName,
                    isCurrentColumn
                        ? insuranceController.healthInsuranceEntity?.providerName ?? ''
                        : widget.insuranceNameController.text,
                    widget.changes.containsKey('insuranceName'),
                  ),
                  if (shouldShowField('insurancePolicyNumber'))
                    SizedBox(height: 12.sp),
                ],

                // Insurance Policy Number
                if (shouldShowField('insurancePolicyNumber'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).insurancePolicyNumber,
                    isCurrentColumn
                        ? insuranceController.healthInsuranceEntity?.policyNumber ?? ''
                        : widget.insurancePolicyNumberController.text,
                    widget.changes.containsKey('insurancePolicyNumber'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 1st Emergency Contact Section
        if (hasFirstContactFields || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 1st Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvg(
                      assetPath: 'assets/icons_assets/main_icons_assets/Emergency Contact.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).emergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('firstContact_firstName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'First Name'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactFirstName ?? ''
                        : widget.firstContact_FirstNameController.text,
                    widget.changes.containsKey('firstContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_lastName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Last Name'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactLastName ?? ''
                        : widget.firstContact_LastNameController.text,
                    widget.changes.containsKey('firstContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_relationship')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Relationship'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactRelationShip ?? ''
                        : widget.firstContact_RelationshipController.text,
                    widget.changes.containsKey('firstContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_email')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Email'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactEmail ?? ''
                        : widget.firstContact_EmailController.text,
                    widget.changes.containsKey('firstContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_phone')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactPhone ?? ''
                        : widget.firstContact_PhoneController.text,
                    widget.changes.containsKey('firstContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_language')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Language'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactLanguage ?? ''
                        : widget.firstContact_LanguageController.text,
                    widget.changes.containsKey('firstContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Country'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactCountry ?? ''
                        : widget.firstContact_CountryController.text,
                    widget.changes.containsKey('firstContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Province'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactProvionce ?? ''
                        : widget.firstContact_ProvinceController.text,
                    widget.changes.containsKey('firstContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'City'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactCity ?? ''
                        : widget.firstContact_CityController.text,
                    widget.changes.containsKey('firstContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('firstContact_street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.firstContactStreet ?? ''
                        : widget.firstContact_StreetController.text,
                    widget.changes.containsKey('firstContact_street'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // 2nd Emergency Contact Section
        if (hasSecondContactFields || !isMobile)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: lightMode ? Colors.white : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 2nd Emergency Contact Section Header
                Row(
                  children: [
                    CustomSvg(
                      assetPath: 'assets/icons_assets/main_icons_assets/Emergency Contact.svg',
                      width: 25.w,
                      height: 25.h,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).secondEmergencyContact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                if (shouldShowField('secondContact_firstName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'First Name'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactFirstName ?? ''
                        : widget.secondContact_FirstNameController.text,
                    widget.changes.containsKey('secondContact_firstName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_lastName')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Last Name'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactLastName ?? ''
                        : widget.secondContact_LastNameController.text,
                    widget.changes.containsKey('secondContact_lastName'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_relationship')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Relationship'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactRelationShip ?? ''
                        : widget.secondContact_RelationshipController.text,
                    widget.changes.containsKey('secondContact_relationship'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_email')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Email'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactEmail ?? ''
                        : widget.secondContact_EmailController.text,
                    widget.changes.containsKey('secondContact_email'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_phone')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactPhone ?? ''
                        : widget.secondContact_PhoneController.text,
                    widget.changes.containsKey('secondContact_phone'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_language')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Language'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactLanguage ?? ''
                        : widget.secondContact_LanguageController.text,
                    widget.changes.containsKey('secondContact_language'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Country'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactCountry ?? ''
                        : widget.secondContact_CountryController.text,
                    widget.changes.containsKey('secondContact_country'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'Province'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactProvionce ?? ''
                        : widget.secondContact_ProvinceController.text,
                    widget.changes.containsKey('secondContact_province'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    'City'.tr,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactCity ?? ''
                        : widget.secondContact_CityController.text,
                    widget.changes.containsKey('secondContact_city'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('secondContact_street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).street,
                    isCurrentColumn
                        ? insuranceController.emergencyContactEntity?.secondContactStreet ?? ''
                        : widget.secondContact_StreetController.text,
                    widget.changes.containsKey('secondContact_street'),
                  ),

                // Request Note (only in New Details column)
                if (!isCurrentColumn) ...[
                  SizedBox(height: 20.sp),
                  CustomTextField(
                    label: S.of(context).request_note,
                    hint: S.of(context).textHere,
                    controller: requestNoteController,
                    maxLines: 3,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    textDirection: isArabic ?  ui.TextDirection.rtl : ui.TextDirection.ltr,
                    onChanged: (_){
                      setState(() {

                      });
                    },
                  )
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFieldDisplay(
      BuildContext context,
      bool lightMode,
      String label,
      String value,
      bool hasChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color:
            lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 36.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: lightMode ? AppColors.background : AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
            border: hasChanged
                ? Border.all(
              color: AppColors.green,
              width: 2,
            )
                : null,
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: StyleText.fontSize12Weight400.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Map field names from changes to model field names
  String _mapFieldNameToModelField(String changeFieldName) {
    final fieldMapping = {
      'insuranceName': 'insuranceName',
      'insurancePolicyNumber': 'insurancePolicyNumber',
      'firstContact_firstName': 'firstContactFirstName',
      'firstContact_lastName': 'firstContactLastName',
      'firstContact_relationship': 'firstContactRelationship',
      'firstContact_email': 'firstContactEmail',
      'firstContact_phone': 'firstContactPhone',
      'firstContact_language': 'firstContactLanguage',
      'firstContact_country': 'firstContactCountry',
      'firstContact_province': 'firstContactProvince',
      'firstContact_city': 'firstContactCity',
      'firstContact_street': 'firstContactStreet',
      'secondContact_firstName': 'secondContactFirstName',
      'secondContact_lastName': 'secondContactLastName',
      'secondContact_relationship': 'secondContactRelationship',
      'secondContact_email': 'secondContactEmail',
      'secondContact_phone': 'secondContactPhone',
      'secondContact_language': 'secondContactLanguage',
      'secondContact_country': 'secondContactCountry',
      'secondContact_province': 'secondContactProvince',
      'secondContact_city': 'secondContactCity',
      'secondContact_street': 'secondContactStreet',
    };

    return fieldMapping[changeFieldName] ?? changeFieldName;
  }

  Future<void> _submitChanges(
      BuildContext context,
      ) async
  {
    // Show confirmation dialog first
    showConfirmationDialog(
      lottiePath: 'assets/lottie/createServices.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        // Show loading dialog
        Get.dialog(
          Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );

        try {
          // Get Firestore instance
          final firestore = FirebaseFirestore.instance;

          // Get the employee document ID
          final String employeeId = employee?.id ?? '';

          if (employeeId.isEmpty) {
            throw Exception('Employee ID is not available');
          }

          print('📝 Starting request submission for employee: $employeeId');
          print('📝 Number of changes to submit: ${widget.changes.length}');

          // Build the path to the roles_module document: Demo/72650285/Modules/roles_module
          final String rolesDocPath = '${getBaseUrl('Modules')}/roles';

          print('DEBUG - Roles document path: $rolesDocPath');

          // Get current timestamp
          final DateTime requestDate = DateTime.now();
          final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(requestDate);

          // Get employee name
          final String employeeName = '${employee?.firstName?.lastOrNull ?? ''} ${employee?.lastName?.lastOrNull ?? ''}'.trim();

          // Get employee email
          final String employeeEmail = employee?.email?.lastOrNull ?? '';

          // Prepare batch write for all changes
          final WriteBatch batch = firestore.batch();

          // Submit each change as a separate document in the Employees_Request subcollection
          for (var entry in widget.changes.entries) {
            print('Processing change: ${entry.key}');

            // Create a new document reference with auto-generated ID in the Employees_Request subcollection
            // Path will be: Demo/72650285/Modules/roles_module/Employees_Request/{auto-id}
            final DocumentReference docRef = firestore
                .doc(rolesDocPath)
                .collection('Employees_Request')
                .doc(); // Auto-generate document ID

            print('DEBUG - Document path: ${docRef.path}');

            // Prepare the request data - Store employeeId and email
            final Map<String, dynamic> requestData = {
              'whatChanged': entry.key,
              'oldValue': entry.value['oldValue']?.toString() ?? '',
              'newValue': entry.value['newValue']?.toString() ?? '',
              'section': 'Health Insurance',
              'requestDate': FieldValue.serverTimestamp(), // Timestamp
              'requestDateFormatted': formattedDate, // Formatted string
              'requestNote': requestNoteController.text.trim().isNotEmpty
                  ? requestNoteController.text.trim()
                  : '',
              'status': 'pending',
              'employeeId': employeeId, // ✅ Store employeeId
              'employeeEmail': employeeEmail, // ✅ Store employee email
              'employeeName': employeeName,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };

            // Add to batch
            batch.set(docRef, requestData);

            print('Request prepared for: ${entry.key}');
          }

          // Commit all changes at once
          await batch.commit();

          print('✅ All requests submitted successfully to Firestore');
          print('Total documents created: ${widget.changes.length}');

          // Close loading dialog
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // Show success dialog
          await showSuccessDialog(
            lottiePath: 'assets/lottie/approved.json',
            title: S.of(context).request_submitted,
            subtitle: S.of(context).successfully_submitted_request,
          );

          // Close success dialog after a delay
          await Future.delayed(Duration(seconds: 2));

          // Close all open dialogs and pages
          int closeCount = 0;

          // Close success dialog
          if (Get.isDialogOpen ?? false) {
            Get.back();
            closeCount++;
          }

          // Close preview page and edit page
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Close preview page
            closeCount++;
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Close edit page
            closeCount++;
          }

          print('DEBUG - Closed $closeCount pages/dialogs');

          // Navigate to MyRequestPage
          Get.back();

        } catch (e, stackTrace) {
          // Close loading dialog if open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // Print detailed error
          print('❌ ERROR in _submitChanges:');
          print('Error: $e');
          print('StackTrace: $stackTrace');

          // Show error dialog
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return Dialog(
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.white
                    : AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: SizedBox(
                    width: 405.sp,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/attention.json',
                          width: 70.sp,
                          height: 70.sp,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(height: 20.sp),
                        Text(
                          'Error',
                          style: StyleText.fontSize20Weight500.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                        ),
                        SizedBox(height: 18.sp),
                        Text(
                          'Failed to submit request: ${e.toString()}',
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          ),
                        ),
                        SizedBox(height: 15.sp),
                        customButton(
                          title: 'Close',
                          function: () => Navigator.pop(dialogContext),
                          textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          width: 135.sp,
                          height: 38.sp,
                          radius: 4.r,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
  Future<void> showSuccessDialog({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  // Add this new function for success dialog with OK button
  Future<void> showSuccessDialogWithButton({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    return showDialog(
      context: Get.context!,
      barrierDismissible: false, // User must tap button to close
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(height: 20.sp),
                customButton(
                  title: 'OK'.tr,
                  function: () {
                    Navigator.pop(context); // Close the success dialog
                  },
                  textStyle: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 120.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isMobile = context.isPhone;
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize15Weight500.copyWith(
                          color: Color(0xff2D2D2D),
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryButton,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}