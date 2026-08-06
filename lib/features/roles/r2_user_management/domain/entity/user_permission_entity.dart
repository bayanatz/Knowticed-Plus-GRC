import 'package:get/get.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/features/roles/r2_user_management/data/user_mangment_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class UserPermissionEntity {
  String employeeEmail;
  String imagePath;
  String employeeId;
  String? gender;
  String englishName;
  String arabicName;
  String? accessName;
  String? grantorEnglishName;
  String? grantorArabicName;
  String? startDate;
  String? endDate;
  UserAccessStatus accessStatus;
  String? departmentId;
  String? arabicJobTitle;
  String? englishJobTitle;

  UserPermissionEntity(
      {required this.imagePath,
        required this.employeeEmail,
        required this.employeeId,
        required this.gender,
        required this.englishName,
        required this.arabicName,
        required this.accessName,
        required this.grantorEnglishName,
        required this.grantorArabicName,
        required this.startDate,
        required this.accessStatus,
        this.departmentId,
        this.arabicJobTitle,
        this.englishJobTitle,
        required this.endDate});

  String get userName =>
      Get.locale.toString().contains('en') ? englishName : arabicName;

  String get grantorName => Get.locale.toString().contains('en')
      ? (grantorEnglishName ?? "")
      : (grantorArabicName ?? "");

  /// ✅ NEW: Get localized role name from RoleCubit
  String getLocalizedRoleName() {
    // Handle null or empty accessName
    if (accessName == null || accessName!.isEmpty) {
      return 'No Role';
    }

    try {
      final roleCubit = Get.find<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull(
              (r) => r.roleId == accessName || r.currentRoleName == accessName
      );

      if (role != null) {
        // Return localized role name based on current language
        return Get.locale?.languageCode == 'ar'
            ? (role.currentRoleNameAr ?? role.currentRoleName)
            : role.currentRoleName;
      }

      return accessName!;
    } catch (e) {
      // If RoleCubit is not available, return the accessName directly
      return accessName!.isEmpty ? 'No Role' : accessName!;
    }
  }

  static UserPermissionEntity fromEmployeeEntity(EmployeeEntityPro employee) {
    return UserPermissionEntity(
      employeeEmail: employee.email!,
      employeeId: employee.id!,
      gender: employee.gender,
      imagePath: EmployeeHelper.getEmployeeImage(employee: employee),
      englishName: employee.firstName! + ' ' + employee.lastName!,
      arabicName:
      employee.firstNameInArabic! + ' ' + employee.lastNameInArabic!,
      accessName: null,
      grantorEnglishName: null,
      grantorArabicName: null,
      startDate: null,
      accessStatus: UserAccessStatus.all,
      endDate: null,
      departmentId: employee.departmentId,
      arabicJobTitle: employee.titleInArabic,
      englishJobTitle: employee.title,
    );
  }

  /// [departments] is passed in rather than located, so this entity stays a
  /// plain data class with no service-locator dependency.
  String departmentName(bool isArabic, MainCoreDepartmentCubit departments) {
    if (departmentId == null) return '';
    return isArabic
        ? (departments.getArabicDepartmentNameFromDepartmentId(
                departmentId: departmentId!) ??
            "")
        : (departments.getEnglishDepartmentNameFromDepartmentId(
                departmentId: departmentId!) ??
            "");
  }

  String jobTitle (bool isArabic){
    return (isArabic ? arabicJobTitle : englishJobTitle)??'';
  }
}