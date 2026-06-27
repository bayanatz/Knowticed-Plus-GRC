import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/grc/drop_down.dart';
import 'package:demo_app/features/roles/helper/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../../../../../../knowledge_hub_module/core/custom_buttons.dart';
import '../../../../../../core/custom_widgets/SideFrameMaster.dart';
import '../../employee_firebase_service.dart';

class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1000;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileMaxWidth &&
          MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth;
}

class HREmployeePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic>? contactInfo;
  final Map<String, dynamic>? addressInfo;
  final Map<String, dynamic>? identificationInfo;
  final Map<String, dynamic>? positionInfo;
  final Map<String, dynamic>? certificationInfo;
  final Map<String, dynamic>? insuranceInfo;
  final Map<String, dynamic>? emergencyInfo;

  const HREmployeePreviewScreen({
    super.key,
    required this.personalInfo,
    this.contactInfo,
    this.addressInfo,
    this.identificationInfo,
    this.positionInfo,
    this.certificationInfo,
    this.insuranceInfo,
    this.emergencyInfo,
  });

  @override
  State<HREmployeePreviewScreen> createState() =>
      _HREmployeePreviewScreenState();
}

class _HREmployeePreviewScreenState extends State<HREmployeePreviewScreen> {
  // Expansion states
  bool _isPersonalInfoExpanded = true;
  bool _isContactDetailsExpanded = true;
  bool _isAddressDetailsExpanded = true;
  bool _isIdentificationDetailsExpanded = true;
  bool _isPositionDetailsExpanded = true;
  bool _isCertificationDetailsExpanded = true;
  bool _isHealthInsuranceExpanded = true;
  bool _isEmergencyContactsExpanded = true;


// Add at the top of the class
  final EmployeeFirebaseService _firebaseService = EmployeeFirebaseService();
  bool _isUploading = false;

// Confirmation Dialog
  Future<void> _showConfirmationDialog() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Confirm Employee Creation',
            style: AppTextStyles.font16BlackSemiBoldCairo.copyWith(color: AppColors.text),
          ),
          content: Text(
            'Are you sure you want to create this employee?\n\nA unique 8-digit employee ID will be generated automatically.',
            style: AppTextStyles.font14BlackCairoRegular.copyWith(color: AppColors.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Yes',
                style: AppTextStyles.font14BlackCairoMedium.copyWith(
                  color: AppColors.textButton,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _createEmployee();
    }
  }

// Create Employee Function
  // Update this method in _HREmployeePreviewScreenState

  Future<void> _createEmployee() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final employeeId = await _firebaseService.createNewEmployee(
        personalInfo: widget.personalInfo,
        contactInfo: widget.contactInfo,
        addressInfo: widget.addressInfo,
        identificationInfo: widget.identificationInfo,
        positionInfo: widget.positionInfo,
        certificationInfo: widget.certificationInfo,
        insuranceInfo: widget.insuranceInfo,
        emergencyInfo: widget.emergencyInfo,
      );

      setState(() {
        _isUploading = false;
      });

      if (employeeId != null && mounted) {
        // Success Dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 28.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Success!',
                    style: AppTextStyles.font16BlackSemiBoldCairo.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Employee created successfully!\n\nEmployee ID: $employeeId',
                style: AppTextStyles.font14BlackCairoRegular.copyWith(
                  color: AppColors.text,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Close dialog first
                    Navigator.of(dialogContext).pop();

                    // Then navigate back to the main screen
                    // Pop preview screen
                    Navigator.of(context).pop();
                    // Pop add employee screen
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: AppTextStyles.font14BlackCairoMedium.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else if (mounted) {
        // Error Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create employee. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: SideFrameMaster(
        titleText: "HR",
        secondTitle: "Employees",
        thirdTitle: "Adding New Employee",
        child: Column(
          children: [
            // Tabs Header (read-only, all filled)
            Container(
              width: 1000.w,
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: isMobile
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCompletedTab('Personal Information', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Contact Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Address Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Identification Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Position Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Certification Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Insurance Details', isMobile),
                    SizedBox(width: 12.w),
                    _buildCompletedTab('Emergency Details', isMobile),
                  ],
                ),
              )
                  : Wrap(
                spacing: 7.w,
                runSpacing: 10.h,
                children: [
                  _buildCompletedTab('Personal Information', isMobile),
                  _buildCompletedTab('Contact Details', isMobile),
                  _buildCompletedTab('Address Details', isMobile),
                  _buildCompletedTab('Identification Details', isMobile),
                  _buildCompletedTab('Position Details', isMobile),
                  _buildCompletedTab('Certification Details', isMobile),
                  _buildCompletedTab('Insurance Details', isMobile),
                  _buildCompletedTab('Emergency Details', isMobile),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    children: [
                      // Personal Information
                      _buildSectionHeader(
                          'Personal Information', _isPersonalInfoExpanded, () {
                        setState(() {
                          _isPersonalInfoExpanded = !_isPersonalInfoExpanded;
                        });
                      }, isMobile),
                      if (_isPersonalInfoExpanded)
                        _buildPersonalInformationContent(isMobile, isTablet),

                      // Contact Details
                      _buildSectionHeader(
                          'Contact Details', _isContactDetailsExpanded, () {
                        setState(() {
                          _isContactDetailsExpanded =
                          !_isContactDetailsExpanded;
                        });
                      }, isMobile),
                      if (_isContactDetailsExpanded)
                        _buildContactDetailsContent(isMobile, isTablet),

                      // Address Details
                      _buildSectionHeader(
                          'Address Details', _isAddressDetailsExpanded, () {
                        setState(() {
                          _isAddressDetailsExpanded =
                          !_isAddressDetailsExpanded;
                        });
                      }, isMobile),
                      if (_isAddressDetailsExpanded)
                        _buildAddressDetailsContent(isMobile, isTablet),

                      // Identification Details
                      _buildSectionHeader('Identification Details',
                          _isIdentificationDetailsExpanded, () {
                            setState(() {
                              _isIdentificationDetailsExpanded =
                              !_isIdentificationDetailsExpanded;
                            });
                          }, isMobile),
                      if (_isIdentificationDetailsExpanded)
                        _buildIdentificationDetailsContent(isMobile, isTablet),

                      // Position Details
                      _buildSectionHeader(
                          'Position Details', _isPositionDetailsExpanded, () {
                        setState(() {
                          _isPositionDetailsExpanded =
                          !_isPositionDetailsExpanded;
                        });
                      }, isMobile),
                      if (_isPositionDetailsExpanded)
                        _buildPositionDetailsContent(isMobile, isTablet),

                      // Certification Details
                      _buildSectionHeader('Certification Details',
                          _isCertificationDetailsExpanded, () {
                            setState(() {
                              _isCertificationDetailsExpanded =
                              !_isCertificationDetailsExpanded;
                            });
                          }, isMobile),
                      if (_isCertificationDetailsExpanded)
                        _buildCertificationDetailsContent(isMobile, isTablet),

                      // Health Insurance
                      _buildSectionHeader(
                          'Health Insurance', _isHealthInsuranceExpanded, () {
                        setState(() {
                          _isHealthInsuranceExpanded =
                          !_isHealthInsuranceExpanded;
                        });
                      }, isMobile),
                      if (_isHealthInsuranceExpanded)
                        _buildHealthInsuranceContent(isMobile, isTablet),

                      // Emergency Contacts
                      _buildSectionHeader('Emergency Contact',
                          _isEmergencyContactsExpanded, () {
                            setState(() {
                              _isEmergencyContactsExpanded =
                              !_isEmergencyContactsExpanded;
                            });
                          }, isMobile),
                      if (_isEmergencyContactsExpanded)
                        _buildEmergencyContactsContent(isMobile, isTablet),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    context: context,
                    title: 'Back',
                    function: () {
                      Navigator.pop(context);
                    },
                    width: isMobile ? 135.w : 150.w,
                    height: 38.h,
                    radius: 8.r,
                    color: lightMode ? Colors.grey[400] : Colors.grey[700],
                    textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                      color: lightMode ? Colors.black : Colors.white,
                    ),
                  ),
                  customButton(
                    context: context,
                    title: 'Create',
                    function: _isUploading ? () {} : () => _showConfirmationDialog(),
                    width: isMobile ? 135.w : 150.w,
                    height: 38.h,
                    radius: 8.r,
                    color: _isUploading ? Colors.grey : AppColors.primary,
                    textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),

// Add loading indicator if uploading
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTab(String title, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: (isMobile
              ? AppTextStyles.font12BlackMediumCairo
              : AppTextStyles.font14BlackCairoMedium)
              .copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 8.h,
          width: isMobile ? 100.w : 105.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(64.r),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, bool isExpanded, VoidCallback onTap, bool isMobile) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10.w : 15.w,
            vertical: isMobile ? 10.h : 15.h),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.w : 16.w,
              vertical: isMobile ? 10.h : 12.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryText.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: (isMobile
                      ? AppTextStyles.font14BlackCairoMedium
                      : AppTextStyles.font16BlackMediumCairo)
                      .copyWith(
                    color: AppColors.text,
                  ),
                ),
              ),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.text,
                size: isMobile ? 20.sp : 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Personal Information Content
  Widget _buildPersonalInformationContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: Column(
        children: [
          if (isMobile) ...[
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'First Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.personalInfo['firstName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Middle Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.personalInfo['middleName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Last Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.personalInfo['lastName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),

            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Gender',
              selectedValue: widget.personalInfo['gender'],
              items: const [
                {'key': 'male', 'value': 'Male'},
                {'key': 'female', 'value': 'Female'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
              height: 36,

            ),
            SizedBox(height: 16.h),
            CustomDropdownFormFieldCalender(
              dropdownColor: AppColors.background,
              label: 'Birthday',
              selectedValue: widget.personalInfo['birthday'],
              onChanged: (value) {},
              widthIcon: 12.w,
              heightIcon: 12.h,
              hint: Text('Select Date', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
              height: 36,

            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Marital Status',
              selectedValue: widget.personalInfo['maritalStatus'],
              items: const [
                {'key': 'married', 'value': 'Married'},
                {'key': 'single', 'value': 'Single'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
              height: 36,

            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Nationality',
              selectedValue: widget.personalInfo['nationality'],
              items: const [
                {'key': 'eg', 'value': 'Egyptian'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
              height: 36,

            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Language',
              selectedValue: widget.personalInfo['language'],
              items: const [
                {'key': 'arabic', 'value': 'Arabic'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
              height: 36,

            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'First Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.personalInfo['firstName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Middle Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.personalInfo['middleName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Last Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.personalInfo['lastName'] ?? ''),
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Gender',
                    selectedValue: widget.personalInfo['gender'],
                    items: const [
                      {'key': 'male', 'value': 'Male'},
                      {'key': 'female', 'value': 'Female'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
                    height: 36,

                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdownFormFieldCalender(
                    dropdownColor: AppColors.background,
                    label: 'Birthday',
                    selectedValue: widget.personalInfo['birthday'],
                    onChanged: (value) {},
                    widthIcon: 12.w,
                    heightIcon: 12.h,
                    hint: Text('Select Date',
                        style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
                    height: 35,

                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Marital Status',
                    selectedValue: widget.personalInfo['maritalStatus'],
                    items: const [
                      {'key': 'married', 'value': 'Married'},
                      {'key': 'single', 'value': 'Single'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
                    height: 36,

                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Nationality',
                    selectedValue: widget.personalInfo['nationality'],
                    items: const [
                      {'key': 'eg', 'value': 'Egyptian'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
                    height: 36,

                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Language',
                    selectedValue: widget.personalInfo['language'],
                    items: const [
                      {'key': 'arabic', 'value': 'Arabic'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText)),
                    height: 36,

                  ),
                ),
                Expanded(child: SizedBox()),
                SizedBox(width: 16.w),

              ],
            ),
          ],
        ],
      ),
    );
  }

  // Placeholder methods for other sections (implement similarly)
  Widget _buildContactDetailsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Mobile Phone',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['mobilePhone'] ?? ''),
            keyboardType: TextInputType.phone,
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor:AppColors.background,
            label: 'Home Number',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['homeNumber'] ?? ''),
            keyboardType: TextInputType.phone,
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Personal Email',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['personalEmail'] ?? ''),
            keyboardType: TextInputType.emailAddress,
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor:AppColors.background,
            label: 'Office Number',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['officeNumber'] ?? ''),
            keyboardType: TextInputType.phone,
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Extension',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['extension'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Business Email',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.contactInfo?['businessEmail'] ?? ''),
            keyboardType: TextInputType.emailAddress,
            enabled: false,
          ),
        ],
      )
          : Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Mobile Phone',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['mobilePhone'] ?? ''),
                  keyboardType: TextInputType.phone,
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Home Number',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['homeNumber'] ?? ''),
                  keyboardType: TextInputType.phone,
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Personal Email',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['personalEmail'] ?? ''),
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Office Number',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['officeNumber'] ?? ''),
                  keyboardType: TextInputType.phone,
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Extension',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['extension'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Business Email',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.contactInfo?['businessEmail'] ?? ''),
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Country',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.addressInfo?['country'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor:AppColors.background,
            label: 'Province',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.addressInfo?['province'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'City',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.addressInfo?['city'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Street',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.addressInfo?['street'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Postal Code',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.addressInfo?['postalCode'] ?? ''),
            keyboardType: TextInputType.number,
            enabled: false,
          ),
        ],
      )
          : Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Country',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.addressInfo?['country'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Province',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.addressInfo?['province'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'City',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.addressInfo?['city'] ?? ''),
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Street',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.addressInfo?['street'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Postal Code',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.addressInfo?['postalCode'] ?? ''),
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationDetailsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'National ID',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.identificationInfo?['nationalId'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.background,
            label: 'National ID Expiration',
            selectedValue: widget.identificationInfo?['nationalIdExpiration'],
            onChanged: (value) {},
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Passport',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.identificationInfo?['passport'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.background,
            label: 'Passport Expiration',
            selectedValue: widget.identificationInfo?['passportExpiration'],
            onChanged: (value) {},
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Driving License ID',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.identificationInfo?['drivingLicenseId'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Car Plate',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.identificationInfo?['carPlate'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Passport',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              customButtonWithImage(
                title: 'Upload',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium
                    .copyWith(color: AppColors.text),
                height: 36.h,
                space: 8.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/upload.svg',
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload National ID',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              customButtonWithImage(
                title: 'Upload',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium
                    .copyWith(color: AppColors.text),
                height: 36.h,
                space: 8.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/upload.svg',
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Driving License ID',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              customButtonWithImage(
                title: 'Upload',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium
                    .copyWith(color: AppColors.text),
                height: 36.h,
                space: 8.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/upload.svg',
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
        ],
      )
          : Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'National ID',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.identificationInfo?['nationalId'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.background,
                  label: 'National ID Expiration',
                  selectedValue: widget.identificationInfo?['nationalIdExpiration'],
                  onChanged: (value) {},
                  widthIcon: 12.w,
                  heightIcon: 12.h,
                  hint: Text('Select Date',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 35,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Passport',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.identificationInfo?['passport'] ?? ''),
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.background,
                  label: 'Passport Expiration',
                  selectedValue: widget.identificationInfo?['passportExpiration'],
                  onChanged: (value) {},
                  widthIcon: 12.w,
                  heightIcon: 12.h,
                  hint: Text('Select Date',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 35,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Driving License ID',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.identificationInfo?['drivingLicenseId'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Car Plate',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.identificationInfo?['carPlate'] ?? ''),
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Passport',
                        style: AppTextStyles.font14BlackCairoRegular
                            .copyWith(color: AppColors.text)),
                    SizedBox(height: 8.h),
                    customButtonWithImage(
                      title: 'Upload',
                      function: () {},
                      textStyle: AppTextStyles.font14BlackCairoMedium
                          .copyWith(color: AppColors.textButton),
                      height: 36.h,
                      width: 171.w,
                      space: 8.w,
                      radius: 4.r,
                      color: AppColors.primary,
                      image: 'assets/hrAsset/Upload.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload National ID',
                        style: AppTextStyles.font14BlackCairoRegular
                            .copyWith(color: AppColors.text)),
                    SizedBox(height: 8.h),
                    customButtonWithImage(
                      title: 'Upload',
                      function: () {},
                      textStyle: AppTextStyles.font14BlackCairoMedium
                          .copyWith(color: AppColors.textButton),
                      height: 36.h,
                      width: 171.w,
                      space: 8.w,
                      radius: 4.r,
                      color: AppColors.primary,
                      image: 'assets/hrAsset/Upload.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Driving License ID',
                        style: AppTextStyles.font14BlackCairoRegular
                            .copyWith(color: AppColors.text)),
                    SizedBox(height: 8.h),
                    customButtonWithImage(
                      title: 'Upload',
                      function: () {},
                      textStyle: AppTextStyles.font14BlackCairoMedium
                          .copyWith(color: AppColors.textButton),
                      height: 36.h,
                      width: 171.w,
                      space: 8.w,
                      radius: 4.r,
                      color: AppColors.primary,
                      image: 'assets/hrAsset/Upload.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionDetailsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Job Title',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.positionInfo?['jobTitle'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Department',
            selectedValue: widget.positionInfo?['department'],
            items: const [
              {'key': 'hr', 'value': 'HR'},
              {'key': 'it', 'value': 'IT'},
              {'key': 'finance', 'value': 'Finance'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Job Type',
            selectedValue: widget.positionInfo?['jobType'],
            items: const [
              {'key': 'full_time', 'value': 'Full Time'},
              {'key': 'part_time', 'value': 'Part Time'},
              {'key': 'contract', 'value': 'Contract'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Work Arrangement',
            selectedValue: widget.positionInfo?['workArrangement'],
            items: const [
              {'key': 'onsite', 'value': 'Onsite'},
              {'key': 'remote', 'value': 'Remote'},
              {'key': 'hybrid', 'value': 'Hybrid'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Remote Status',
            selectedValue: widget.positionInfo?['remoteStatus'],
            items: const [
              {'key': 'fully_remote', 'value': 'Fully Remote'},
              {'key': 'partially_remote', 'value': 'Partially Remote'},
              {'key': 'not_remote', 'value': 'Not Remote'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Job Location',
            selectedValue: widget.positionInfo?['jobLocation'],
            items: const [
              {'key': 'cairo', 'value': 'Cairo'},
              {'key': 'alex', 'value': 'Alexandria'},
              {'key': 'giza', 'value': 'Giza'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.background,
            label: 'Start Date',
            selectedValue: widget.positionInfo?['startDate'],
            onChanged: (value) {},
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Working Hours',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              CustomValidatedTextField(
                fillColor: AppColors.background,
                hint: 'Select Time',
                controller: TextEditingController(
                    text: widget.positionInfo?['workingHours'] ?? ''),
                label: '',
                enabled: false,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Days Off',
            selectedValue: widget.positionInfo?['daysOff'],
            items: const [
              {'key': 'friday', 'value': 'Friday'},
              {'key': 'saturday', 'value': 'Saturday'},
              {'key': 'sunday', 'value': 'Sunday'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Salary',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.positionInfo?['salary'] ?? ''),
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Currency',
                  selectedValue: widget.positionInfo?['currency'],
                  items: const [
                    {'key': 'egp', 'value': 'EGP'},
                    {'key': 'usd', 'value': 'USD'},
                    {'key': 'eur', 'value': 'EUR'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Currency',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
            ],
          ),
        ],
      )
          : Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Job Title',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.positionInfo?['jobTitle'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Department',
                  selectedValue: widget.positionInfo?['department'],
                  items: const [
                    {'key': 'hr', 'value': 'HR'},
                    {'key': 'it', 'value': 'IT'},
                    {'key': 'finance', 'value': 'Finance'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Job Type',
                  selectedValue: widget.positionInfo?['jobType'],
                  items: const [
                    {'key': 'full_time', 'value': 'Full Time'},
                    {'key': 'part_time', 'value': 'Part Time'},
                    {'key': 'contract', 'value': 'Contract'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Work Arrangement',
                  selectedValue: widget.positionInfo?['workArrangement'],
                  items: const [
                    {'key': 'onsite', 'value': 'Onsite'},
                    {'key': 'remote', 'value': 'Remote'},
                    {'key': 'hybrid', 'value': 'Hybrid'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Remote Status',
                  selectedValue: widget.positionInfo?['remoteStatus'],
                  items: const [
                    {'key': 'fully_remote', 'value': 'Fully Remote'},
                    {'key': 'partially_remote', 'value': 'Partially Remote'},
                    {'key': 'not_remote', 'value': 'Not Remote'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Job Location',
                  selectedValue: widget.positionInfo?['jobLocation'],
                  items: const [
                    {'key': 'cairo', 'value': 'Cairo'},
                    {'key': 'alex', 'value': 'Alexandria'},
                    {'key': 'giza', 'value': 'Giza'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.background,
                  label: 'Start Date',
                  selectedValue: widget.positionInfo?['startDate'],
                  onChanged: (value) {},
                  widthIcon: 12.w,
                  heightIcon: 12.h,
                  hint: Text('Select Date',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 35,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomValidatedTextField(
                      fillColor: AppColors.background,
                      hint: 'Select Time',
                      controller: TextEditingController(
                          text: widget.positionInfo?['workingHours'] ?? ''),
                      label: 'Working Hours',
                      height: 40,
                      enabled: false,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Days Off',
                  selectedValue: widget.positionInfo?['daysOff'],
                  items: const [
                    {'key': 'friday', 'value': 'Friday'},
                    {'key': 'saturday', 'value': 'Saturday'},
                    {'key': 'sunday', 'value': 'Sunday'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Salary',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.positionInfo?['salary'] ?? ''),
                  keyboardType: TextInputType.number,
                  enabled: false,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Currency',
                  selectedValue: widget.positionInfo?['currency'],
                  items: const [
                    {'key': 'egp', 'value': 'EGP'},
                    {'key': 'usd', 'value': 'USD'},
                    {'key': 'eur', 'value': 'EUR'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Currency',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 34,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildCertificationDetailsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Institution Name',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.certificationInfo?['institutionName'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Degree Or Certification',
            selectedValue: widget.certificationInfo?['degreeOrCertification'],
            items: const [
              {'key': 'bachelor', 'value': 'Bachelor'},
              {'key': 'master', 'value': 'Master'},
              {'key': 'phd', 'value': 'PhD'},
              {'key': 'diploma', 'value': 'Diploma'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Field of Study',
            selectedValue: widget.certificationInfo?['fieldOfStudy'],
            items: const [
              {'key': 'cs', 'value': 'Computer Science'},
              {'key': 'engineering', 'value': 'Engineering'},
              {'key': 'business', 'value': 'Business'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.background,
            label: 'Start Date',
            selectedValue: widget.certificationInfo?['startDate'],
            onChanged: (value) {},
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.background,
            label: 'End Date',
            selectedValue: widget.certificationInfo?['endDate'],
            onChanged: (value) {},
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Grade Or Score',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.certificationInfo?['gradeOrScore'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Certificate ID',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.certificationInfo?['certificateId'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.background,
            label: 'Issuing Authority',
            selectedValue: widget.certificationInfo?['issuingAuthority'],
            items: const [
              {'key': 'university', 'value': 'University'},
              {'key': 'institution', 'value': 'Institution'},
            ],
            onChanged: (value) {},
            validator: (value) => '',
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Document URL',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              customButtonWithImage(
                title: 'Upload',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium
                    .copyWith(color: AppColors.text),
                height: 36.h,
                space: 8.w,
                radius: 8.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/upload.svg',
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Notes',
            hint: 'Text here',
            height: 72.h,
            controller: TextEditingController(
                text: widget.certificationInfo?['notes'] ?? ''),
            maxLines: 4,
            enabled: false,
          ),
        ],
      )
          : Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Institution Name',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.certificationInfo?['institutionName'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Degree Or Certification',
                  selectedValue: widget.certificationInfo?['degreeOrCertification'],
                  items: const [
                    {'key': 'bachelor', 'value': 'Bachelor'},
                    {'key': 'master', 'value': 'Master'},
                    {'key': 'phd', 'value': 'PhD'},
                    {'key': 'diploma', 'value': 'Diploma'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Field of Study',
                  selectedValue: widget.certificationInfo?['fieldOfStudy'],
                  items: const [
                    {'key': 'cs', 'value': 'Computer Science'},
                    {'key': 'engineering', 'value': 'Engineering'},
                    {'key': 'business', 'value': 'Business'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.background,
                  label: 'Start Date',
                  selectedValue: widget.certificationInfo?['startDate'],
                  onChanged: (value) {},
                  widthIcon: 12.w,
                  heightIcon: 12.h,
                  hint: Text('Select Date',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 35,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.background,
                  label: 'End Date',
                  selectedValue: widget.certificationInfo?['endDate'],
                  onChanged: (value) {},
                  widthIcon: 12.w,
                  heightIcon: 12.h,
                  hint: Text('Select Date',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 35,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Grade Or Score',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.certificationInfo?['gradeOrScore'] ?? ''),
                  enabled: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.background,
                  label: 'Certificate ID',
                  hint: 'Text Here',
                  controller: TextEditingController(
                      text: widget.certificationInfo?['certificateId'] ?? ''),
                  enabled: false,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.background,
                  label: 'Issuing Authority',
                  selectedValue: widget.certificationInfo?['issuingAuthority'],
                  items: const [
                    {'key': 'university', 'value': 'University'},
                    {'key': 'institution', 'value': 'Institution'},
                  ],
                  onChanged: (value) {},
                  validator: (value) => '',
                  widthIcon: 12,
                  heightIcon: 12,
                  hint: Text('Select',
                      style: AppTextStyles.font12BlackCairoRegular
                          .copyWith(color: AppColors.secondaryText)),
                  height: 36,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Upload Document URL',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              Expanded(child: SizedBox()),
              customButtonWithImage(
                title: 'Upload',
                function: () {},
                textStyle: AppTextStyles.font14BlackCairoMedium
                    .copyWith(color: AppColors.textButton),
                height: 36.h,
                width: 122.w,
                space: 8.w,
                radius: 4.r,
                color: AppColors.primary,
                image: 'assets/hrAsset/Upload.svg',
                svgColor: AppColors.textButton,
                widthImage: 16.sp,
                heightImage: 16.sp,
                colorBorder: Colors.transparent,
              ),
              SizedBox(width: 2.w),
              Expanded(child: SizedBox()),
              SizedBox(width: 2.w),
              Expanded(child: SizedBox()),
              SizedBox(width: 80.w),
            ],
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Notes',
            hint: 'Text here',
            height: 72.h,
            controller: TextEditingController(
                text: widget.certificationInfo?['notes'] ?? ''),
            maxLines: 4,
            enabled: false,
          ),
        ],
      ),
    );
  }
  Widget _buildHealthInsuranceContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: isMobile
          ? Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Insurance Name',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.insuranceInfo?['insuranceName'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Insurance Policy Number',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.insuranceInfo?['insurancePolicyNumber'] ?? ''),
            enabled: false,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.background,
            label: 'Insurance Provider Contact',
            hint: 'Text Here',
            controller: TextEditingController(
                text: widget.insuranceInfo?['insuranceProviderContact'] ?? ''),
            enabled: false,
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Insurance Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.insuranceInfo?['insuranceName'] ?? ''),
              enabled: false,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Insurance Policy Number',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.insuranceInfo?['insurancePolicyNumber'] ?? ''),
              enabled: false,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Insurance Provider Contact',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.insuranceInfo?['insuranceProviderContact'] ?? ''),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmergencyContactsContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10.w : 15.w, vertical: isMobile ? 12.h : 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Emergency Contact Section
          Text(
            'First Emergency Contact',
            style: AppTextStyles.font16BlackSemiBoldCairo.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 16.h),

          if (isMobile) ...[
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'First Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['firstName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Middle Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['middleName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Last Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['lastName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Relationship',
              selectedValue: widget.emergencyInfo?['firstContact']?['relationship'],
              items: const [
                {'key': 'spouse', 'value': 'Spouse'},
                {'key': 'parent', 'value': 'Parent'},
                {'key': 'sibling', 'value': 'Sibling'},
                {'key': 'friend', 'value': 'Friend'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select',
                  style: AppTextStyles.font12BlackCairoRegular
                      .copyWith(color: AppColors.secondaryText)),
              height: 36,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Email',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['email'] ?? ''),
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Mobile Phone',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['mobilePhone'] ?? ''),
              keyboardType: TextInputType.phone,
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Country',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['country'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Province',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['firstContact']?['province'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Language',
              selectedValue: widget.emergencyInfo?['firstContact']?['language'],
              items: const [
                {'key': 'arabic', 'value': 'Arabic'},
                {'key': 'english', 'value': 'English'},
                {'key': 'indian', 'value': 'Indian'},
                {'key': 'german', 'value': 'German'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select',
                  style: AppTextStyles.font12BlackCairoRegular
                      .copyWith(color: AppColors.secondaryText)),
              height: 36,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'First Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['firstName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Middle Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['middleName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Last Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['lastName'] ?? ''),
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Relationship',
                    selectedValue: widget.emergencyInfo?['firstContact']?['relationship'],
                    items: const [
                      {'key': 'spouse', 'value': 'Spouse'},
                      {'key': 'parent', 'value': 'Parent'},
                      {'key': 'sibling', 'value': 'Sibling'},
                      {'key': 'friend', 'value': 'Friend'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select',
                        style: AppTextStyles.font12BlackCairoRegular
                            .copyWith(color: AppColors.secondaryText)),
                    height: 36,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Email',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['email'] ?? ''),
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Mobile Phone',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['mobilePhone'] ?? ''),
                    keyboardType: TextInputType.phone,
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Country',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['country'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Province',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['firstContact']?['province'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Language',
                    selectedValue: widget.emergencyInfo?['firstContact']?['language'],
                    items: const [
                      {'key': 'arabic', 'value': 'Arabic'},
                      {'key': 'english', 'value': 'English'},
                      {'key': 'indian', 'value': 'Indian'},
                      {'key': 'german', 'value': 'German'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select',
                        style: AppTextStyles.font12BlackCairoRegular
                            .copyWith(color: AppColors.secondaryText)),
                    height: 36,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 32.h),

          // Second Emergency Contact Section
          Text(
            'Second Emergency Contact',
            style: AppTextStyles.font16BlackSemiBoldCairo.copyWith(color: AppColors.text),
          ),
          SizedBox(height: 16.h),

          if (isMobile) ...[
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'First Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['firstName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Middle Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['middleName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Last Name',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['lastName'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Relationship',
              selectedValue: widget.emergencyInfo?['secondContact']?['relationship'],
              items: const [
                {'key': 'spouse', 'value': 'Spouse'},
                {'key': 'parent', 'value': 'Parent'},
                {'key': 'sibling', 'value': 'Sibling'},
                {'key': 'friend', 'value': 'Friend'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select',
                  style: AppTextStyles.font12BlackCairoRegular
                      .copyWith(color: AppColors.secondaryText)),
              height: 36,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Email',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['email'] ?? ''),
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Mobile Phone',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['mobilePhone'] ?? ''),
              keyboardType: TextInputType.phone,
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Country',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['country'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomValidatedTextField(
              fillColor: AppColors.background,
              label: 'Province',
              hint: 'Text Here',
              controller: TextEditingController(
                  text: widget.emergencyInfo?['secondContact']?['province'] ?? ''),
              enabled: false,
            ),
            SizedBox(height: 16.h),
            CustomDropdownFormField(
              dropdownColor: AppColors.background,
              label: 'Language',
              selectedValue: widget.emergencyInfo?['secondContact']?['language'],
              items: const [
                {'key': 'arabic', 'value': 'Arabic'},
                {'key': 'english', 'value': 'English'},
                {'key': 'indian', 'value': 'Indian'},
                {'key': 'german', 'value': 'German'},
              ],
              onChanged: (value) {},
              validator: (value) => '',
              widthIcon: 12,
              heightIcon: 12,
              hint: Text('Select',
                  style: AppTextStyles.font12BlackCairoRegular
                      .copyWith(color: AppColors.secondaryText)),
              height: 36,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'First Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['firstName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Middle Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['middleName'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Last Name',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['lastName'] ?? ''),
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Relationship',
                    selectedValue: widget.emergencyInfo?['secondContact']?['relationship'],
                    items: const [
                      {'key': 'spouse', 'value': 'Spouse'},
                      {'key': 'parent', 'value': 'Parent'},
                      {'key': 'sibling', 'value': 'Sibling'},
                      {'key': 'friend', 'value': 'Friend'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select',
                        style: AppTextStyles.font12BlackCairoRegular
                            .copyWith(color: AppColors.secondaryText)),
                    height: 36,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Email',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['email'] ?? ''),
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Mobile Phone',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['mobilePhone'] ?? ''),
                    keyboardType: TextInputType.phone,
                    enabled: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Country',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['country'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomValidatedTextField(
                    fillColor: AppColors.background,
                    label: 'Province',
                    hint: 'Text Here',
                    controller: TextEditingController(
                        text: widget.emergencyInfo?['secondContact']?['province'] ?? ''),
                    enabled: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdownFormField(
                    dropdownColor: AppColors.background,
                    label: 'Language',
                    selectedValue: widget.emergencyInfo?['secondContact']?['language'],
                    items: const [
                      {'key': 'arabic', 'value': 'Arabic'},
                      {'key': 'english', 'value': 'English'},
                      {'key': 'indian', 'value': 'Indian'},
                      {'key': 'german', 'value': 'German'},
                    ],
                    onChanged: (value) {},
                    validator: (value) => '',
                    widthIcon: 12,
                    heightIcon: 12,
                    hint: Text('Select',
                        style: AppTextStyles.font12BlackCairoRegular
                            .copyWith(color: AppColors.secondaryText)),
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }}