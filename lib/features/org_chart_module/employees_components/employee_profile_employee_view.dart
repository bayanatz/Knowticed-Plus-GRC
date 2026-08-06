// ignore_for_file: sdk_version_since

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/custom_personal_Info_Container.dart';
import 'package:grc_module/core/theme/app_font_size.dart';

import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/mobile_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:grc_module/generated/l10n.dart';

/// Date Created: 3/Dec/2023
/// Developer Name: Bassem Mohamed
/// App Version: Version 2
/// Date of Last Edit: Refactored to single column layout
/// Objectives: Mobile screen showing employee work information with single column layout
/// - Position details
/// - Working history
/// - Work schedule
/// - Education
/// - Skills

class EmployeeWorkInfoScreenEmployeeViewMobile extends StatefulWidget {
  const EmployeeWorkInfoScreenEmployeeViewMobile({
    super.key,
    required this.employee,
  });
  final NewEmployeeModelHistory employee;

  @override
  State<EmployeeWorkInfoScreenEmployeeViewMobile> createState() =>
      _EmployeeWorkInfoScreenEmployeeViewMobileState();
}

class _EmployeeWorkInfoScreenEmployeeViewMobileState
    extends State<EmployeeWorkInfoScreenEmployeeViewMobile> {
  /// Loads the user-access list so this profile can show the employee's access
  /// type.
  ///
  /// The old GetX `usersAccessController.getUserAcess(email)` is gone —
  /// skeleton_app uses [UserAccessCubit], which has no single-employee fetch.
  /// It loads every account via `getAccountsStatusEntities()` and exposes the
  /// result on `filteredSortedSelectedEntities`, so filter by email from there:
  ///
  ///   final entity = cubit.filteredSortedSelectedEntities
  ///       .firstWhereOrNull((e) => e.email == email);
  Future<void> getAccessTypeByName() async {
    // ✅ Safe email access
    String email = widget.employee.email.isNotEmpty
        ? widget.employee.email.last
        : '';

    if (email.isNotEmpty) {
      await context.read<UserAccessCubit>().getAccountsStatusEntities();
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Deferred: context.read() is not available during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) => getAccessTypeByName());

    // ✅ DEBUG: Print academic history
    print('🎓 Academic History Debug (Mobile):');
    print('   Count: ${widget.employee.academicHistory.length}');
    if (widget.employee.academicHistory.isNotEmpty) {
      Map<String, dynamic> lastEntry = widget.employee.academicHistory.last;
      print('   Last Entry: $lastEntry');
      print('   University: ${lastEntry['University']}');
      print('   Graduate From: ${lastEntry['Graduate_From']}');
      print('   Year: ${lastEntry['Year_Of_Graduation']}');
    }

    print('🎯 Skills Debug (Mobile):');
    print('   Count: ${widget.employee.skills.length}');
    print('   Skills: ${widget.employee.skills}');

    print('🎨 Hobbies Debug (Mobile):');
    print('   Count: ${widget.employee.hobbies.length}');
    print('   Hobbies: ${widget.employee.hobbies}');
  }

  /// ✅ Get department name safely
  String _getDepartmentName() {
    String departmentId = widget.employee.departmentId.isNotEmpty
        ? widget.employee.departmentId.last
        : '';

    if (departmentId.isEmpty) return '';

    if (Get.locale.toString().contains('en')) {
      return context.read<MainCoreDepartmentCubit>()
          .getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId) ??
          '';
    } else {
      return context.read<MainCoreDepartmentCubit>()
          .getArabicDepartmentNameFromDepartmentId(departmentId: departmentId) ??
          '';
    }
  }

  /// ✅ Get title safely
  String _getTitle() {
    if (Get.locale.toString().contains('en')) {
      return widget.employee.title.isNotEmpty ? widget.employee.title.last : '';
    } else {
      return widget.employee.titleInArabic.isNotEmpty
          ? widget.employee.titleInArabic.last
          : '';
    }
  }

  /// ✅ Get supervisor safely
  String _getSupervisor() {
    return widget.employee.supervisor.isNotEmpty
        ? widget.employee.supervisor.last
        : '';
  }

  String _getEmail() {
    return widget.employee.email.isNotEmpty
        ? widget.employee.email.last
        : '-';
  }

  String _getPhone() {
    if (widget.employee.mobilePhone.isEmpty) return '-';

    MobilePhone phone = widget.employee.mobilePhone.last;

    // Get the last (most recent) phone number and country code
    String countryCode = (phone.countryCode != null && phone.countryCode!.isNotEmpty)
        ? phone.countryCode!.last
        : '';
    String number = (phone.phones != null && phone.phones!.isNotEmpty)
        ? phone.phones!.last
        : '';

    if (countryCode.isEmpty && number.isEmpty) return '-';

    if (countryCode.isEmpty) return number;
    if (number.isEmpty) return countryCode;

    return '$countryCode $number';
  }

  /// ✅ Get start date safely
  String _getStartDate() {
    if (widget.employee.timestamps.isEmpty) return '';

    DateTime startDate =
    DateTime.fromMillisecondsSinceEpoch(widget.employee.timestamps.first);

    String formattedDate = DateFormat('MMM dd, yyyy').format(startDate);

    return Get.locale.toString().contains('en')
        ? formattedDate
        : convertToArabicDate(formattedDate);
  }

  String convertToArabicDate(String date) {
    List<String> dateParts = date.split(", ");
    List<String> dateComponents = dateParts[0].split(" ");

    Map<String, String> monthsMap = {
      'jan': 'يناير',
      'feb': 'فبراير',
      'mar': 'مارس',
      'apr': 'أبريل',
      'may': 'مايو',
      'jun': 'يونيو',
      'jul': 'يوليو',
      'aug': 'أغسطس',
      'sep': 'سبتمبر',
      'oct': 'أكتوبر',
      'nov': 'نوفمبر',
      'dec': 'ديسمبر',
    };

    String arabicMonth =
        monthsMap[dateComponents[0].toLowerCase()] ?? dateComponents[0];
    return '$arabicMonth ${dateComponents[1]}, ${dateParts[1]}';
  }

  /// ✅ Get academic history field safely - returns '-' for empty values
  String _getAcademicField(String fieldName) {
    List<Map<String, dynamic>> academicHistory = widget.employee.academicHistory;

    if (academicHistory.isEmpty) return '-';

    // Get the last (most recent) academic history entry
    Map<String, dynamic> lastEntry = academicHistory.last;

    // ✅ Map to correct Firebase field names
    String firebaseFieldName;
    switch (fieldName) {
      case 'institutionName':
        firebaseFieldName = 'University';
        break;
      case 'degreeOrCertification':
        firebaseFieldName = 'Graduate_From';
        break;
      case 'yearOfGraduation':
        firebaseFieldName = 'Year_Of_Graduation';
        break;
      case 'gpa':
        firebaseFieldName = 'GPA';
        break;
      default:
        return '-';
    }

    // ✅ Extract value from array format
    dynamic fieldValue = lastEntry[firebaseFieldName];

    // ✅ Return '-' if null
    if (fieldValue == null) return '-';

    // ✅ Handle List format
    if (fieldValue is List) {
      // ✅ Return '-' if list is empty
      if (fieldValue.isEmpty) return '-';

      // ✅ Get first value from list
      String value = fieldValue[0]?.toString().trim() ?? '';

      // ✅ Return '-' if value is empty string
      if (value.isEmpty) return '-';

      // ✅ Convert degree codes to readable text
      if (firebaseFieldName == 'Graduate_From') {
        switch (value.toLowerCase()) {
          case 'bachelor':
            return "Bachelor's Degree";
          case 'master':
            return "Master's Degree";
          case 'phd':
            return "PhD";
          case 'diploma':
            return "Diploma";
          case 'certificate':
            return "Certificate";
          default:
            return value;
        }
      }

      return value;
    }

    // ✅ Handle direct string value
    String directValue = fieldValue.toString().trim();
    return directValue.isEmpty ? '-' : directValue;
  }



  String _getSkillsList() {
    List<List<String>> skills = widget.employee.skills;

    if (skills.isEmpty) return '-';

    // Format: "[[skill1], [skill2], [skill3]]"
    // This format will be properly parsed by _buildMobileWrappedItemForGeneralInfo
    List<String> skillNames = skills
        .map((skillPair) {
      if (skillPair.isEmpty) return '';
      return skillPair[0]; // Just the skill name, no level
    })
        .where((skill) => skill.isNotEmpty)
        .toList();

    if (skillNames.isEmpty) return '-';

    // Return in a format that the wrapper can parse
    return skillNames.join(', ');
  }

  /// Get hobbies as a formatted string that can be parsed into wrapped containers
  String _getHobbiesList() {
    List<List<String>> hobbies = widget.employee.hobbies;

    if (hobbies.isEmpty) return '-';

    List<String> hobbyNames = hobbies
        .map((hobbyList) {
      return hobbyList.isNotEmpty ? hobbyList[0] : '';
    })
        .where((hobby) => hobby.isNotEmpty)
        .toList();

    if (hobbyNames.isEmpty) return '-';

    return hobbyNames.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Safe supervisor check
    bool hasSupervisor = widget.employee.supervisor.isNotEmpty;

    // ✅ Safe work location check
    String workLocation = widget.employee.workLocation.isNotEmpty
        ? widget.employee.workLocation.last
        : '';

    return SingleChildScrollView(
      child: Column(
        children: [




          // Position Details - Single Column Layout
          CustomPersonalInfoContainer(
            primaryText: 'Position Details',
            isPersonalInformation: true,
            isPositionDetailes: false,
            numberOfElementsInColumn: 1,
            customIcons: hasSupervisor
                ? [
              'assets/icons_assets/organization_chart_assets/new_department.svg',
              'assets/icons_assets/organization_chart_assets/new_superVisor.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              'assets/icons_assets/main_icons_assets/images_email.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              'assets/icons_assets/main_icons_assets/phone_number.svg',
            ]
                : [
              'assets/icons_assets/organization_chart_assets/new_department.svg',
              'assets/icons_assets/organization_chart_assets/new_superVisor.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              'assets/icons_assets/main_icons_assets/images_email.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              'assets/icons_assets/main_icons_assets/phone_number.svg',
            ],
            personalInfoTexts: hasSupervisor
                ? [
             "${S.of(context).department}: ",
              "${S.of(context).superVisor}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              "${S.of(context).email}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              "${S.of(context).phoneNumber}: ",
            ]
                : [
              "${S.of(context).department}: ",
              "${S.of(context).superVisor}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              "${S.of(context).email}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              "${S.of(context).phoneNumber}: ",
            ],
            secondaryTexts: hasSupervisor
                ? [
              _getDepartmentName(),
              _getSupervisor(),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              _getEmail(),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              _getPhone(),
            ]
                : [
              _getDepartmentName(),
              _getSupervisor(),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareEmailsAndSocialDataInBio,
              ) )
              _getEmail(),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.shareCellphonesInSocialDataInBio,
              ) )
              _getPhone(),
            ],
          ),

          SizedBox(height: 0.02.h),

          // Working Hours - Single Column Layout
          CustomPersonalInfoContainer(
            primaryText: S.of(context).workingHours,
            isPersonalInformation: true,
            isWorkingHours: false, // ✅ CHANGED: Disable 3+2 layout
            numberOfElementsInColumn: 1, // ✅ CHANGED: Single column
            customIcons: [
              'assets/icons_assets/organization_chart_assets/new_start_date.svg',
              'assets/icons_assets/organization_chart_assets/new_work_hourse.svg',
              'assets/icons_assets/organization_chart_assets/new_day_off.svg',
           //   'assets/icons_assets/organization_chart_assets/new_sallary.svg',
              'assets/icons_assets/organization_chart_assets/new_job_location.svg',
            ],
            personalInfoTexts: [
              "${S.of(context).startDate}: ",
              "${S.of(context).workingHours}: ",
              "${S.of(context).daysOff}: ",
            //  S.of(context).salary,
              "${S.of(context).jobLocation}: ",

            ],
            secondaryTexts: [
              _getStartDate(),
              '-',
              '-',
           //   '-',
              workLocation.isEmpty ? '-' : workLocation,
            ],
          ),

          SizedBox(height: 0.02.h),

        if(Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.settings,
      section: SettingsPermissionsSections.socialPermissions,
      permission: SocialPermissions.shareSocialInformation,
    ) )

          // General Information - Single Column Layout
        // General Information - Single Column Layout
          CustomPersonalInfoContainer(
            primaryText: S.of(context).generalInformation,
            isPersonalInformation: true,
            isGeneralInfo: false, // ✅ KEEP FALSE - use default single column for mobile
            numberOfElementsInColumn: 1,
            customIcons: [
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.academicHistory,
              ))
                'assets/icons_assets/organization_chart_assets/new_institution_name.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                'assets/icons_assets/organization_chart_assets/new_degree.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                'assets/icons_assets/organization_chart_assets/new_start_date.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                'assets/icons_assets/organization_chart_assets/skills_new.svg',
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                'assets/icons_assets/organization_chart_assets/hobbies_new.svg',
            ],
            personalInfoTexts: [
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.academicHistory,
              ))
                "${S.of(context).institutionName}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                "${S.of(context).degreeOrCertification}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                "${S.of(context).graduationYear}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                "${S.of(context).skills}: ",
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                "${S.of(context).hobbys}: ",
            ],
            secondaryTexts: [
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.academicHistory,
              ))
                _getAcademicField('institutionName'),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                _getAcademicField('degreeOrCertification'),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.certificates,
              ))
                _getAcademicField('yearOfGraduation'),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                _getSkillsList(),
              if(Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.settings,
                section: SettingsPermissionsSections.socialPermissions,
                permission: SocialPermissions.skillsHobbies,
              ))
                _getHobbiesList(),
            ],
          ),
        ],
      ),
    );
  }
}