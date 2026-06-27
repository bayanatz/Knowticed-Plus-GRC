///*************************** FILE INFO ****************************///
/// Purpose: Preview page for comparing old and new personal information
/// Author: Claude AI Assistant
/// Created At: 27/10/2025
/// Modified: Mobile responsive layout - vertical stacking on mobile

import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/theme/app_theme.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/inventory_module/core/text_field.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/settings/widgets/countries.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/constants/skeleton_assets.dart';
import '../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
import 'package:demo_app/core/network/get_base_url.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'request_page.dart';
import 'settings_screen.dart';

class PreviewChangesPage extends StatefulWidget {
  final Map<String, dynamic> changes;
  final File? selectedImage;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController streetController;
  final TextEditingController dateOfBirthController;
  final String? selectedGender;
  final String? selectedMaritalStatus;
  final String? selectedCountryCode;

  const PreviewChangesPage({
    super.key,
    required this.changes,
    this.selectedImage,
    required this.firstNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.countryController,
    required this.provinceController,
    required this.cityController,
    required this.streetController,
    required this.dateOfBirthController,
    this.selectedGender,
    this.selectedMaritalStatus,
    this.selectedCountryCode,
  });

  @override
  State<PreviewChangesPage> createState() => _PreviewChangesPageState();
}

class _PreviewChangesPageState extends State<PreviewChangesPage> {
  late TextEditingController requestNoteController;

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

  // Helper method to get current phone display
  String _getCurrentPhoneDisplay() {
    final mobilePhoneList = employee?.mobilePhone;
    final mobilePhone = mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";

    if (phoneNumber.isEmpty) return '';

    final flag = _getCountryFlag(countryCode);
    final dialCode = _getDialCode(countryCode);

    return '$flag $dialCode $phoneNumber';
  }

  // Helper method to get new phone display
  String _getNewPhoneDisplay() {
    if (widget.phoneController.text.isEmpty) return '';

    final countryCode = widget.selectedCountryCode ?? "EG";
    final flag = _getCountryFlag(countryCode);
    final dialCode = _getDialCode(countryCode);

    return '$flag $dialCode ${widget.phoneController.text}';
  }

  // Get country flag from country code
  String _getCountryFlag(String countryDialCode) {
    try {
      final country = countries.firstWhere(
            (country) => country.dialCode == countryDialCode,
        orElse: () => countries.firstWhere((c) => c.code == 'EG'),
      );
      return country.flag;
    } catch (e) {
      return '🇪🇬';
    }
  }

  // Get dial code from country code
  String _getDialCode(String countryDialCode) {
    try {
      final country = countries.firstWhere(
            (country) => country.dialCode == countryDialCode,
        orElse: () => countries.firstWhere((c) => c.code == 'EG'),
      );
      return '+${country.dialCode}';
    } catch (e) {
      return '+20';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMaster(
        titleText: S.of(context).settings,
        onFirstTap: () {
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingMyPersonalData,
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
                    color: AppColors.text
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
                            color: AppColors.text
                        ),
                      ),
                    ),
                    SizedBox(width: 20.sp),
                    Expanded(
                      child: Text(
                        S.of(context).new_details,
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.text
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
                        color: AppColors.text,
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
                      function: () {
                        Navigator.pop(context);
                      },
                      height: 38.h,
                      width: isMobile ? double.infinity : 150.sp,
                      color: lightMode ? Colors.grey[400] : Colors.grey[700],
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: lightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: customButton(
                      title: S.of(context).submit,
                      function: () => _submitChanges(context),
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
                   function: () {
                     Navigator.pop(context);
                   },
                   height: 38.h,
                   width:  150.sp,
                   color: Colors.grey[700],
                   textStyle: StyleText.fontSize16Weight500.copyWith(
                     color: Colors.white,
                   ),
                 ),
                 Spacer(),
                 customButton(
                   title: S.of(context).submit,
                   function: () => _submitChanges(context),
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
      })
  {
    final isArabic = Localizations
        .localeOf(context)
        .languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Helper function to check if field should be shown
    bool shouldShowField(String fieldKey) {
      if (!isMobile) return true; // Show all fields on tablet/desktop
      return widget.changes.containsKey(fieldKey); // Show only changed fields on mobile
    }

    // Helper to check if any personal info fields should be shown
    bool hasPersonalInfoFields = shouldShowField('photo') ||
        shouldShowField('first_name') ||
        shouldShowField('middle_name') ||
        shouldShowField('last_name') ||
        shouldShowField('gender') ||
        shouldShowField('date_of_birth') ||
        shouldShowField('marital_status');

    // Check if any contact fields changed
    bool hasContactChanges = shouldShowField('email') ||
        shouldShowField('phone') ||
        shouldShowField('country_code');

    // Check if any location fields changed
    bool hasLocationChanges = shouldShowField('country') ||
        shouldShowField('province') ||
        shouldShowField('city') ||
        shouldShowField('street');

    return Column(
      children: [
        // Personal Information Container - only show if there are fields to display
        if (hasPersonalInfoFields) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo - only show if changed on mobile
                if (shouldShowField('photo'))
                  Column(
                    children: [
                      Row(
                        children: [
                          Center(
                            child: Stack(
                              alignment: AlignmentDirectional.bottomEnd,
                              children: [
                                CircleAvatar(
                                  radius: 29.r,
                                  backgroundColor: Colors.grey[200],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32.r),
                                    child: isCurrentColumn
                                        ? _buildCurrentPhoto()
                                        : _buildNewPhoto(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.sp),
                    ],
                  ),

                // Personal Information - conditionally show fields
                if (shouldShowField('first_name') || shouldShowField('first_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).firstName,
                 FormatHelper.capitalize(   isCurrentColumn
  ? (isArabic
  ? (employee?.firstNameInArabic?.lastOrNull ?? '')
      : (employee?.firstName?.lastOrNull ?? ''))
      : widget.firstNameController.text,),
                    widget.changes.containsKey('first_name') || widget.changes.containsKey('first_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('middle_name') || shouldShowField('middle_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).middleName,
                    FormatHelper.capitalize(isCurrentColumn
  ? (isArabic
  ? (employee?.middleNameInArabic?.lastOrNull ?? '')
      : (employee?.middleName?.lastOrNull ?? ''))
      : widget.middleNameController.text,),
                    widget.changes.containsKey('middle_name') || widget.changes.containsKey('middle_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('last_name') || shouldShowField('last_name_arabic')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).lastName,
                    FormatHelper.capitalize(isCurrentColumn
                    ? (isArabic
                    ? (employee?.lastNameInArabic?.lastOrNull ?? '')
      : (employee?.lastName?.lastOrNull ?? ''))
      : widget.lastNameController.text,),
                    widget.changes.containsKey('last_name') || widget.changes.containsKey('last_name_arabic'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('gender')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).gender,
                   FormatHelper.capitalize( isCurrentColumn
  ? employee?.gender?.lastOrNull ?? ''
      : _getGenderValue(widget.selectedGender),),
                    widget.changes.containsKey('gender'),
                  ),
                  SizedBox(height: 12.sp),
                ],

                if (shouldShowField('date_of_birth')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).birthday,
                   FormatHelper.capitalize( isCurrentColumn
  ? _formatDate(employee?.birthDay?.lastOrNull)
      : widget.dateOfBirthController.text,),
                    widget.changes.containsKey('date_of_birth'),
                  ),
                  if (shouldShowField('marital_status'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('marital_status'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).maritalStatus,
                   FormatHelper.capitalize( isCurrentColumn
  ? employee?.maritalStatus?.lastOrNull ?? ''
      : _getMaritalStatusValue(widget.selectedMaritalStatus),),
                    widget.changes.containsKey('marital_status'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // Contact Section - only show if any contact field changed
        if (hasContactChanges || !isMobile) ...[
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Contact Section Header
                Row(
                  children: [
                    CustomSvg(
                      assetPath: 'assets/phone_contact.svg',
                      width: 16.w,
                      height: 16.h,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).contact,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),

                if (shouldShowField('email')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).email,
                  FormatHelper.capitalize(  isCurrentColumn
  ? employee?.email?.lastOrNull ?? ''
      : widget.emailController.text,),
                    widget.changes.containsKey('email'),
                  ),
                  if (shouldShowField('phone') || shouldShowField('country_code'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('phone') || shouldShowField('country_code'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).phoneNumber,
                   FormatHelper.capitalize( isCurrentColumn
  ? _getCurrentPhoneDisplay()
      : _getNewPhoneDisplay(),),
                    widget.changes.containsKey('phone') || widget.changes.containsKey('country_code'),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.sp),
        ],

        // Location Section - only show if any location field changed
        if (hasLocationChanges || !isMobile)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Location Section Header
                Row(
                  children: [
                    CustomSvg(
                      assetPath: 'assets/new_location.svg',
                      width: 16.w,
                      height: 16.h,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      S.of(context).location,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),

                if (shouldShowField('country')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).country,
                  FormatHelper.capitalize(  isCurrentColumn
  ? employee?.country?.lastOrNull ?? ''
      : widget.countryController.text,),
                    widget.changes.containsKey('country'),
                  ),
                  if (shouldShowField('province') || shouldShowField('city') || shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('province')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).stateOrProvince,
                 FormatHelper.capitalize(   isCurrentColumn
                 ? employee?.province?.lastOrNull ?? ''
      : widget.provinceController.text,),
                    widget.changes.containsKey('province'),
                  ),
                  if (shouldShowField('city') || shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('city')) ...[
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).city,
                   FormatHelper.capitalize( isCurrentColumn
  ? employee?.city?.lastOrNull ?? ''
      : widget.cityController.text,),
                    widget.changes.containsKey('city'),
                  ),
                  if (shouldShowField('street'))
                    SizedBox(height: 12.sp),
                ],

                if (shouldShowField('street'))
                  _buildFieldDisplay(
                    context,
                    lightMode,
                    S.of(context).streetName,
                    FormatHelper.capitalize(isCurrentColumn
  ? employee?.street?.lastOrNull ?? ''
      : widget.streetController.text,),
                    widget.changes.containsKey('street'),
                  ),

                // Request Note (only in New Details column)
                if (!isCurrentColumn) ...[
                  SizedBox(height: 20.sp),
                  CustomTextField(
                    label: S.of(context).request_note,
                    hint: S.of(context).textHere,
                    controller: requestNoteController,
                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    maxLines: 3,
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
            color: AppColors.text
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 36.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.background,
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
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPhoto() {
    if (employee?.photo != null &&
        employee!.photo!.isNotEmpty) {
      return Image.network(
        employee!.photo!.last!,
        fit: BoxFit.cover,
        width: 58.r,
        height: 58.r,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: EdgeInsets.all(8.sp),
            child: SvgPicture.asset(
              SkeletonAssets.imageAvatar,
              width: 26.sp,
              height: 26.sp,
            ),
          );
        },
      );
    }
    return Container(
      padding: EdgeInsets.all(8.sp),
      child: SvgPicture.asset(
        SkeletonAssets.imageAvatar,
        width: 26.sp,
        height: 26.sp,
      ),
    );
  }

  Widget _buildNewPhoto() {
    if (widget.selectedImage != null) {
      return Image.file(
        widget.selectedImage!,
        fit: BoxFit.cover,
        width: 58.r,
        height: 58.r,
      );
    }
    return _buildCurrentPhoto();
  }

  String _getGenderValue(String? key) {
    if (key == null || key.isEmpty) return '';
    final genderMap = {
      'male': 'Male',
      'female': 'Female',
    };
    return genderMap[key] ?? key;
  }

  String _getMaritalStatusValue(String? key) {
    if (key == null || key.isEmpty) return '';
    final maritalMap = {
      'single': 'Single',
      'married': 'Married',
      'divorced': 'Divorced',
      'widowed': 'Widowed',
    };
    return maritalMap[key] ?? key;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }


  Future<void> _submitChanges(BuildContext context) async {
    showConfirmationDialog(
      lottiePath: 'assets/lottie/createServices.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        // Show loading dialog
        Get.dialog(
          Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          final firestore = FirebaseFirestore.instance;
          final String employeeId = employee?.id ?? '';

          if (employeeId.isEmpty) {
            throw Exception('Employee ID is not available');
          }

          print('📝 Starting data update for employee: $employeeId');

          // Build the path to the employee document
          final String employeeDocPath = '${getBaseUrl('Modules')}/roles/Employees/$employeeId';
          final DocumentReference employeeDocRef = firestore.doc(employeeDocPath);

          print('DEBUG - Employee document path: $employeeDocPath');

          // ✅ FIRST, GET THE CURRENT DOCUMENT TO READ EXISTING ARRAYS
          DocumentSnapshot docSnapshot = await employeeDocRef.get();

          if (!docSnapshot.exists) {
            throw Exception('Employee document not found');
          }

          Map<String, dynamic> currentData = docSnapshot.data() as Map<String, dynamic>;
          print('DEBUG - Current document data retrieved');

          // ✅ PREPARE UPDATE DATA BY APPENDING TO EXISTING ARRAYS
          Map<String, dynamic> updateData = {};
          final isArabic = Get.locale?.languageCode == 'ar';

          // Track if phone/country code changed
          bool phoneChanged = false;
          bool countryCodeChanged = false;
          String? newPhone;
          String? newCountryCode;

          for (var entry in widget.changes.entries) {
            String fieldName = entry.key;
            dynamic newValue = entry.value['newValue'];

            print('Processing update: $fieldName = $newValue');

            switch (fieldName) {
              case 'first_name':
                List<dynamic> currentArray = List.from(currentData['First_Name'] ?? []);
                currentArray.add(newValue);
                updateData['First_Name'] = currentArray;
                break;

              case 'first_name_arabic':
                List<dynamic> currentArray = List.from(currentData['First_Name_In_Arabic'] ?? []);
                currentArray.add(newValue);
                updateData['First_Name_In_Arabic'] = currentArray;
                break;

              case 'middle_name':
                List<dynamic> currentArray = List.from(currentData['Middle_Name'] ?? []);
                currentArray.add(newValue);
                updateData['Middle_Name'] = currentArray;
                break;

              case 'middle_name_arabic':
                List<dynamic> currentArray = List.from(currentData['Middle_Name_In_Arabic'] ?? []);
                currentArray.add(newValue);
                updateData['Middle_Name_In_Arabic'] = currentArray;
                break;

              case 'last_name':
                List<dynamic> currentArray = List.from(currentData['Last_Name'] ?? []);
                currentArray.add(newValue);
                updateData['Last_Name'] = currentArray;
                break;

              case 'last_name_arabic':
                List<dynamic> currentArray = List.from(currentData['Last_Name_In_Arabic'] ?? []);
                currentArray.add(newValue);
                updateData['Last_Name_In_Arabic'] = currentArray;
                break;

              case 'email':
                List<dynamic> currentArray = List.from(currentData['Email'] ?? []);
                currentArray.add(newValue);
                updateData['Email'] = currentArray;
                break;

              case 'phone':
                phoneChanged = true;
                newPhone = newValue.toString();
                break;

              case 'country_code':
                countryCodeChanged = true;
                newCountryCode = newValue.toString();
                break;

              case 'gender':
                List<dynamic> currentArray = List.from(currentData['Gender'] ?? []);
                currentArray.add(newValue);
                updateData['Gender'] = currentArray;
                break;

              case 'date_of_birth':
                List<dynamic> currentArray = List.from(currentData['Birth_Day'] ?? []);
                currentArray.add(newValue);
                updateData['Birth_Day'] = currentArray;
                break;

              case 'marital_status':
                List<dynamic> currentArray = List.from(currentData['Marital_Status'] ?? []);
                currentArray.add(newValue);
                updateData['Marital_Status'] = currentArray;
                break;

              case 'country':
                List<dynamic> currentArray = List.from(currentData['Country'] ?? []);
                currentArray.add(newValue);
                updateData['Country'] = currentArray;
                break;

              case 'province':
                List<dynamic> currentArray = List.from(currentData['Province'] ?? []);
                currentArray.add(newValue);
                updateData['Province'] = currentArray;
                break;

              case 'city':
                List<dynamic> currentArray = List.from(currentData['City'] ?? []);
                currentArray.add(newValue);
                updateData['City'] = currentArray;
                break;

              case 'street':
                List<dynamic> currentArray = List.from(currentData['Street'] ?? []);
                currentArray.add(newValue);
                updateData['Street'] = currentArray;
                break;

              case 'nationality':
                List<dynamic> currentArray = List.from(currentData['Nationality'] ?? []);
                currentArray.add(newValue);
                updateData['Nationality'] = currentArray;
                break;

              case 'photo':
                List<dynamic> currentArray = List.from(currentData['Photo'] ?? []);
                currentArray.add(newValue);
                updateData['Photo'] = currentArray;
                break;
            }
          }

          // Handle Mobile_Phone updates (if phone or country code changed)
          if (phoneChanged || countryCodeChanged) {
            List<dynamic> currentMobilePhone = List.from(currentData['Mobile_Phone'] ?? []);

            if (currentMobilePhone.isNotEmpty) {
              Map<String, dynamic> mobilePhoneData = Map<String, dynamic>.from(currentMobilePhone[0]);

              // Get current arrays
              List<dynamic> countryAppArray = List.from(mobilePhoneData['Country_App'] ?? []);
              List<dynamic> countryCodeArray = List.from(mobilePhoneData['Country_Code'] ?? []);
              List<dynamic> phoneArray = List.from(mobilePhoneData['Phone'] ?? []);
              List<dynamic> timestampArray = List.from(mobilePhoneData['Timestamp'] ?? []);

              // Add new values
              if (countryCodeChanged) {
                countryCodeArray.add(newCountryCode);
                countryAppArray.add(newCountryCode!.toUpperCase());
              }
              if (phoneChanged) {
                phoneArray.add(newPhone);
              }
              timestampArray.add(Timestamp.now());

              // Update the Mobile_Phone structure
              updateData['Mobile_Phone'] = [
                {
                  'Country_App': countryAppArray,
                  'Country_Code': countryCodeArray,
                  'Phone': phoneArray,
                  'Timestamp': timestampArray,
                }
              ];
            } else {
              // If no existing Mobile_Phone, create new
              updateData['Mobile_Phone'] = [
                {
                  'Country_App': [newCountryCode?.toUpperCase() ?? 'EG'],
                  'Country_Code': [newCountryCode ?? '20'],
                  'Phone': [newPhone ?? ''],
                  'Timestamp': [Timestamp.now()],
                }
              ];
            }
          }

          // Add last update timestamp
          updateData['Last_Login'] = Timestamp.now().toDate().toString();

          print('DEBUG - Update data prepared: ${updateData.keys.join(', ')}');
          print('DEBUG - Sample values:');
          updateData.forEach((key, value) {
            if (value is List) {
              print('  $key: [${value.length} items] - Last: ${value.isNotEmpty ? value.last : 'empty'}');
            } else {
              print('  $key: $value');
            }
          });

          // ✅ UPDATE THE EMPLOYEE DOCUMENT
          await employeeDocRef.update(updateData);

          print('✅ Employee data updated successfully in Firestore');

          // ✅ ALSO CREATE A REQUEST RECORD (for audit trail)
          // ✅ ALSO CREATE A REQUEST RECORD (for audit trail)
          final String companyBase = employeeDocPath.split('/Modules').first;
// companyBase = "Demo/66625076"

          final DocumentReference requestDocRef = firestore
              .collection('$companyBase/Employees_Info')  // ✅ collection(), not doc()
              .doc(); // auto-generated ID

          List<Map<String, dynamic>> changesArray = [];
          for (var entry in widget.changes.entries) {
            changesArray.add({
              'fieldName': entry.key,
              'oldValue': entry.value['oldValue']?.toString() ?? '',
              'newValue': entry.value['newValue']?.toString() ?? '',
            });
          }

          final String employeeName = '${employee?.firstName?.lastOrNull ?? ''} ${employee?.lastName?.lastOrNull ?? ''}'.trim();
          final String employeeEmail = employee?.email?.lastOrNull ?? '';
          final DateTime requestDate = DateTime.now();
          final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(requestDate);

          final Map<String, dynamic> requestData = {
            'changes': changesArray,
            'section': 'Personal Information',
            'requestDate': FieldValue.serverTimestamp(),
            'requestDateFormatted': formattedDate,
            'requestNote': requestNoteController.text.trim().isNotEmpty
                ? requestNoteController.text.trim()
                : '',
            'status': 'approved', // Auto-approved since we updated directly
            'employeeId': employeeId,
            'employeeEmail': employeeEmail,
            'employeeName': employeeName,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'numberOfChanges': changesArray.length,
          };

          await requestDocRef.set(requestData);

          print('✅ Request record created for audit trail');

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

          await Future.delayed(Duration(seconds: 2));

          // Close success dialog
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // Close preview page
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // Close edit page
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

        } catch (e, stackTrace) {
          // Close loading dialog if open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

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

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isPhone = context.isPhone;
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
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: Color(0xff2D2D2D),
                        ),
                        width: isPhone ? 120.sp : 135.sp,
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
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isPhone ?120.sp : 135.sp,                        height: 38.sp,
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

  Future<void> showSuccessDialog({
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
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
                    color: AppColors.secondaryText,
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