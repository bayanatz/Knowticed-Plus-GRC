///*************************** FILE INFO ****************************///
/// Purpose: Edit page for personal information change requests with Arabic support
/// Author: Claude AI Assistant
/// Updated At: 07/11/2025
/// Using CustomValidatedTextField and CustomDropdownFormField

import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/settings/presentation/controller/request_controller.dart';
import 'package:demo_app/features/settings/widgets/countries.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/preview_changes_page.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/constants/skeleton_assets.dart';
import 'package:demo_app/core/enums/enum.dart' as FormatHelper;
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_drop_down.dart';
import '../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/drop_down.dart' hide CustomDropdownFormFieldFinal;
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/core/custom_drop_down.dart';
import '../../../../../core/theme/app_colors.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import '../widgets/countryh_bicker.dart';
import '../widgets/custom_drop_down_new.dart';
import 'settings_screen.dart';


class EditPageRequest extends StatefulWidget {
  const EditPageRequest({super.key});

  @override
  State<EditPageRequest> createState() => _EditPageRequestState();
}

class _EditPageRequestState extends State<EditPageRequest> {
  final RequestController requestController = Get.find<RequestController>();

  // Controllers for all fields
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nationalityController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController dateOfBirthController;

  // Selected values
  String? selectedGender;
  String? selectedMaritalStatus;
  DateTime? selectedDateOfBirth;
  var selectedCountryCode;

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Form validation
  bool submitted = false;

  // Change tracking
  Map<String, dynamic> changes = {};

  // Dropdown items - will be initialized with localized values
  List<Map<String, String>> genderItems = [];
  List<Map<String, String>> maritalStatusItems = [];

  @override
  void initState() {
    super.initState();
    _initializeDropdownItems();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (employee == null) {
      print("WARNING: employee is null in _initializeControllers");
    }

    final isArabic = Get.locale?.languageCode == 'ar';

    // Get the current mobile phone object
    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone = mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    // Extract phone data from MobilePhone object
    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final countryApp = mobilePhone?.countryApp?.lastOrNull ?? "EG";
    final email = employee!.email!.last;

    // Initialize with current employee data - use localized names with capitalization
    firstNameController = TextEditingController(
      text: FormatHelper.capitalize(
        isArabic
            ? (employee?.firstNameInArabic?.lastOrNull ?? '')
            : (employee?.firstName?.lastOrNull ?? ''),
      ),
    );

    middleNameController = TextEditingController(
      text: FormatHelper.capitalize(
        isArabic
            ? (employee?.middleNameInArabic?.lastOrNull ?? '')
            : (employee?.middleName?.lastOrNull ?? ''),
      ),
    );

    lastNameController = TextEditingController(
      text: FormatHelper.capitalize(
        isArabic
            ? (employee?.lastNameInArabic?.lastOrNull ?? '')
            : (employee?.lastName?.lastOrNull ?? ''),
      ),
    );

    emailController = TextEditingController(
      text: email,
    );

    // Initialize phone controller with the actual phone number
    phoneController = TextEditingController(
      text: phoneNumber,
    );

    nationalityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.nationality?.lastOrNull ?? ''),
    );

    countryController = TextEditingController(
      text: FormatHelper.capitalize(employee?.country?.lastOrNull ?? ''),
    );

    provinceController = TextEditingController(
      text: FormatHelper.capitalize(employee?.province?.lastOrNull ?? ''),
    );

    cityController = TextEditingController(
      text: FormatHelper.capitalize(employee?.city?.lastOrNull ?? ''),
    );

    streetController = TextEditingController(
      text: FormatHelper.capitalize(employee?.street?.lastOrNull ?? ''),
    );

    // Set initial selected values for gender
    final genderValue = employee?.gender?.lastOrNull?.toLowerCase();
    selectedGender = genderItems
        .firstWhere(
          (item) => item['key'] == genderValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedGender?.isEmpty ?? true) {
      selectedGender = null;
    }

    // Set initial selected values for marital status
    final maritalValue = employee?.maritalStatus?.lastOrNull?.toLowerCase();
    selectedMaritalStatus = maritalStatusItems
        .firstWhere(
          (item) => item['key'] == maritalValue,
      orElse: () => {'key': '', 'value': ''},
    )['key'];

    if (selectedMaritalStatus?.isEmpty ?? true) {
      selectedMaritalStatus = null;
    }

    // Set country code - use the extracted country code from MobilePhone
    selectedCountryCode = countryCode;

    // Parse birthday with improved error handling
    final birthdayString = employee?.birthDay?.lastOrNull;
    print("==================== BIRTHDAY DEBUG START ====================");
    print("DEBUG - Birthday raw data: $birthdayString");
    print("DEBUG - Birthday full list: ${employee?.birthDay}");
    print("DEBUG - Birthday list length: ${employee?.birthDay?.length}");

    // Only attempt to parse if we have a non-null, non-empty string
    if (birthdayString != null && birthdayString.trim().isNotEmpty) {
      print("DEBUG - Attempting to parse birthday: '$birthdayString'");
      selectedDateOfBirth = _parseDate(birthdayString);
      print("DEBUG - Parsed selectedDateOfBirth: $selectedDateOfBirth");
    } else {
      selectedDateOfBirth = null;
      print("DEBUG - Birthday is null or empty, setting selectedDateOfBirth to null");
    }
    // Initialize date controller with formatted date (localized if Arabic)
    dateOfBirthController = TextEditingController(
      text: selectedDateOfBirth != null
          ? _formatDateForDisplay(selectedDateOfBirth!)
          : '',
    );

    print("DEBUG - dateOfBirthController.text: '${dateOfBirthController.text}'");
    print("DEBUG - selectedDateOfBirth: $selectedDateOfBirth");
    print("==================== BIRTHDAY DEBUG END ====================");

    print("DEBUG - dateOfBirthController text: ${dateOfBirthController.text}");
    print("DEBUG - Phone controller initialized with: $phoneNumber");
    print("DEBUG - Country code initialized with: $countryCode");
  }
  void _initializeDropdownItems() {
    // Initialize gender items with localized values
    genderItems = [
      {'key': 'male', 'value': 'Male'.tr},
      {'key': 'female', 'value': 'Female'.tr},
    ];

    // Initialize marital status items with localized values
    maritalStatusItems = [
      {'key': 'single', 'value': 'Single'.tr},
      {'key': 'married', 'value': 'Married'.tr},
      {'key': 'divorced', 'value': 'Divorced'.tr},
      {'key': 'widowed', 'value': 'Widowed'.tr},
    ];
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        _trackChange(
          'photo',
          employee?.photo?.lastOrNull,
          pickedFile.path,
        );

        print("upload Done ");
      }
    } catch (e) {
      print("have Error $e ");
    }
  }



  // Helper method to format date for display with Arabic support
  String _formatDateForDisplay(DateTime date) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final formatted = isArabic ?  DateFormat('yyyy/M/dd').format(date): DateFormat('dd/MM/yyyy').format(date); // ← NEW FORMAT

    if (isArabic) {
      return _convertNumberToArabic(formatted);
    }
    return formatted;
  }

  // Helper method to convert English numbers to Arabic
  String _convertNumberToArabic(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      print("DEBUG - Date string is null or empty");
      return null;
    }

    final cleanedDate = dateString.trim();
    print("DEBUG - Attempting to parse date: '$cleanedDate'");

    // Try ISO 8601 format first
    try {
      final parsed = DateTime.tryParse(cleanedDate);
      if (parsed != null) {
        print("DEBUG - Successfully parsed as ISO format: $parsed");
        return parsed;
      }
    } catch (e) {
      print("DEBUG - ISO parse failed: $e");
    }

    // MANUAL PARSING for dd/MM/yyyy or d/M/yyyy format
    if (cleanedDate.contains('/')) {
      try {
        final parts = cleanedDate.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          print("DEBUG - Manual parse: day=$day, month=$month, year=$year");

          if (day != null && month != null && year != null) {
            // Validate the date ranges
            if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
              final parsed = DateTime(year, month, day);
              print("DEBUG - Successfully parsed manually: $parsed");
              return parsed;
            }
          }
        }
      } catch (e) {
        print("DEBUG - Manual parse failed: $e");
      }
    }

    // Try with dash separator (yyyy-MM-dd)
    if (cleanedDate.contains('-')) {
      try {
        final parts = cleanedDate.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final day = int.tryParse(parts[2]);

          if (day != null && month != null && year != null) {
            if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
              final parsed = DateTime(year, month, day);
              print("DEBUG - Successfully parsed dash format: $parsed");
              return parsed;
            }
          }
        }
      } catch (e) {
        print("DEBUG - Dash format parse failed: $e");
      }
    }

    // Try timestamp (milliseconds since epoch)
    try {
      final timestamp = int.tryParse(cleanedDate);
      if (timestamp != null) {
        final parsed = DateTime.fromMillisecondsSinceEpoch(timestamp);
        print("DEBUG - Successfully parsed as timestamp: $parsed");
        return parsed;
      }
    } catch (e) {
      print("DEBUG - Timestamp parse failed: $e");
    }

    print("DEBUG - All date parsing attempts failed for: '$cleanedDate'");
    return null;
  }

  String _convertArabicToEnglish(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

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

  Set<String> touchedFields = {};

  void _markFieldAsTouched(String fieldName) {
    setState(() {
      touchedFields.add(fieldName);
    });
  }

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

  void _trackChange(String field, dynamic oldValue, dynamic newValue) {
    if (oldValue != newValue) {
      changes[field] = {
        'oldValue': oldValue,
        'newValue': newValue,
      };
    } else {
      changes.remove(field);
    }
  }

  Future<void> _submitChanges() async {
    setState(() {
      submitted = true;
    });

    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _showValidationErrorDialog('Please fill in all required fields'.tr);
      return;
    }

    if (changes.isEmpty) {
      _showValidationErrorDialog('You haven\'t made any changes to submit'.tr);
      return;
    }

    navigateTo(
      context,
      PreviewChangesPage(
        changes: changes,
        selectedImage: _selectedImage,
        firstNameController: firstNameController,
        middleNameController: middleNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        phoneController: phoneController,
        countryController: countryController,
        provinceController: provinceController,
        cityController: cityController,
        streetController: streetController,
        dateOfBirthController: dateOfBirthController,
        selectedGender: selectedGender,
        selectedMaritalStatus: selectedMaritalStatus,
        selectedCountryCode: selectedCountryCode,
      ),
    );
  }

  void _showValidationErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        var lightMode = Theme.of(context).brightness == Brightness.light;
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Material(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 411.w,
                  padding: EdgeInsets.all(24.sp),
                  decoration: BoxDecoration(
                    color: lightMode ? Colors.white : AppColors.chatBackground,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                          'assets/lottie/attention.json',
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.scaleDown,
                          repeat: true
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isPhone = context.isPhone;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: (){
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingMyPersonalData,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(

            physics: ClampingScrollPhysics(),
            child: Column(
              children: [

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
                    Container(
                      padding: EdgeInsets.only(top: 15.h,right: 15.w,left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPortrait) ...[
                            CustomTextField(
                              label: S.of(context).firstName,
                              hint: 'Enter Your First Name'.tr,
                              controller: firstNameController,
                              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                              onChanged: (value) {
                                final isArabic = Get.locale?.languageCode == 'ar';
                                _trackChange(
                                  isArabic ? 'first_name_arabic' : 'first_name',
                                  isArabic
                                      ? employee?.firstNameInArabic?.lastOrNull
                                      : employee?.firstName?.lastOrNull,
                                  value,
                                );
                              },
                            ),
                            isPhone ? SizedBox(height: 16.h) : SizedBox(),
                            CustomTextField(
                              label: S.of(context).middleName,
                              hint: 'Enter Your Middle Name'.tr,
                              controller: middleNameController,
                              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                              onChanged: (value) {
                                final isArabic = Get.locale?.languageCode == 'ar';
                                _trackChange(
                                  isArabic ? 'middle_name_arabic' : 'middle_name',
                                  isArabic
                                      ? employee?.middleNameInArabic?.lastOrNull
                                      : employee?.middleName?.lastOrNull,
                                  value,
                                );
                              },
                            ),
                            isPhone ? SizedBox(height: 16.h) : SizedBox(),
                            CustomTextField(
                              label: S.of(context).lastName,
                              hint: 'Enter Your Last Name'.tr,
                              controller: lastNameController,
                              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                              onChanged: (value) {
                                final isArabic = Get.locale?.languageCode == 'ar';
                                _trackChange(
                                  isArabic ? 'last_name_arabic' : 'last_name',
                                  isArabic
                                      ? employee?.lastNameInArabic?.lastOrNull
                                      : employee?.lastName?.lastOrNull,
                                  value,
                                );
                              },
                            ),
                            isPhone ? SizedBox(height: 16.h) : SizedBox(),

                          ] else ...[
                            Row(
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  children: [
                                    CircleAvatar(
                                      radius: 29.r,
                                      backgroundColor: AppColors.background,
                                      // (_selectedImage != null ||
                                      //     (employee?.photo != null && employee!.photo!.isNotEmpty))
                                      //     ? Colors.transparent
                                      //     : AppColors.grey,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(32.r),
                                        child: _selectedImage != null
                                            ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                          width: 58.r,
                                          height: 58.r,
                                        )
                                            : (employee?.photo != null && employee!.photo!.isNotEmpty)
                                            ? Image.network(
                                          employee!.photo!.last!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              padding: EdgeInsets.all(8.sp),
                                              child: SvgPicture.asset(
                                                SkeletonAssets.imageAvatar,
                                                width: 26.sp,
                                                height: 26.sp,
                                                color:lightMode ? Colors.black : Colors.white,
                                              ),
                                            );
                                          },
                                        )
                                            : Container(
                                          padding: EdgeInsets.all(8.sp),
                                          child: SvgPicture.asset(
                                            SkeletonAssets.imageAvatar,
                                            width: 26.sp,
                                            height: 26.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await _pickImage();
                                      },
                                      child: CircleAvatar(
                                        radius: 10.r,
                                        backgroundColor: AppColors.primary,
                                        child: SvgPicture.asset(
                                          SkeletonAssets.cameraIcon,
                                          width: 16.w,
                                          height: 16.h,
                                          color: AppColors.textButton,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.sp),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: S.of(context).firstName,
                                    hint: 'Enter Your First Name'.tr,
                                    controller: firstNameController,
                                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                    onChanged: (value) {
                                      final isArabic = Get.locale?.languageCode == 'ar';
                                      _trackChange(
                                        isArabic ? 'first_name_arabic' : 'first_name',
                                        isArabic
                                            ? employee?.firstNameInArabic?.lastOrNull
                                            : employee?.firstName?.lastOrNull,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomTextField(
                                    label: S.of(context).middleName,
                                    hint: 'Enter Your Middle Name'.tr,
                                    controller: middleNameController,
                                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                    onChanged: (value) {
                                      final isArabic = Get.locale?.languageCode == 'ar';
                                      _trackChange(
                                        isArabic ? 'middle_name_arabic' : 'middle_name',
                                        isArabic
                                            ? employee?.middleNameInArabic?.lastOrNull
                                            : employee?.middleName?.lastOrNull,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomTextField(
                                    label: S.of(context).lastName,
                                    hint: 'Enter Your Last Name'.tr,
                                    controller: lastNameController,
                                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                    onChanged: (value) {
                                      final isArabic = Get.locale?.languageCode == 'ar';
                                      _trackChange(
                                        isArabic ? 'last_name_arabic' : 'last_name',
                                        isArabic
                                            ? employee?.lastNameInArabic?.lastOrNull
                                            : employee?.lastName?.lastOrNull,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          isPhone ? SizedBox() : SizedBox(height: 16.h),
                          if (isPortrait) ...[
                            CustomDropdownFormFieldAmr(
                              label: S.of(context).gender,
                              spaceHeight: 6,
                              selectedValue: selectedGender,
                              items: genderItems,
                              widthIcon: 16,
                              heightIcon: 16,
                              height: 36,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                  final selectedItem = genderItems.firstWhere(
                                        (item) => item['key'] == value,
                                    orElse: () => {'key': '', 'value': ''},
                                  );
                                  _trackChange(
                                    'gender',
                                    employee?.gender?.lastOrNull,
                                    selectedItem['key'],
                                  );
                                });
                              },
                            ),
                            isPhone ? SizedBox() : SizedBox(height: 16.h),
                            _buildDateOfBirthField(lightMode),
                            isPhone ? SizedBox() : SizedBox(height: 16.h),
                            CustomDropdownFormFieldAmr(
                              label: S.of(context).maritalStatus,
                              selectedValue: selectedMaritalStatus,
                              items: maritalStatusItems,
                              widthIcon: 16,
                              heightIcon: 16,
                              height: 36,
                              onChanged: (value) {
                                setState(() {
                                  selectedMaritalStatus = value;
                                  final selectedItem = maritalStatusItems.firstWhere(
                                        (item) => item['key'] == value,
                                    orElse: () => {'key': '', 'value': ''},
                                  );
                                  _trackChange(
                                    'marital_status',
                                    employee?.maritalStatus?.lastOrNull,
                                    selectedItem['key'],
                                  );
                                });
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdownFormFieldInvMaster(
                                    label: S.of(context).gender,
                                    spaceHeight: 6.h,
                                    selectedValue: selectedGender,
                                    items: genderItems,
                                    widthIcon: 14,
                                    heightIcon: 7,
                                    borderRadius: 4.r,
                                    height: 36,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                        final selectedItem = genderItems.firstWhere(
                                              (item) => item['key'] == value,
                                          orElse: () => {'key': '', 'value': ''},
                                        );
                                        _trackChange(
                                          'gender',
                                          employee?.gender?.lastOrNull,
                                          selectedItem['key'],
                                        );
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                               Expanded(child: _buildDateOfBirthField(lightMode)),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomDropdownFormFieldInvMaster(
                                    label: S.of(context).maritalStatus,
                                    spaceHeight: 6.h,
                                    borderRadius: 4.r,
                                    selectedValue: selectedMaritalStatus,
                                    items: maritalStatusItems,
                                    widthIcon: 14,
                                    heightIcon: 7,
                                    height: 36,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMaritalStatus = value;
                                        final selectedItem = maritalStatusItems.firstWhere(
                                              (item) => item['key'] == value,
                                          orElse: () => {'key': '', 'value': ''},
                                        );
                                        _trackChange(
                                          'marital_status',
                                          employee?.maritalStatus?.lastOrNull,
                                          selectedItem['key'],
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],

                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Container(
                      padding: EdgeInsets.only(top: 15.h,right: 15.w,left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvg(assetPath: 'assets/phone_contact.svg',width: 25.w,height: 25.h,fit: BoxFit.fill,),
                              SizedBox(width: 8.sp),
                              Text(S.of(context).contact,style: StyleText.fontSize16Weight600.copyWith(
                                  color: AppColors.text,
                              ),),
                            ],
                          ),
                          SizedBox(height: 15.sp),
                          _buildContactSection(isPortrait, lightMode, isTablet),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.sp),
                    Container(
                      padding: EdgeInsets.only(top: 15.h,right: 15.w,left: 15.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CustomSvg(assetPath: 'assets/new_location.svg',width: 25.w,height: 25.h,fit: BoxFit.fill,),
                              SizedBox(width: 8.sp),
                              Text(S.of(context).location,style: StyleText.fontSize16Weight600.copyWith(
                                  color: AppColors.text,
                              ),),
                            ],
                          ),
                          SizedBox(height: 10.sp),
                          _buildLocationSection(isPortrait, lightMode, isTablet),
                          isPhone ? SizedBox() : SizedBox(height: 16.h),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.sp),
                // Replace the preview button section at the bottom of your build method with this:

                // Replace the preview button section at the bottom of your build method with this:

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    customButton(
                      title: S.of(context).discardChange,
                      function: () {
                        Navigator.pop(context);
                      },
                      height: 38.h,
                      width: 150.sp,
                      color: lightMode ? Colors.grey[400] : Colors.grey[700],
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: lightMode ? Colors.black : Colors.white
                      ),
                    ),
                    Spacer(),
                    customButton(
                      title: S.of(context).preview,
                      function: changes.isEmpty
                          ? () {} // Empty function when disabled (or null if customButton supports it)
                          : () => _submitChanges(), // Wrap async function
                      height: 38.h,
                      width: 150.sp,
                      color: changes.isEmpty ? lightMode ? Colors.grey[400] : Colors.grey[700]  : AppColors.primary, // Gray if no changes
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: changes.isEmpty
                            ? lightMode ? Colors.black : Colors.white // Lighter text when disabled
                            : AppColors.textButton,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Usage example for _buildDateOfBirthField
  Widget _buildDateOfBirthField(bool lightMode) {
    print("DEBUG - Building date field");
    print("DEBUG - S.of(context).birthday: ${S.of(context).birthday}");
    print("DEBUG - S.of(context).selectdate: ${S.of(context).selectdate}");
    print("DEBUG - StyleText.fontSize12Weight400: $StyleText.fontSize12Weight400");
    print("DEBUG - AppColors.secondaryText: ${AppColors.secondaryText}");
    // Create display value from selectedDateOfBirth
    final displayValue = selectedDateOfBirth != null
        ? _formatDateForDisplay(selectedDateOfBirth!)
        : null;

    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: CustomDropdownFormFieldCalendar(
        key: ValueKey('birthday_${displayValue ?? "empty"}'), // Null-safe key
        selectedValue: displayValue,
        width: double.infinity,
        height: 36,
        label: S.of(context).birthday ?? 'Birthday', // Add null safety
        hint: Text(
          S.of(context).selectdate ?? 'Select date', // Add null safety
          style: (StyleText.fontSize12Weight400 ?? const TextStyle()).copyWith(
            color: AppColors.secondaryText ?? Colors.grey,
          ),
        ),
        initialDate: selectedDateOfBirth ?? DateTime(2000, 1, 1),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        onChanged: (value) {
          if (value != null) {
            print("DEBUG - Date picker returned: '$value'");

            // Convert Arabic numerals to English before parsing
            final englishValue = _convertArabicToEnglish(value);

            // Parse the date
            final parts = englishValue.split('/');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]);
              final month = int.tryParse(parts[1]);
              final year = int.tryParse(parts[2]);

              if (day != null && month != null && year != null) {
                final picked = DateTime(year, month, day);

                setState(() {
                  selectedDateOfBirth = picked;
                  dateOfBirthController.text = _formatDateForDisplay(picked);

                  _trackChange(
                    'date_of_birth',
                    employee?.birthDay?.lastOrNull,
                    picked.toIso8601String(),
                  );
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildContactSection(bool isPortrait, bool lightMode, bool isTablet) {
    final isArabic = Get.locale?.languageCode == 'ar';
    var isPhone = context.isPhone;

    // Get the current mobile phone object
    final mobilePhoneList = employee!.mobilePhone;
    final mobilePhone = mobilePhoneList?.isNotEmpty == true ? mobilePhoneList!.first : null;

    // Extract phone data from MobilePhone object
    final phoneNumber = mobilePhone?.phones?.lastOrNull ?? "";
    final countryCode = mobilePhone?.countryCode?.lastOrNull ?? "EG";
    final countryApp = mobilePhone?.countryApp?.lastOrNull ?? "EG";

    // Use selectedCountryCode if available, otherwise use the extracted countryCode
    final currentCountryCode = selectedCountryCode ?? countryCode;

    final flag = _getCountryFlag(currentCountryCode);
    final dialCode = _getDialCode(currentCountryCode);

    // Convert to Arabic digits if Arabic locale
    final displayDialCode = isArabic ? _convertToArabicDigits(dialCode) : dialCode;
    final flagAndCode = '$flag $displayDialCode';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPortrait) ...[
            CustomTextField(
              label: S.of(context).email,
              hint: 'Enter Your Email'.tr,
              controller: emailController,
              textDirection: ui.TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _trackChange(
                  'email',
                  employee?.email?.lastOrNull,
                  value,
                );
              },
            ),
            isPhone ? SizedBox(height: 16.h) : SizedBox(),
            Text(
              S.of(context).phoneNumber,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
            // Removed the outer Row wrapper - just use the inner Row directly
            Row(
              children: [
                // Country Code Field
                SizedBox(
                  width: 0.25.w,
                  child: CustomTextField(
                    label: '',
                    hint: flagAndCode,
                    controller: TextEditingController(text: flagAndCode),
                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    enabled: false,
                    readOnly: true,
                    onTap: () async { // Add onTap directly to the text field if supported
                      final result = await showCountryPickerDialog(context);
                      if (result != null) {
                        setState(() {
                          selectedCountryCode = result.dialCode;
                          _trackChange(
                            'country_code',
                            mobilePhone?.countryCode?.lastOrNull,
                            result.dialCode,
                          );
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 0.02.w),
                // Phone Number Field
                Expanded(
                  child: CustomTextField(
                    label: '',
                    hint: 'Enter The Phone Number'.tr,
                    controller: phoneController,
                    textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      _trackChange(
                        'phone',
                        mobilePhone?.phones?.lastOrNull,
                        value,
                      );
                    },
                  ),
                ),
              ],
            ),
            isPhone ? SizedBox(height: 16.h) : SizedBox(),
          ]

          else ...[
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // // Email Field (Landscape)
                    // Expanded(
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //       right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                    //       left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                    //     ),
                    //     child: CustomTextField(
                      Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Country Code Field - Using CustomValidatedTextFieldInv
                              SizedBox(
                                width: 70.w, // Fixed width for country code
                                child: CustomTextField(
                                  label: '',
                                  hint: flagAndCode,
                                  controller: TextEditingController(text: flagAndCode),
                                  textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                  textAlign: TextAlign.center,
                                  enabled: true,
                                  readOnly: true,
                                  onTap: () async {
                                    final result = await showCountryPickerDialog(context);
                                    if (result != null) {
                                      setState(() {
                                        selectedCountryCode = result.dialCode;
                                        _trackChange(
                                          'country_code',
                                          mobilePhone?.countryCode?.lastOrNull,
                                          result.dialCode,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Phone Number Field
                              Expanded(
                                child: CustomTextField(
                                  label: '',
                                  hint: 'Enter The Phone Number'.tr,
                                  controller: phoneController,
                                  textDirection: ui.TextDirection.ltr,
                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    _trackChange(
                                      'phone',
                                      mobilePhone?.phones?.lastOrNull,
                                      value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                      ],
                    ),
                SizedBox(height: 15.sp)
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _convertToArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

    Widget _buildLocationSection(bool isPortrait, bool lightMode, bool isTablet) {
    var isPhone = context.isPhone;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPortrait) ...[
            CustomTextField(
              label: S.of(context).country,
              hint: 'Enter Your Country'.tr,
              controller: countryController,
              onChanged: (value) {
                _trackChange(
                  'country',
                  employee?.country?.lastOrNull,
                  value,
                );
              },
            ),
            isPhone ? SizedBox(height: 16.h) : SizedBox(),
            CustomTextField(
              label: S.of(context).stateOrProvince,
              hint: 'Enter Your State Or Province'.tr,
              controller: provinceController,
              onChanged: (value) {
                _trackChange(
                  'province',
                  employee?.province?.lastOrNull,
                  value,
                );
              },
            ),
            isPhone ? SizedBox(height: 16.h) : SizedBox(),            CustomTextField(
              label: S.of(context).city,
              hint: 'Enter Your City'.tr,
              controller: cityController,
              onChanged: (value) {
                _trackChange(
                  'city',
                  employee?.city?.lastOrNull,
                  value,
                );
              },
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: S.of(context).country,
                    hint: 'Enter Your Country'.tr,
                    controller: countryController,
                    onChanged: (value) {
                      _trackChange(
                        'country',
                        employee?.country?.lastOrNull,
                        value,
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: CustomTextField(
                    label: S.of(context).stateOrProvince,
                    hint: 'Enter Your State Or Province'.tr,
                    controller: provinceController,
                    onChanged: (value) {
                      _trackChange(
                        'province',
                        employee?.province?.lastOrNull,
                        value,
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: CustomTextField(
                    label: S.of(context).city,
                    hint: 'Enter Your City'.tr,
                    controller: cityController,
                    onChanged: (value) {
                      _trackChange(
                        'city',
                        employee?.city?.lastOrNull,
                        value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
          isPhone ? SizedBox(height: 16.h) : SizedBox(height: 16.h),          CustomTextField(
            label: S.of(context).streetName,
            hint: 'Enter Your Street Address'.tr,
            controller: streetController,
            onChanged: (value) {
              _markFieldAsTouched('street');
              _trackChange(
                'street',
                employee?.street?.lastOrNull,
                value,
              );
            },
          ),
          isPhone ? SizedBox(height: 16.h) : SizedBox(),
        ],
      ),
    );
  }
}