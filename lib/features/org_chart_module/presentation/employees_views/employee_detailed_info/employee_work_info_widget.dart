
// ignore_for_file: sdk_version_since
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/custom_personal_Info_Container.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/mobile_phone_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:grc_module/generated/l10n.dart';



/// Date Created: 3/Dec/2023
/// Developer Name: Bassem Mohamed
/// App Version: Version 2
/// Date of Last Edit: Migrated to NewEmployeeModelHistory
/// Objectives: Screen showing employee work information including:
/// - Position details
/// - Working history
/// - Work schedule
/// - Education
/// - Skills

class EmployeeWorkInfoScreen extends StatefulWidget {
  const EmployeeWorkInfoScreen({super.key, required this.employee});
  final NewEmployeeModelHistory employee;

  @override
  State<EmployeeWorkInfoScreen> createState() => _EmployeeWorkInfoScreenState();
}

class _EmployeeWorkInfoScreenState extends State<EmployeeWorkInfoScreen> {
  /// Guarded lookup — the controller may not be registered yet when this
  /// widget builds, which used to throw `"AddDepartmentController" not found`.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  // NOTE: this used to hold `RoleController` + `UsersAccessController` (GetX).
  // Both were dead: `addRoleController` and `accessTypeEmployee` were never
  // read, and `getUserAcess()` in the source app has its body commented out,
  // so `getAccessTypeByName()` awaited a no-op and called setState() for
  // nothing.
  //
  // skeleton_app's equivalents are cubits:
  //   roles/r1_role_management/presentation/controller/role_cubit.dart  (RoleCubit)
  //   roles/r3_user_access/presentation/controller/user_access_cubit.dart (UserAccessCubit)
  // UserAccessCubit exposes the full list via getAccountsStatusEntities() /
  // filteredSortedSelectedEntities — there is no single-employee fetch.

  @override
  void initState() {
    super.initState();

    // ✅ DEBUG: Print academic history
    print('🎓 Academic History Debug:');
    print('   Count: ${widget.employee.academicHistory.length}');
    if (widget.employee.academicHistory.isNotEmpty) {
      Map<String, dynamic> lastEntry = widget.employee.academicHistory.last;
      print('   Last Entry: $lastEntry');
      print('   University: ${lastEntry['University']}');
      print('   Graduate From: ${lastEntry['Graduate_From']}');
      print('   Year: ${lastEntry['Year_Of_Graduation']}');
    }

    print('🎯 Skills Debug:');
    print('   Count: ${widget.employee.skills.length}');
    print('   Skills: ${widget.employee.skills}');

    print('🎨 Hobbies Debug:');
    print('   Count: ${widget.employee.hobbies.length}');
    print('   Hobbies: ${widget.employee.hobbies}');
  }

  String translateTimeFormat(String original) {
    const Map<String, String> amPmTranslations = {"AM": "ص", "PM": "م"};
    const Map<String, String> numberTranslations = {
      '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
      '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
    };

    List<String> parts = original.split(" ");
    String timePart = parts[0];
    String periodPart = parts[1];

    String translatedTimePart = timePart
        .split('')
        .map((char) => numberTranslations[char] ?? char)
        .join('');

    String translatedPeriodPart = amPmTranslations[periodPart] ?? periodPart;
    String translatedTime = "$translatedTimePart $translatedPeriodPart";

    parts[0] = translatedTime;
    parts.removeAt(1);

    return parts.join(" ");
  }

  String convertToArabicWeekdays(String weekdays) {
    List<String> weekdaysList = weekdays.split(", ");
    Map<String, String> weekdaysMap = {
      'saturday': 'السبت',
      'sunday': 'الأحد',
      'monday': 'الاثنين',
      'tuesday': 'الثلاثاء',
      'wednesday': 'الأربعاء',
      'thursday': 'الخميس',
      'friday': 'الجمعة',
    };

    List<String> arabicWeekdaysList = weekdaysList.map((weekday) {
      return weekdaysMap[weekday.toLowerCase()] ?? weekday;
    }).toList();

    return arabicWeekdaysList.join(", ");
  }

  String convertToArabicDate(String date) {
    List<String> dateParts = date.split(", ");
    List<String> dateComponents = dateParts[0].split(" ");

    Map<String, String> monthsMap = {
      'jan': 'يناير', 'feb': 'فبراير', 'mar': 'مارس',
      'apr': 'أبريل', 'may': 'مايو', 'jun': 'يونيو',
      'jul': 'يوليو', 'aug': 'أغسطس', 'sep': 'سبتمبر',
      'oct': 'أكتوبر', 'nov': 'نوفمبر', 'dec': 'ديسمبر',
    };

    String arabicMonth = monthsMap[dateComponents[0].toLowerCase()] ?? dateComponents[0];
    return '$arabicMonth ${dateComponents[1]}, ${dateParts[1]}';
  }

  /// ✅ NEW: Get department name safely
  String _getDepartmentName() {
    String departmentId = widget.employee.departmentId.isNotEmpty
        ? widget.employee.departmentId.last
        : '';

    if (departmentId.isEmpty) return '';

    if (Get.locale.toString().contains('en')) {
      return _departments
          .getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId) ?? '';
    } else {
      return _departments
          .getArabicDepartmentNameFromDepartmentId(departmentId: departmentId) ?? '';
    }
  }

  /// ✅ NEW: Get title safely
  String _getTitle() {
    if (Get.locale.toString().contains('en')) {
      return widget.employee.title.isNotEmpty
          ? widget.employee.title.last
          : '';
    } else {
      return widget.employee.titleInArabic.isNotEmpty
          ? widget.employee.titleInArabic.last
          : '';
    }
  }

  /// ✅ NEW: Get title safely
  String _getSuperVisor() {
    if (Get.locale.toString().contains('en')) {
      return widget.employee.supervisor.isNotEmpty
          ? widget.employee.supervisor.last
          : '';
    } else {
      return widget.employee.supervisor.isNotEmpty
          ? widget.employee.supervisor.last
          : '';
    }
  }

  /// ✅ NEW: Get start date safely
  String _getStartDate() {
    if (widget.employee.timestamps.isEmpty) return '';

    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
        widget.employee.timestamps.first
    );

    String formattedDate = DateFormat('MMM dd, yyyy').format(startDate);

    return Get.locale.toString().contains('en')
        ? formattedDate
        : convertToArabicDate(formattedDate);
  }

  /// ✅ FIXED: Get academic history field safely - returns '-' for empty values
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

  /// Get skills as comma-separated string
  String _getSkillsString() {
    List<List<String>> skills = widget.employee.skills;

    if (skills.isEmpty) return '-';

    return skills.map((skillPair) {
      if (skillPair.isEmpty) return '';

      String skillName = skillPair[0];
      String skillLevel = skillPair.length > 1 ? skillPair[1] : '';

      // Return skill with level if available
      return skillLevel.isEmpty ? skillName : '$skillName ($skillLevel)';
    }).where((skill) => skill.isNotEmpty).join(', ');
  }

  /// Get hobbies as comma-separated string
  String _getHobbiesString() {
    List<List<String>> hobbies = widget.employee.hobbies;

    if (hobbies.isEmpty) return '-';

    return hobbies.map((hobbyList) {
      return hobbyList.isNotEmpty ? hobbyList[0] : '';
    }).where((hobby) => hobby.isNotEmpty).join(', ');
  }

  /// ✅ NEW: Get email safely
  String _getEmail() {
    return widget.employee.email.isNotEmpty
        ? widget.employee.email.last
        : '-';
  }

  /// ✅ NEW: Get phone safely
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


  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    // ✅ UPDATED: Safe supervisor check
    bool hasSupervisor = widget.employee.supervisor.isNotEmpty;
    String supervisorEmail = hasSupervisor ? widget.employee.supervisor.last : '';

    // ✅ UPDATED: Safe work location check
    String workLocation = widget.employee.workLocation.isNotEmpty
        ? widget.employee.workLocation.last
        : '';

    return Container(
      color: AppColors.card,
      height: isVertical ? 0.85.h : 0.80.h,  // ~12% more space
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Container(height: 800,color: Colors.red,width: 200,)
            // Position Details
            CustomPersonalInfoContainer(
              primaryText: 'Position Details',
              isPersonalInformation: true,
              isPositionDetailes: true,
              numberOfElementsInColumn: 2,
              customIcons: hasSupervisor
                  ? [
                'assets/icons_assets/organization_chart_assets/new_department.svg',
                'assets/icons_assets/organization_chart_assets/new_superVisor.svg',
                'assets/icons_assets/organization_chart_assets/settings_email.svg',
                'assets/icons_assets/organization_chart_assets/settings_phone.svg',
              ]
                  : [
                'assets/icons_assets/organization_chart_assets/FolderWithFiles.svg',
                'assets/icons_assets/organization_chart_assets/jobCompansation.svg',
                'assets/icons_assets/main_icons_assets/Case.svg',
                'assets/icons_assets/organization_chart_assets/titleIcon.svg',
                'assets/icons_assets/organization_chart_assets/managerOutlined.svg',
                'assets/icons_assets/organization_chart_assets/MapPoint.svg',
                'assets/icons_assets/organization_chart_assets/team.svg',
              ],
              personalInfoTexts: hasSupervisor
                  ? [
                'Department:',
                "${S.of(context).superVisor}: ",
                "${S.of(context).email}: ",
                "${S.of(context).phoneNumber}: ",
              ]
                  : [
                'Department :',
                'Job Compensation :',
                'Job Type :',
                'Title :',
                'Manager :',
                'Job Location :',
              ],
              secondaryTexts: hasSupervisor
                  ? [
                _getDepartmentName(),
                _getSuperVisor(),
                _getEmail(),
                _getPhone(),
                _getTitle(),
              ]
                  : [
                _getDepartmentName(),
                "N/A", // Job Compensation
                "N/A", // Job Type
                _getTitle(),
                supervisorEmail,
                workLocation,
              ],
            ),

            // Working History
            // Working Hours section
            CustomPersonalInfoContainer(
              primaryText: S.of(context).workingHours,
              isPersonalInformation: true,
              isWorkingHours: true, // ✅ NEW FLAG - Enables 3+2 layout
              customIcons: [
                'assets/icons_assets/organization_chart_assets/new_start_date.svg',
                'assets/icons_assets/organization_chart_assets/new_work_hourse.svg',
                'assets/icons_assets/organization_chart_assets/new_day_off.svg',
                'assets/icons_assets/organization_chart_assets/new_sallary.svg',
                'assets/icons_assets/organization_chart_assets/new_job_location.svg',
              ],
              personalInfoTexts: [
                "${S.of(context).startDate}: ",
                "${S.of(context).workingHours}: ",
                "${S.of(context).daysOff}: ",
                //      "${S.of(context).salary}: ",
                "${S.of(context).jobLocation}: ",
              ],
              secondaryTexts: [
                _getStartDate(),
                '-',
                '-',
                workLocation.isEmpty ? '-' : workLocation,
              ],
            ),

            // Work Schedule
            // General Information section
            CustomPersonalInfoContainer(
              primaryText: S.of(context).generalInformation,
              isPersonalInformation: true,
              isGeneralInfo: true, // ✅ NEW FLAG - Single column layout
              customIcons: [
                'assets/icons_assets/organization_chart_assets/new_institution_name.svg',
                'assets/icons_assets/organization_chart_assets/new_degree.svg',
                'assets/icons_assets/organization_chart_assets/new_start_date.svg',
                'assets/icons_assets/organization_chart_assets/skills_new.svg',
                'assets/icons_assets/organization_chart_assets/hobbies_new.svg',
              ],
              personalInfoTexts: [
                "${S.of(context).institutionName}: ",
                "${S.of(context).degreeOrCertification}: ",
                "${S.of(context).graduationYear}: ",
                "${S.of(context).skills}: ",
                "${S.of(context).hobbys}: ",
              ],
              secondaryTexts: [
                _getAcademicField('institutionName'),      // Maps to 'University'
                _getAcademicField('degreeOrCertification'), // Maps to 'Graduate_From'
                _getAcademicField('yearOfGraduation'),     // Maps to 'Year_Of_Graduation'
                _getSkillsString(),                        // Gets skills from employee.skills
                _getHobbiesString(),                       // Gets hobbies from employee.hobbies
              ],
            ),

          ],
        ),
      ),
    );
  }
}