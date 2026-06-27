import 'dart:io';

import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/grc/drop_down.dart';
import 'package:demo_app/features/roles/helper/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../../../../../../knowledge_hub_module/core/custom_buttons.dart';
import '../../../../../../core/custom_widgets/SideFrameMaster.dart';
import 'hr_employee_preview_screen.dart';

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

class HRAddNewEmployeeScreen extends StatefulWidget {
  const HRAddNewEmployeeScreen({super.key});

  @override
  State<HRAddNewEmployeeScreen> createState() => _HRAddNewEmployeeScreenState();
}

class _HRAddNewEmployeeScreenState extends State<HRAddNewEmployeeScreen> {
  int _currentStep = 0;

// Profile and Document Images
  File? _profileImage;

  File? _passportImage;
  String? _passportImageName;
  int? _passportImageSize;
  DateTime? _passportImageDate;

  File? _nationalIdImage;
  String? _nationalIdImageName;
  int? _nationalIdImageSize;
  DateTime? _nationalIdImageDate;

  File? _drivingLicenseImage;
  String? _drivingLicenseImageName;
  int? _drivingLicenseImageSize;
  DateTime? _drivingLicenseImageDate;

  File? _certificationDocImage;
  String? _certificationDocImageName;
  int? _certificationDocImageSize;
  DateTime? _certificationDocImageDate;

  // Controllers for Personal Information
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedGender;
  String? _selectedBirthday;
  String? _selectedMaritalStatus;
  String? _selectedNationality;
  String? _selectedLanguage;

  // Controllers for Contact Details
  final TextEditingController _mobilePhoneController = TextEditingController();
  final TextEditingController _homeNumberController = TextEditingController();
  final TextEditingController _personalEmailController =
      TextEditingController();
  final TextEditingController _officeNumberController = TextEditingController();
  final TextEditingController _extensionController = TextEditingController();
  final TextEditingController _businessEmailController =
      TextEditingController();

  // Controllers for Address Details
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Controllers for Insurance Details
  final TextEditingController _insuranceNameController = TextEditingController();
  final TextEditingController _insurancePolicyNumberController = TextEditingController();
  final TextEditingController _insuranceProviderContactController = TextEditingController();

// Controllers for Emergency Details - First Contact
  final TextEditingController _emergencyFirstNameController = TextEditingController();
  final TextEditingController _emergencyMiddleNameController = TextEditingController();
  final TextEditingController _emergencyLastNameController = TextEditingController();
  String? _selectedEmergencyRelationship;
  final TextEditingController _emergencyEmailController = TextEditingController();
  final TextEditingController _emergencyMobilePhoneController = TextEditingController();
  final TextEditingController _emergencyCountryController = TextEditingController();
  final TextEditingController _emergencyProvinceController = TextEditingController();
  String? _selectedEmergencyLanguage;

// Controllers for Emergency Details - Second Contact
  final TextEditingController _emergencySecondFirstNameController = TextEditingController();
  final TextEditingController _emergencySecondMiddleNameController = TextEditingController();
  final TextEditingController _emergencySecondLastNameController = TextEditingController();
  String? _selectedEmergencySecondRelationship;
  final TextEditingController _emergencySecondEmailController = TextEditingController();
  final TextEditingController _emergencySecondMobilePhoneController = TextEditingController();
  final TextEditingController _emergencySecondCountryController = TextEditingController();
  final TextEditingController _emergencySecondProvinceController = TextEditingController();
  String? _selectedEmergencySecondLanguage;



  final TextEditingController _nationalIdController = TextEditingController();
  String? _selectedNationalIdExpiration;
  final TextEditingController _passportController = TextEditingController();
  String? _selectedPassportExpiration;
  final TextEditingController _drivingLicenseController = TextEditingController();
  final TextEditingController _carPlateController = TextEditingController();

// Position Details Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedJobType;
  String? _selectedWorkArrangement;
  String? _selectedRemoteStatus;
  String? _selectedJobLocation;
  String? _selectedStartDate;
  final TextEditingController _workingHoursController = TextEditingController();
  String? _selectedDaysOff;
  final TextEditingController _salaryController = TextEditingController();
  String? _selectedCurrency;

// Certification Details Controllers
  final TextEditingController _institutionNameController = TextEditingController();
  String? _selectedDegreeOrCertification;
  String? _selectedFieldOfStudy;
  String? _selectedCertStartDate;
  String? _selectedCertEndDate;
  final TextEditingController _gradeOrScoreController = TextEditingController();
  final TextEditingController _certificateIdController = TextEditingController();
  String? _selectedIssuingAuthority;
  final TextEditingController _notesController = TextEditingController();

  // Track completion status of each tab
  final List<bool> _tabCompleted = List.generate(8, (index) => false);

  final List<String> _tabTitles = [
    'Personal Information',
    'Contact Details',
    'Address Details',
    'Identification Details',
    'Position Details',
    'Certification Details',
    'Insurance Details',
    'Emergency Details',
  ];




  // Add this method to _HRAddNewEmployeeScreenState class

  Map<String, dynamic> _collectAllFormData() {
    return {
      // Personal Information
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text,
      'lastName': _lastNameController.text,
      'gender': _selectedGender,
      'birthday': _selectedBirthday,
      'maritalStatus': _selectedMaritalStatus,
      'nationality': _selectedNationality,
      'language': _selectedLanguage,

      // Contact Details
      'mobilePhone': _mobilePhoneController.text,
      'homeNumber': _homeNumberController.text,
      'personalEmail': _personalEmailController.text,
      'officeNumber': _officeNumberController.text,
      'extension': _extensionController.text,
      'businessEmail': _businessEmailController.text,

      // Address Details
      'country': _countryController.text,
      'province': _provinceController.text,
      'city': _cityController.text,
      'street': _streetController.text,
      'postalCode': _postalCodeController.text,

      // Identification Details
      'nationalId': _nationalIdController.text,
      'nationalIdExpiration': _selectedNationalIdExpiration,
      'passport': _passportController.text,
      'passportExpiration': _selectedPassportExpiration,
      'drivingLicenseId': _drivingLicenseController.text,
      'carPlate': _carPlateController.text,

      // Position Details
      'jobTitle': _jobTitleController.text,
      'department': _selectedDepartment,
      'jobType': _selectedJobType,
      'workArrangement': _selectedWorkArrangement,
      'remoteStatus': _selectedRemoteStatus,
      'jobLocation': _selectedJobLocation,
      'startDate': _selectedStartDate,
      'workingHours': _workingHoursController.text,
      'daysOff': _selectedDaysOff,
      'salary': _salaryController.text,
      'currency': _selectedCurrency,

      // Certification Details
      'institutionName': _institutionNameController.text,
      'degreeOrCertification': _selectedDegreeOrCertification,
      'fieldOfStudy': _selectedFieldOfStudy,
      'certStartDate': _selectedCertStartDate,
      'certEndDate': _selectedCertEndDate,
      'gradeOrScore': _gradeOrScoreController.text,
      'certificateId': _certificateIdController.text,
      'issuingAuthority': _selectedIssuingAuthority,
      'notes': _notesController.text,

      // Insurance Details
      'insuranceName': _insuranceNameController.text,
      'insurancePolicyNumber': _insurancePolicyNumberController.text,
      'insuranceProviderContact': _insuranceProviderContactController.text,

      // Emergency Details - First Contact
      'firstContactFirstName': _emergencyFirstNameController.text,
      'firstContactMiddleName': _emergencyMiddleNameController.text,
      'firstContactLastName': _emergencyLastNameController.text,
      'firstContactRelationship': _selectedEmergencyRelationship,
      'firstContactEmail': _emergencyEmailController.text,
      'firstContactMobilePhone': _emergencyMobilePhoneController.text,
      'firstContactCountry': _emergencyCountryController.text,
      'firstContactProvince': _emergencyProvinceController.text,
      'firstContactLanguage': _selectedEmergencyLanguage,

      // Emergency Details - Second Contact
      'secondContactFirstName': _emergencySecondFirstNameController.text,
      'secondContactMiddleName': _emergencySecondMiddleNameController.text,
      'secondContactLastName': _emergencySecondLastNameController.text,
      'secondContactRelationship': _selectedEmergencySecondRelationship,
      'secondContactEmail': _emergencySecondEmailController.text,
      'secondContactMobilePhone': _emergencySecondMobilePhoneController.text,
      'secondContactCountry': _emergencySecondCountryController.text,
      'secondContactProvince': _emergencySecondProvinceController.text,
      'secondContactLanguage': _selectedEmergencySecondLanguage,
    };
  }


  // ⚠️ VALIDATION FUNCTIONS
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value)) {
      return 'Only letters are allowed';
    }
    return null;
  }

  String?   _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{8,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateOptionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{8,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    if (!RegExp(r'^[0-9]{4,10}$').hasMatch(value.trim())) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'National ID is required';
    }
    if (value.trim().length < 8) {
      return 'National ID must be at least 8 characters';
    }
    return null;
  }

  String? _validatePassport(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passport is required';
    }
    if (value.trim().length < 6) {
      return 'Passport must be at least 6 characters';
    }
    return null;
  }

  String? _validateDrivingLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 5) {
      return 'Driving License must be at least 5 characters';
    }
    return null;
  }

  String? _validateCarPlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 3) {
      return 'Car Plate must be at least 3 characters';
    }
    return null;
  }

  String? _validateJobTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Job title is required';
    }
    if (value.trim().length < 3) {
      return 'Job title must be at least 3 characters';
    }
    return null;
  }

  String? _validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Salary is required';
    }
    final number = double.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Enter a valid salary';
    }
    return null;
  }

  String? _validateExtension(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (!RegExp(r'^[0-9]{1,5}$').hasMatch(value.trim())) {
      return 'Enter a valid extension';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 3) {
      return 'Must be at least 3 characters';
    }
    return null;
  }

  String? _validateInstitutionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Institution name is required';
    }
    if (value.trim().length < 3) {
      return 'Must be at least 3 characters';
    }
    return null;
  }

  String? _validateCertificateId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 3) {
      return 'Must be at least 3 characters';
    }
    return null;
  }

  String? _validateGradeOrScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    return null;
  }

  String? _validateInsuranceName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 3) {
      return 'Must be at least 3 characters';
    }
    return null;
  }

  String? _validateInsurancePolicy(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    if (value.trim().length < 5) {
      return 'Must be at least 5 characters';
    }
    return null;
  }

  String? _validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }



  Future<Map<String, dynamic>?> _showImagePickerDialog(BuildContext context) async {
    XFile? selectedImage;

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: Text('Upload Image'.tr, style: TextStyle(color: AppColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.text),
                title: Text('Gallery'.tr, style: TextStyle(color: AppColors.text)),
                onTap: () {
                  Navigator.pop(context, 'gallery');
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.text),
                title: Text('Camera'.tr, style: TextStyle(color: AppColors.text)),
                onTap: () {
                  Navigator.pop(context, 'camera');
                },
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      final ImagePicker picker = ImagePicker();

      if (result == 'gallery') {
        selectedImage = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      } else if (result == 'camera') {
        selectedImage = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
      }
    }

    if (selectedImage != null) {
      final file = File(selectedImage.path);
      final fileName = selectedImage.name;
      final fileSize = await file.length();
      final fileDate = DateTime.now();

      return {
        'file': file,
        'name': fileName,
        'size': fileSize,
        'date': fileDate,
      };
    }

    return null;
  }

  Widget _buildUploadedFileContainer({
    required String fileName,
    required int fileSize,
    required DateTime fileDate,
    required VoidCallback onRemove,
  }) {
    final sizeInKB = (fileSize / 1024).round();
    final formattedDate = '${fileDate.day} ${_getMonthName(fileDate.month)} ${fileDate.year}';

    return Container(
      height: 60.h,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Image icon
          Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              color: AppColors.secondaryText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: SvgPicture.asset(
              'assets/hrAsset/hrimage.svg',
              width: 24.sp,
              height: 24.sp,
              color: AppColors.secondaryText,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(width: 12.w),
          // File details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.font14BlackCairoMedium.copyWith(color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '$sizeInKB KB',
                  style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Date
          Text(
            'Date: $formattedDate',
            style: AppTextStyles.font12BlackCairoRegular.copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(width: 12.w),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 15.sp,
              height: 15.sp,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      body: SideFrameMaster(
        titleText: "HR",
        onFirstTap:  (){
          Navigator.pop(context);
        },
        secondTitle: "Employees",
        onSecondTap:  (){
          Navigator.pop(context);
        },
        thirdTitle: "Adding New Employee",
        onThirdTap:  (){
          Navigator.pop(context);
        },
        child: Column(
          children: [
            // Tabs Row
            _buildTabsRow(isMobile, isTablet),
            SizedBox(height: 20.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _buildCurrentStepContent(isMobile, isTablet),
              ),
            ),

            // Bottom Navigation Buttons
            _buildBottomNavigation(isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsRow(bool isMobile, bool isTablet) {
    return Container(
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
                children: List.generate(_tabTitles.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < _tabTitles.length - 1 ? 12.w : 0),
                    child: _buildTab(_tabTitles[index], index, isMobile),
                  );
                }),
              ),
            )
          : Wrap(
              spacing: 7.w,
              runSpacing: 10.h,
              children: List.generate(_tabTitles.length, (index) {
                return _buildTab(_tabTitles[index], index, isMobile);
              }),
            ),
    );
  }

  Widget _buildTab(String title, int index, bool isMobile) {
    final isCurrent = _currentStep == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStep = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: (isMobile
                    ? AppTextStyles.font12BlackMediumCairo
                    : AppTextStyles.font14BlackCairoMedium)
                .copyWith(
              color: isCurrent ? AppColors.text : AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 8.h,
            width: isMobile ? 100.w : 105.w,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(64.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent(bool isMobile, bool isTablet) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInformation(isMobile, isTablet);
      case 1:
        return _buildContactDetails(isMobile, isTablet);
      case 2:
        return _buildAddressDetails(isMobile, isTablet);
      case 3:
        return _buildIdentificationDetails(isMobile, isTablet);
      case 4:
        return _buildPositionDetails(isMobile, isTablet);
      case 5:
        return _buildCertificationDetails(isMobile, isTablet);
      case 6:
        return _buildInsuranceDetails(isMobile, isTablet);
      case 7:
        return _buildEmergencyDetails(isMobile, isTablet);
      default:
        return Container();
    }
  }

  // Step 1: Personal Information
  Widget _buildPersonalInformation(bool isMobile, bool isTablet) {

    return Column(
      children: [
        // Profile Image Upload

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                // Show dialog to choose upload option
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppColors.background,
                      title: Text('Upload Image'.tr,style: TextStyle(color: AppColors.text),),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.photo_library,color: AppColors.text,),
                            title: Text('Gallery'.tr,style: TextStyle(color: AppColors.text),),
                            onTap: () async {
                              Navigator.pop(context);
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );

                              if (image != null) {
                                setState(() {
                                  _profileImage = File(image.path);
                                });
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.camera_alt,color: AppColors.text,),
                            title: Text('camera'.tr,style: TextStyle(color: AppColors.text),),
                            onTap: () async {
                              Navigator.pop(context);
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );

                              if (image != null) {
                                setState(() {
                                  _profileImage = File(image.path);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 60.sp,
                    height: 60.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryText.withOpacity(0.5),
                      image: _profileImage != null
                          ? DecorationImage(
                        image: FileImage(_profileImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _profileImage == null
                        ? SvgPicture.asset(
                      'assets/hrAsset/Gallery.svg',
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.card,
                      fit: BoxFit.scaleDown,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24.sp,
                      height: 24.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: SvgPicture.asset(
                        'assets/hrAsset/Camera.svg',
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.textButton,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Name Fields
        if (isMobile) ...[
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'First Name',
            hint: 'Text Here',
            validator: _validateName,
            controller: _firstNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            label: 'Middle Name',
            validator : _validateName,
            hint: 'Text Here',
            controller: _middleNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            label: 'Last Name',
            hint: 'Text Here',
            validator : _validateName,
            controller: _lastNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'First Name',
                  hint: 'Text Here',
                  validator : _validateName,
                  controller: _firstNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Middle Name',
                  hint: 'Text Here',
                  validator : _validateName,
                  controller: _middleNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Last Name',
                  validator : _validateName,
                  hint: 'Text Here',
                  controller: _lastNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 16.h),

        // Gender, Birthday, Marital Status
        if (isMobile) ...[
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Gender',
            selectedValue: _selectedGender,
            items: const [
              {'key': 'male', 'value': 'Male'},
              {'key': 'female', 'value': 'Female'},
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Gender';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select', style: AppTextStyles.font12BlackCairoRegular),
            height: 36,
          ),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'Birthday',
            selectedValue: _selectedBirthday,
            onChanged: (value) => setState(() => _selectedBirthday = value),
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Marital Status',
            selectedValue: _selectedMaritalStatus,
            items: const [
              {'key': 'married', 'value': 'Married'},
              {'key': 'single', 'value': 'Single'},
              {'key': 'divorced', 'value': 'Divorced'},
              {'key': 'widowed', 'value': 'Widowed'},
            ],
            onChanged: (value) =>
                setState(() => _selectedMaritalStatus = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Marital Status';
              }
              return '';
            },
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
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Gender',
                  selectedValue: _selectedGender,
                  items: const [
                    {'key': 'male', 'value': 'Male'},
                    {'key': 'female', 'value': 'Female'},
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Gender';
                    }
                    return '';
                  },
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
                child: CustomDropdownFormFieldCalender(
                  dropdownColor: AppColors.card,
                  label: 'Birthday',
                  selectedValue: _selectedBirthday,
                  onChanged: (value) =>
                      setState(() => _selectedBirthday = value),
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
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Marital Status',
                  selectedValue: _selectedMaritalStatus,
                  items: const [
                    {'key': 'married', 'value': 'Married'},
                    {'key': 'single', 'value': 'Single'},
                    {'key': 'divorced', 'value': 'Divorced'},
                    {'key': 'widowed', 'value': 'Widowed'},
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedMaritalStatus = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Marital Status';
                    }
                    return '';
                  },
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
        SizedBox(height: 16.h),

        // Nationality and Languages
        if (isMobile) ...[
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Nationality',
            selectedValue: _selectedNationality,
            items: const [
              {'key': 'eg', 'value': 'Egyptian'},
              {'key': 'sa', 'value': 'Saudi'},
            ],
            onChanged: (value) => setState(() => _selectedNationality = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Nationality';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Language',
            selectedValue: _selectedLanguage,
            items: const [
              {'key': 'arabic', 'value': 'Arabic'},
              {'key': 'english', 'value': 'English'},
              {'key': 'indian', 'value': 'Indian'},
              {'key': 'german', 'value': 'German'},
            ],
            onChanged: (value) => setState(() => _selectedLanguage = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Language';
              }
              return '';
            },
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
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Nationality',
                  selectedValue: _selectedNationality,
                  items: const [
                    {'key': 'eg', 'value': 'Egyptian'},
                    {'key': 'sa', 'value': 'Saudi'},
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedNationality = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Nationality';
                    }
                    return '';
                  },
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
                  dropdownColor: AppColors.card,
                  label: 'Language',
                  selectedValue: _selectedLanguage,
                  items: const [
                    {'key': 'arabic', 'value': 'Arabic'},
                    {'key': 'english', 'value': 'English'},
                    {'key': 'indian', 'value': 'Indian'},
                    {'key': 'german', 'value': 'German'},
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedLanguage = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Language';
                    }
                    return '';
                  },
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
    );
  }

  // Step 2: Contact Details
  Widget _buildContactDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Mobile Phone',
            hint: 'Text Here',
            validator : _validatePhone,
            controller: _mobilePhoneController,
            keyboardType: TextInputType.phone,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Home Number',
            validator: _validateOptionalPhone,
            hint: 'Text Here',
            controller: _homeNumberController,
            keyboardType: TextInputType.phone,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Personal Email',
            validator: _validateEmail,
            hint: 'Text Here',
            controller: _personalEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Office Number',
            validator: _validateOptionalPhone,
            hint: 'Text Here',
            controller: _officeNumberController,
            keyboardType: TextInputType.phone,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Extension',
            validator: _validateExtension,
            hint: 'Text Here',
            controller: _extensionController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Business Email',
            hint: 'Text Here',
            validator: _validateEmail,
            controller: _businessEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Mobile Phone',
                hint: 'Text Here',
                validator: _validatePhone,
                controller: _mobilePhoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Home Number',
                validator: _validateOptionalPhone,
                hint: 'Text Here',
                controller: _homeNumberController,
                keyboardType: TextInputType.phone,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Personal Email',
                hint: 'Text Here',
                validator: _validateOptionalEmail,
                controller: _personalEmailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Office Number',
                validator: _validateOptionalPhone,
                hint: 'Text Here',
                controller: _officeNumberController,
                keyboardType: TextInputType.phone,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Extension',
                validator: _validateExtension,
                hint: 'Text Here',
                controller: _extensionController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Business Email',
                validator: _validateEmail,
                hint: 'Text Here',
                controller: _businessEmailController,
                onChanged: (_){
                  setState(() {

                  });
                },
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }

// Step 3: Address Details
  Widget _buildAddressDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Country',
            validator: _validateAddress,
            hint: 'Text Here',
            controller: _countryController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Province',
            validator: _validateAddress,
            hint: 'Text Here',
            controller: _provinceController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'City',
            hint: 'Text Here',
            controller: _cityController,
            validator: _validateAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Street',
            hint: 'Text Here',
            controller: _streetController,
            validator: _validateAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Postal Code',
            hint: 'Text Here',
            controller: _postalCodeController,
            keyboardType: TextInputType.number,
            validator: _validatePostalCode,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Country',
                hint: 'Text Here',
                controller: _countryController,
                validator: _validateAddress,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Province',
                hint: 'Text Here',
                controller: _provinceController,
                validator: _validateAddress,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'City',
                hint: 'Text Here',
                controller: _cityController,
                validator: _validateAddress,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Street',
                hint: 'Text Here',
                controller: _streetController,
                validator: _validateAddress,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Postal Code',
                hint: 'Text Here',
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                validator: _validatePostalCode,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

// Step 4: Identification Details
  Widget _buildIdentificationDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'National ID',
            hint: 'Text Here',
            controller: _nationalIdController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'National ID Expiration',
            selectedValue: _selectedNationalIdExpiration,
            onChanged: (value) => setState(() => _selectedNationalIdExpiration = value),
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Passport',
            validator: _validatePassport,
            hint: 'Text Here',
            controller: _passportController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'Passport Expiration',
            selectedValue: _selectedPassportExpiration,
            onChanged: (value) => setState(() => _selectedPassportExpiration = value),
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Driving License ID',
            validator: _validateDrivingLicense,
            hint: 'Text Here',
            controller: _drivingLicenseController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Car Plate',
            validator: _validateCarPlate,
            hint: 'Text Here',
            controller: _carPlateController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Passport',
                  style: AppTextStyles.font14BlackCairoRegular
                      .copyWith(color: AppColors.text)),
              SizedBox(height: 8.h),
              _passportImage == null
                  ? customButtonWithImage(
                title: 'Upload',
                function: () async {
                  final imageData = await _showImagePickerDialog(context);
                  if (imageData != null) {
                    setState(() {
                      _passportImage = imageData['file'];
                      _passportImageName = imageData['name'];
                      _passportImageSize = imageData['size'];
                      _passportImageDate = imageData['date'];
                    });
                  }
                },
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
              )
                  : _buildUploadedFileContainer(
                fileName: _passportImageName!,
                fileSize: _passportImageSize!,
                fileDate: _passportImageDate!,
                onRemove: () {
                  setState(() {
                    _passportImage = null;
                    _passportImageName = null;
                    _passportImageSize = null;
                    _passportImageDate = null;
                  });
                },
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
              _nationalIdImage == null
                  ? customButtonWithImage(
                title: 'Upload',
                function: () async {
                  final imageData = await _showImagePickerDialog(context);
                  if (imageData != null) {
                    setState(() {
                      _nationalIdImage = imageData['file'];
                      _nationalIdImageName = imageData['name'];
                      _nationalIdImageSize = imageData['size'];
                      _nationalIdImageDate = imageData['date'];
                    });
                  }
                },
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
              )
                  : _buildUploadedFileContainer(
                fileName: _nationalIdImageName!,
                fileSize: _nationalIdImageSize!,
                fileDate: _nationalIdImageDate!,
                onRemove: () {
                  setState(() {
                    _nationalIdImage = null;
                    _nationalIdImageName = null;
                    _nationalIdImageSize = null;
                    _nationalIdImageDate = null;
                  });
                },
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
              _drivingLicenseImage == null
                  ? customButtonWithImage(
                title: 'Upload',
                function: () async {
                  final imageData = await _showImagePickerDialog(context);
                  if (imageData != null) {
                    setState(() {
                      _drivingLicenseImage = imageData['file'];
                      _drivingLicenseImageName = imageData['name'];
                      _drivingLicenseImageSize = imageData['size'];
                      _drivingLicenseImageDate = imageData['date'];
                    });
                  }
                },
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
              )
                  : _buildUploadedFileContainer(
                fileName: _drivingLicenseImageName!,
                fileSize: _drivingLicenseImageSize!,
                fileDate: _drivingLicenseImageDate!,
                onRemove: () {
                  setState(() {
                    _drivingLicenseImage = null;
                    _drivingLicenseImageName = null;
                    _drivingLicenseImageSize = null;
                    _drivingLicenseImageDate = null;
                  });
                },
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'National ID',
                validator: _validatePassport,
                hint: 'Text Here',
                controller: _nationalIdController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomDropdownFormFieldCalender(
                dropdownColor: AppColors.card,
                label: 'National ID Expiration',
                selectedValue: _selectedNationalIdExpiration,
                onChanged: (value) => setState(() => _selectedNationalIdExpiration = value),
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
                fillColor: AppColors.card,
                label: 'Passport',
                validator: _validatePassport,
                hint: 'Text Here',
                controller: _passportController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomDropdownFormFieldCalender(
                dropdownColor: AppColors.card,
                label: 'Passport Expiration',
                selectedValue: _selectedPassportExpiration,
                onChanged: (value) => setState(() => _selectedPassportExpiration = value),
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
                fillColor: AppColors.card,
                label: 'Driving License ID',
                hint: 'Text Here',
                controller: _drivingLicenseController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Car Plate',
                validator: _validateCarPlate,
                hint: 'Text Here',
                controller: _carPlateController,
                onChanged: (_){
                  setState(() {

                  });
                },
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
                  _passportImage == null
                      ? customButtonWithImage(
                    title: 'Upload',
                    function: () async {
                      final imageData = await _showImagePickerDialog(context);
                      if (imageData != null) {
                        setState(() {
                          _passportImage = imageData['file'];
                          _passportImageName = imageData['name'];
                          _passportImageSize = imageData['size'];
                          _passportImageDate = imageData['date'];
                        });
                      }
                    },
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
                  )
                      : _buildUploadedFileContainer(
                    fileName: _passportImageName!,
                    fileSize: _passportImageSize!,
                    fileDate: _passportImageDate!,
                    onRemove: () {
                      setState(() {
                        _passportImage = null;
                        _passportImageName = null;
                        _passportImageSize = null;
                        _passportImageDate = null;
                      });
                    },
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
                  _nationalIdImage == null
                      ? customButtonWithImage(
                    title: 'Upload',
                    function: () async {
                      final imageData = await _showImagePickerDialog(context);
                      if (imageData != null) {
                        setState(() {
                          _nationalIdImage = imageData['file'];
                          _nationalIdImageName = imageData['name'];
                          _nationalIdImageSize = imageData['size'];
                          _nationalIdImageDate = imageData['date'];
                        });
                      }
                    },
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
                  )
                      : _buildUploadedFileContainer(
                    fileName: _nationalIdImageName!,
                    fileSize: _nationalIdImageSize!,
                    fileDate: _nationalIdImageDate!,
                    onRemove: () {
                      setState(() {
                        _nationalIdImage = null;
                        _nationalIdImageName = null;
                        _nationalIdImageSize = null;
                        _nationalIdImageDate = null;
                      });
                    },
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
                  _drivingLicenseImage == null
                      ? customButtonWithImage(
                    title: 'Upload',
                    function: () async {
                      final imageData = await _showImagePickerDialog(context);
                      if (imageData != null) {
                        setState(() {
                          _drivingLicenseImage = imageData['file'];
                          _drivingLicenseImageName = imageData['name'];
                          _drivingLicenseImageSize = imageData['size'];
                          _drivingLicenseImageDate = imageData['date'];
                        });
                      }
                    },
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
                  )
                      : _buildUploadedFileContainer(
                    fileName: _drivingLicenseImageName!,
                    fileSize: _drivingLicenseImageSize!,
                    fileDate: _drivingLicenseImageDate!,
                    onRemove: () {
                      setState(() {
                        _drivingLicenseImage = null;
                        _drivingLicenseImageName = null;
                        _drivingLicenseImageSize = null;
                        _drivingLicenseImageDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

// Step 5: Position Details
  Widget _buildPositionDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Job Title',
            hint: 'Text Here',
            validator: _validateJobTitle,
            controller: _jobTitleController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Department',
            selectedValue: _selectedDepartment,
            items: const [
              {'key': 'hr', 'value': 'HR'},
              {'key': 'it', 'value': 'IT'},
              {'key': 'finance', 'value': 'Finance'},
            ],
            onChanged: (value) => setState(() => _selectedDepartment = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Department';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Job Type',
            selectedValue: _selectedJobType,
            items: const [
              {'key': 'full_time', 'value': 'Full Time'},
              {'key': 'part_time', 'value': 'Part Time'},
              {'key': 'contract', 'value': 'Contract'},
            ],
            onChanged: (value) => setState(() => _selectedJobType = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Job Type';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Work Arrangement',
            selectedValue: _selectedWorkArrangement,
            items: const [
              {'key': 'onsite', 'value': 'Onsite'},
              {'key': 'remote', 'value': 'Remote'},
              {'key': 'hybrid', 'value': 'Hybrid'},
            ],
            onChanged: (value) => setState(() => _selectedWorkArrangement = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Work Arrangement';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Remote Status',
            selectedValue: _selectedRemoteStatus,
            items: const [
              {'key': 'fully_remote', 'value': 'Fully Remote'},
              {'key': 'partially_remote', 'value': 'Partially Remote'},
              {'key': 'not_remote', 'value': 'Not Remote'},
            ],
            onChanged: (value) => setState(() => _selectedRemoteStatus = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Remote Status';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Job Location',
            selectedValue: _selectedJobLocation,
            items: const [
              {'key': 'cairo', 'value': 'Cairo'},
              {'key': 'alex', 'value': 'Alexandria'},
              {'key': 'giza', 'value': 'Giza'},
            ],
            onChanged: (value) => setState(() => _selectedJobLocation = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Job Location';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'Start Date',
            selectedValue: _selectedStartDate,
            onChanged: (value) => setState(() => _selectedStartDate = value),
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
                fillColor: AppColors.card,
                hint: 'Select Time',
                controller: _workingHoursController,
                label: '',
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Days Off',
            selectedValue: _selectedDaysOff,
            items: const [
              {'key': 'friday', 'value': 'Friday'},
              {'key': 'saturday', 'value': 'Saturday'},
              {'key': 'sunday', 'value': 'Sunday'},
            ],
            onChanged: (value) => setState(() => _selectedDaysOff = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Days Off';
              }
              return '';
            },
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
                  fillColor: AppColors.card,
                  label: 'Salary',
                  validator: _validateSalary,
                  hint: 'Text Here',
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Currency',
                  selectedValue: _selectedCurrency,
                  items: const [
                    {'key': 'egp', 'value': 'EGP'},
                    {'key': 'usd', 'value': 'USD'},
                    {'key': 'eur', 'value': 'EUR'},
                  ],
                  onChanged: (value) => setState(() => _selectedCurrency = value),
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
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Job Title',
                validator: _validateJobTitle,
                hint: 'Text Here',
                controller: _jobTitleController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                label: 'Department',
                selectedValue: _selectedDepartment,
                items: const [
                  {'key': 'hr', 'value': 'HR'},
                  {'key': 'it', 'value': 'IT'},
                  {'key': 'finance', 'value': 'Finance'},
                ],
                onChanged: (value) => setState(() => _selectedDepartment = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Department';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Job Type',
                selectedValue: _selectedJobType,
                items: const [
                  {'key': 'full_time', 'value': 'Full Time'},
                  {'key': 'part_time', 'value': 'Part Time'},
                  {'key': 'contract', 'value': 'Contract'},
                ],
                onChanged: (value) => setState(() => _selectedJobType = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Job Type';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Work Arrangement',
                selectedValue: _selectedWorkArrangement,
                items: const [
                  {'key': 'onsite', 'value': 'Onsite'},
                  {'key': 'remote', 'value': 'Remote'},
                  {'key': 'hybrid', 'value': 'Hybrid'},
                ],
                onChanged: (value) => setState(() => _selectedWorkArrangement = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Work Arrangement';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Remote Status',
                selectedValue: _selectedRemoteStatus,
                items: const [
                  {'key': 'fully_remote', 'value': 'Fully Remote'},
                  {'key': 'partially_remote', 'value': 'Partially Remote'},
                  {'key': 'not_remote', 'value': 'Not Remote'},
                ],
                onChanged: (value) => setState(() => _selectedRemoteStatus = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Remote Status';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Job Location',
                selectedValue: _selectedJobLocation,
                items: const [
                  {'key': 'cairo', 'value': 'Cairo'},
                  {'key': 'alex', 'value': 'Alexandria'},
                  {'key': 'giza', 'value': 'Giza'},
                ],
                onChanged: (value) => setState(() => _selectedJobLocation = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Job Location';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Start Date',
                selectedValue: _selectedStartDate,
                onChanged: (value) => setState(() => _selectedStartDate = value),
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
                    fillColor: AppColors.card,
                    hint: 'Select Time',
                    controller: _workingHoursController,
                    label: 'Working Hours',
                    height: 40,
                    onChanged: (_){
                      setState(() {

                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                label: 'Days Off',
                selectedValue: _selectedDaysOff,
                items: const [
                  {'key': 'friday', 'value': 'Friday'},
                  {'key': 'saturday', 'value': 'Saturday'},
                  {'key': 'sunday', 'value': 'Sunday'},
                ],
                onChanged: (value) => setState(() => _selectedDaysOff = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Days Off';
                  }
                  return '';
                },
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
                fillColor: AppColors.card,
                label: 'Salary',
                validator: _validateSalary,
                hint: 'Text Here',
                controller: _salaryController,
                keyboardType: TextInputType.number,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                label: 'Currency',
                selectedValue: _selectedCurrency,
                items: const [
                  {'key': 'egp', 'value': 'EGP'},
                  {'key': 'usd', 'value': 'USD'},
                  {'key': 'eur', 'value': 'EUR'},
                ],
                onChanged: (value) => setState(() => _selectedCurrency = value),
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
    );
  }

// Step 6: Certification Details
  Widget _buildCertificationDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Institution Name',
            validator: _validateInstitutionName,

            hint: 'Text Here',
            controller: _institutionNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Degree Or Certification',
            selectedValue: _selectedDegreeOrCertification,
            items: const [
              {'key': 'bachelor', 'value': 'Bachelor'},
              {'key': 'master', 'value': 'Master'},
              {'key': 'phd', 'value': 'PhD'},
              {'key': 'diploma', 'value': 'Diploma'},
            ],
            onChanged: (value) => setState(() => _selectedDegreeOrCertification = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Degree Or Certification';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Field of Study',
            selectedValue: _selectedFieldOfStudy,
            items: const [
              {'key': 'cs', 'value': 'Computer Science'},
              {'key': 'engineering', 'value': 'Engineering'},
              {'key': 'business', 'value': 'Business'},
            ],
            onChanged: (value) => setState(() => _selectedFieldOfStudy = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Field of Study';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'Start Date',
            selectedValue: _selectedCertStartDate,
            onChanged: (value) => setState(() => _selectedCertStartDate = value),
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormFieldCalender(
            dropdownColor: AppColors.card,
            label: 'End Date',
            selectedValue: _selectedCertEndDate,
            onChanged: (value) => setState(() => _selectedCertEndDate = value),
            widthIcon: 12.w,
            heightIcon: 12.h,
            hint: Text('Select Date',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Grade Or Score',
            validator: _validateGradeOrScore,
            hint: 'Text Here',
            controller: _gradeOrScoreController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Certificate ID',
            validator: _validateCertificateId,
            hint: 'Text Here',
            controller: _certificateIdController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Issuing Authority',

            selectedValue: _selectedIssuingAuthority,
            items: const [
              {'key': 'university', 'value': 'University'},
              {'key': 'institution', 'value': 'Institution'},
            ],
            onChanged: (value) => setState(() => _selectedIssuingAuthority = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Issuing Authority';
              }
              return '';
            },
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
                function: () async {
                  final imageData = await _showImagePickerDialog(context);
                  if (imageData != null) {
                    setState(() {
                      _certificationDocImage = imageData['file'];
                      _certificationDocImageName = imageData['name'];
                      _certificationDocImageSize = imageData['size'];
                      _certificationDocImageDate = imageData['date'];
                    });
                  }
                },
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
            fillColor: AppColors.card,
            label: 'Notes',
            hint: 'Text here',
            validator: _validateName,
            height: 72.h,
            controller: _notesController,
            maxLines: 4, onChanged: (_){
            setState(() {

            });
          },

          ),
        ],
      );
    }

    // Tablet/Desktop Layout
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomValidatedTextField(
                fillColor: AppColors.card,
                label: 'Institution Name',
                validator: _validateInstitutionName,
                hint: 'Text Here',
                controller: _institutionNameController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                label: 'Degree Or Certification',
                selectedValue: _selectedDegreeOrCertification,
                items: const [
                  {'key': 'bachelor', 'value': 'Bachelor'},
                  {'key': 'master', 'value': 'Master'},
                  {'key': 'phd', 'value': 'PhD'},
                  {'key': 'diploma', 'value': 'Diploma'},
                ],
                onChanged: (value) => setState(() => _selectedDegreeOrCertification = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Degree Or Certification';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Field of Study',
                selectedValue: _selectedFieldOfStudy,
                items: const [
                  {'key': 'cs', 'value': 'Computer Science'},
                  {'key': 'engineering', 'value': 'Engineering'},
                  {'key': 'business', 'value': 'Business'},
                ],
                onChanged: (value) => setState(() => _selectedFieldOfStudy = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Field of Study';
                  }
                  return '';
                },
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
                dropdownColor: AppColors.card,
                label: 'Start Date',
                selectedValue: _selectedCertStartDate,
                onChanged: (value) => setState(() => _selectedCertStartDate = value),
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
                dropdownColor: AppColors.card,
                label: 'End Date',
                selectedValue: _selectedCertEndDate,
                onChanged: (value) => setState(() => _selectedCertEndDate = value),
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
                fillColor: AppColors.card,
                label: 'Grade Or Score',
                validator: _validateGradeOrScore,
                hint: 'Text Here',
                controller: _gradeOrScoreController,
                onChanged: (_){
                  setState(() {

                  });
                },
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
                fillColor: AppColors.card,
                label: 'Certificate ID',
                validator: _validateCertificateId,
                hint: 'Text Here',
                controller: _certificateIdController,
                onChanged: (_){
                  setState(() {

                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomDropdownFormField(
                dropdownColor: AppColors.card,
                label: 'Issuing Authority',
                selectedValue: _selectedIssuingAuthority,
                items: const [
                  {'key': 'university', 'value': 'University'},
                  {'key': 'institution', 'value': 'Institution'},
                ],
                onChanged: (value) => setState(() => _selectedIssuingAuthority = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Issuing Authority';
                  }
                  return '';
                },
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
            _certificationDocImage == null
                ? customButtonWithImage(
              title: 'Upload',
              function: () async {
                final imageData = await _showImagePickerDialog(context);
                if (imageData != null) {
                  setState(() {
                    _certificationDocImage = imageData['file'];
                    _certificationDocImageName = imageData['name'];
                    _certificationDocImageSize = imageData['size'];
                    _certificationDocImageDate = imageData['date'];
                  });
                }
              },
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
            )
                : SizedBox(
              width: 400.w,
              child: _buildUploadedFileContainer(
                fileName: _certificationDocImageName!,
                fileSize: _certificationDocImageSize!,
                fileDate: _certificationDocImageDate!,
                onRemove: () {
                  setState(() {
                    _certificationDocImage = null;
                    _certificationDocImageName = null;
                    _certificationDocImageSize = null;
                    _certificationDocImageDate = null;
                  });
                },
              ),
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
          fillColor: AppColors.card,
          label: 'Notes',
          hint: 'Text here',
          validator: _validateName,
          height: 72.h,
          controller: _notesController,
          onChanged: (_){
            setState(() {

            });
          },
          maxLines: 4,
        ),
      ],
    );
  }

// Step 7: Insurance Details
  Widget _buildInsuranceDetails(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Insurance Name',
            validator: _validateInstitutionName,
            hint: 'Text Here',
            controller: _insuranceNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            validator: _validateInsurancePolicy,
            label: 'Insurance Policy Number',
            onChanged: (_){
              setState(() {

              });
            },
            hint: 'Text Here',
            controller: _insurancePolicyNumberController,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            validator: _validateName,
            label: 'Insurance Provider Contact',
            hint: 'Text Here',
            controller: _insuranceProviderContactController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Insurance Name',
            validator: _validateInsuranceName,
            hint: 'Text Here',
            controller: _insuranceNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Insurance Policy Number',
            validator: _validateInsurancePolicy,
            hint: 'Text Here',
            controller: _insurancePolicyNumberController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Insurance Provider Contact',
            hint: 'Text Here',
            controller: _insuranceProviderContactController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
        ),
      ],
    );
  }

// Step 8: Emergency Details
  Widget _buildEmergencyDetails(bool isMobile, bool isTablet) {
    return Column(
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
            fillColor: AppColors.card,
            label: 'First Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencyFirstNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Middle Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencyMiddleNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Last Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencyLastNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Relationship',
            selectedValue: _selectedEmergencyRelationship,
            items: const [
              {'key': 'spouse', 'value': 'Spouse'},
              {'key': 'parent', 'value': 'Parent'},
              {'key': 'sibling', 'value': 'Sibling'},
              {'key': 'friend', 'value': 'Friend'},
            ],
            onChanged: (value) => setState(() => _selectedEmergencyRelationship = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Relationship';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Email',
            hint: 'Text Here',
            validator: _validateEmail,
            controller: _emergencyEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Mobile Phone',
            validator: _validatePhone,
            hint: 'Text Here',
            controller: _emergencyMobilePhoneController,
            keyboardType: TextInputType.phone,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Country',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencyCountryController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Province',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencyProvinceController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Language',
            selectedValue: _selectedEmergencyLanguage,
            items: const [
              {'key': 'arabic', 'value': 'Arabic'},
              {'key': 'english', 'value': 'English'},
              {'key': 'indian', 'value': 'Indian'},
              {'key': 'german', 'value': 'German'},
            ],
            onChanged: (value) => setState(() => _selectedEmergencyLanguage = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Language';
              }
              return '';
            },
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
                  fillColor: AppColors.card,
                  label: 'First Name',
                  validator: _validateName,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                  hint: 'Text Here',
                  controller: _emergencyFirstNameController,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Middle Name',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencyMiddleNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Last Name',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencyLastNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
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
                  dropdownColor: AppColors.card,
                  label: 'Relationship',
                  selectedValue: _selectedEmergencyRelationship,
                  items: const [
                    {'key': 'spouse', 'value': 'Spouse'},
                    {'key': 'parent', 'value': 'Parent'},
                    {'key': 'sibling', 'value': 'Sibling'},
                    {'key': 'friend', 'value': 'Friend'},
                  ],
                  onChanged: (value) => setState(() => _selectedEmergencyRelationship = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Relationship';
                    }
                    return '';
                  },
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
                  fillColor: AppColors.card,
                  label: 'Email',
                  validator: _validateEmail,
                  hint: 'Text Here',
                  controller: _emergencyEmailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Mobile Phone',
                  validator: _validatePhone,
                  hint: 'Text Here',
                  controller: _emergencyMobilePhoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_){
                    setState(() {

                    });
                  },
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
                  fillColor: AppColors.card,
                  label: 'Country',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencyCountryController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Province',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencyProvinceController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Language',
                  selectedValue: _selectedEmergencyLanguage,
                  items: const [
                    {'key': 'arabic', 'value': 'Arabic'},
                    {'key': 'english', 'value': 'English'},
                    {'key': 'indian', 'value': 'Indian'},
                    {'key': 'german', 'value': 'German'},
                  ],
                  onChanged: (value) => setState(() => _selectedEmergencyLanguage = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Language';
                    }
                    return '';
                  },
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
            fillColor: AppColors.card,
            label: 'First Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencySecondFirstNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Middle Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencySecondMiddleNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Last Name',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencySecondLastNameController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Relationship',
            selectedValue: _selectedEmergencySecondRelationship,
            items: const [
              {'key': 'spouse', 'value': 'Spouse'},
              {'key': 'parent', 'value': 'Parent'},
              {'key': 'sibling', 'value': 'Sibling'},
              {'key': 'friend', 'value': 'Friend'},
            ],
            onChanged: (value) => setState(() => _selectedEmergencySecondRelationship = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Relationship';
              }
              return '';
            },
            widthIcon: 12,
            heightIcon: 12,
            hint: Text('Select',
                style: AppTextStyles.font12BlackCairoRegular
                    .copyWith(color: AppColors.secondaryText)),
            height: 36,
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Email',
            validator: _validateEmail,
            hint: 'Text Here',
            controller: _emergencySecondEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Mobile Phone',
            validator: _validatePhone,
            hint: 'Text Here',
            controller: _emergencySecondMobilePhoneController,
            keyboardType: TextInputType.phone,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Country',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencySecondCountryController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomValidatedTextField(
            fillColor: AppColors.card,
            label: 'Province',
            validator: _validateName,
            hint: 'Text Here',
            controller: _emergencySecondProvinceController,
            onChanged: (_){
              setState(() {

              });
            },
          ),
          SizedBox(height: 16.h),
          CustomDropdownFormField(
            dropdownColor: AppColors.card,
            label: 'Language',
            selectedValue: _selectedEmergencySecondLanguage,
            items: const [
              {'key': 'arabic', 'value': 'Arabic'},
              {'key': 'english', 'value': 'English'},
              {'key': 'indian', 'value': 'Indian'},
              {'key': 'german', 'value': 'German'},
            ],
            onChanged: (value) => setState(() => _selectedEmergencySecondLanguage = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select Language';
              }
              return '';
            },
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
                  fillColor: AppColors.card,
                  label: 'First Name',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencySecondFirstNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Middle Name',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencySecondMiddleNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Last Name',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencySecondLastNameController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
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
                  dropdownColor: AppColors.card,
                  label: 'Relationship',
                  selectedValue: _selectedEmergencySecondRelationship,
                  items: const [
                    {'key': 'spouse', 'value': 'Spouse'},
                    {'key': 'parent', 'value': 'Parent'},
                    {'key': 'sibling', 'value': 'Sibling'},
                    {'key': 'friend', 'value': 'Friend'},
                  ],
                  onChanged: (value) => setState(() => _selectedEmergencySecondRelationship = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Relationship';
                    }
                    return '';
                  },
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
                  fillColor: AppColors.card,
                  label: 'Email',
                  validator: _validateEmail,
                  hint: 'Text Here',
                  controller: _emergencySecondEmailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Mobile Phone',
                  validator: _validatePhone,
                  hint: 'Text Here',
                  controller: _emergencySecondMobilePhoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_){
                    setState(() {

                    });
                  },
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
                  fillColor: AppColors.card,
                  label: 'Country',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencySecondCountryController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomValidatedTextField(
                  fillColor: AppColors.card,
                  label: 'Province',
                  validator: _validateName,
                  hint: 'Text Here',
                  controller: _emergencySecondProvinceController,
                  onChanged: (_){
                    setState(() {

                    });
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomDropdownFormField(
                  dropdownColor: AppColors.card,
                  label: 'Language',
                  selectedValue: _selectedEmergencySecondLanguage,
                  items: const [
                    {'key': 'arabic', 'value': 'Arabic'},
                    {'key': 'english', 'value': 'English'},
                    {'key': 'indian', 'value': 'Indian'},
                    {'key': 'german', 'value': 'German'},
                  ],
                  onChanged: (value) => setState(() => _selectedEmergencySecondLanguage = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Language';
                    }
                    return '';
                  },
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
    );
  }


  Widget _buildBottomNavigation(bool isMobile, bool isTablet) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final buttonWidth = isMobile ? 135.w : 150.w;
    final buttonHeight = 38.h;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            customButton(
              context: context,
              title: 'Back',
              function: () {
                setState(() {
                  _currentStep--;
                });
              },
              width: buttonWidth,
              height: buttonHeight,
              radius: 8.r,
              color: lightMode ? Colors.grey[400] : Colors.grey[700],
              textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: lightMode ? Colors.black : Colors.white,
              ),
            )
          else
            customButton(
              context: context,
              title: 'Discard',
              function: () {
                Navigator.pop(context);
              },
              width: buttonWidth,
              height: buttonHeight,
              radius: 8.r,
              color: lightMode ? Colors.grey[400] : Colors.grey[700],
              textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
                color: lightMode ? Colors.black : Colors.white,
              ),
            ),
          customButton(
            context: context,
            title: _currentStep < 7 ? 'Next' : 'Preview',
            function: () {
              if (_currentStep < 7) {
                setState(() {
                  _tabCompleted[_currentStep] = true;
                  _currentStep++;
                });
              } else {
                // Collect all form data
                final allData = _collectAllFormData();

                // Navigate to Preview Screen with all data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HREmployeePreviewScreen(
                      personalInfo: {
                        'firstName': allData['firstName'],
                        'middleName': allData['middleName'],
                        'lastName': allData['lastName'],
                        'gender': allData['gender'],
                        'birthday': allData['birthday'],
                        'maritalStatus': allData['maritalStatus'],
                        'nationality': allData['nationality'],
                        'language': allData['language'],
                      },
                      contactInfo: {
                        'mobilePhone': allData['mobilePhone'],
                        'homeNumber': allData['homeNumber'],
                        'personalEmail': allData['personalEmail'],
                        'officeNumber': allData['officeNumber'],
                        'extension': allData['extension'],
                        'businessEmail': allData['businessEmail'],
                      },
                      addressInfo: {
                        'country': allData['country'],
                        'province': allData['province'],
                        'city': allData['city'],
                        'street': allData['street'],
                        'postalCode': allData['postalCode'],
                      },
                      identificationInfo: {
                        'nationalId': allData['nationalId'],
                        'nationalIdExpiration': allData['nationalIdExpiration'],
                        'passport': allData['passport'],
                        'passportExpiration': allData['passportExpiration'],
                        'drivingLicenseId': allData['drivingLicenseId'],
                        'carPlate': allData['carPlate'],
                      },
                      positionInfo: {
                        'jobTitle': allData['jobTitle'],
                        'department': allData['department'],
                        'jobType': allData['jobType'],
                        'workArrangement': allData['workArrangement'],
                        'remoteStatus': allData['remoteStatus'],
                        'jobLocation': allData['jobLocation'],
                        'startDate': allData['startDate'],
                        'workingHours': allData['workingHours'],
                        'daysOff': allData['daysOff'],
                        'salary': allData['salary'],
                        'currency': allData['currency'],
                      },
                      certificationInfo: {
                        'institutionName': allData['institutionName'],
                        'degreeOrCertification': allData['degreeOrCertification'],
                        'fieldOfStudy': allData['fieldOfStudy'],
                        'startDate': allData['certStartDate'],
                        'endDate': allData['certEndDate'],
                        'gradeOrScore': allData['gradeOrScore'],
                        'certificateId': allData['certificateId'],
                        'issuingAuthority': allData['issuingAuthority'],
                        'notes': allData['notes'],
                      },
                      insuranceInfo: {
                        'insuranceName': allData['insuranceName'],
                        'insurancePolicyNumber': allData['insurancePolicyNumber'],
                        'insuranceProviderContact': allData['insuranceProviderContact'],
                      },
                      emergencyInfo: {
                        'firstContact': {
                          'firstName': allData['firstContactFirstName'],
                          'middleName': allData['firstContactMiddleName'],
                          'lastName': allData['firstContactLastName'],
                          'relationship': allData['firstContactRelationship'],
                          'email': allData['firstContactEmail'],
                          'mobilePhone': allData['firstContactMobilePhone'],
                          'country': allData['firstContactCountry'],
                          'province': allData['firstContactProvince'],
                          'language': allData['firstContactLanguage'],
                        },
                        'secondContact': {
                          'firstName': allData['secondContactFirstName'],
                          'middleName': allData['secondContactMiddleName'],
                          'lastName': allData['secondContactLastName'],
                          'relationship': allData['secondContactRelationship'],
                          'email': allData['secondContactEmail'],
                          'mobilePhone': allData['secondContactMobilePhone'],
                          'country': allData['secondContactCountry'],
                          'province': allData['secondContactProvince'],
                          'language': allData['secondContactLanguage'],
                        },
                      },
                    ),
                  ),
                );
              }
            },
            width: buttonWidth,
            height: buttonHeight,
            radius: 8.r,
            color: AppColors.primary,
            textStyle: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: AppColors.textButton,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Personal Information
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();

    // Contact Details
    _mobilePhoneController.dispose();
    _homeNumberController.dispose();
    _personalEmailController.dispose();
    _officeNumberController.dispose();
    _extensionController.dispose();
    _businessEmailController.dispose();

    // Address Details
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();

    // Identification Details
    _nationalIdController.dispose();
    _passportController.dispose();
    _drivingLicenseController.dispose();
    _carPlateController.dispose();

    // Position Details
    _jobTitleController.dispose();
    _workingHoursController.dispose();
    _salaryController.dispose();

    // Certification Details
    _institutionNameController.dispose();
    _gradeOrScoreController.dispose();
    _certificateIdController.dispose();
    _notesController.dispose();

    // Insurance Details
    _insuranceNameController.dispose();
    _insurancePolicyNumberController.dispose();
    _insuranceProviderContactController.dispose();

    // Emergency First Contact
    _emergencyFirstNameController.dispose();
    _emergencyMiddleNameController.dispose();
    _emergencyLastNameController.dispose();
    _emergencyEmailController.dispose();
    _emergencyMobilePhoneController.dispose();
    _emergencyCountryController.dispose();
    _emergencyProvinceController.dispose();

    // Emergency Second Contact
    _emergencySecondFirstNameController.dispose();
    _emergencySecondMiddleNameController.dispose();
    _emergencySecondLastNameController.dispose();
    _emergencySecondEmailController.dispose();
    _emergencySecondMobilePhoneController.dispose();
    _emergencySecondCountryController.dispose();
    _emergencySecondProvinceController.dispose();

    super.dispose();
  }


}