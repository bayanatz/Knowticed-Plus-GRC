/// ****************** FILE INFO **************
/// FILE NAME: selectable_qiyas_person_entity.dart
/// Purpose: Defines the entity holds person data for qiyas module.
/// Author: Mohamed Elrashidy
/// Created At: 19/5/2025
library;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/features/roles/r4_active_directory/presentation/controller/add_department_controller.dart';

class QiyasPersonEntity {
  String department, id;
  String image;
  String arabicName;
  String titleArabic;
  String phone;
  bool isSelected = false;

  QiyasPersonEntity(
      {required this.department,
      required this.id,
      required this.image,
      required this.arabicName,
      required this.titleArabic,
      required this.phone});

  static QiyasPersonEntity fromEmployeeEntity(
      EmployeeEntityPro employeeEntity) {
    return QiyasPersonEntity(
      phone: _buildPhone(employeeEntity),
      department: employeeEntity.departmentId ?? "",
      id: employeeEntity.email ?? "",
      image: employeeEntity.photo ??
          (employeeEntity.gender == "female"
              ? "assets/icons_assets/qiyas_assets/ic_user_female.svg"
              : "assets/icons_assets/qiyas_assets/ic_user_male.svg"),
      arabicName:
          "${employeeEntity.firstNameInArabic ?? ""} ${employeeEntity.lastNameInArabic ?? ""}"
              .trim(),
      titleArabic: employeeEntity.titleInArabic ?? "",
    );
  }

  /// ✅ mobilePhone is a single MobilePhoneEntity — access fields directly
  static String _buildPhone(EmployeeEntityPro employeeEntity) {
    try {
      final mobile = employeeEntity.mobilePhone;
      if (mobile == null) return "";

      final code = _clean(mobile.countryCode);
      final number = _clean(mobile.phone);
      return "$code$number";
    } catch (e) {
      debugPrint("⚠️ Error building phone: $e");
      return "";
    }
  }

  /// ✅ Removes any [ ] brackets that appear when a List is accidentally toString()-ed
  static String _clean(dynamic value) {
    if (value == null) return "";
    return value.toString().replaceAll('[', '').replaceAll(']', '').trim();
  }

  String get name => arabicName;
  String get title => titleArabic;
  String get departmentName {
    try {
      MainCoreDepartmentController addDepartmentController = Get.find();
      DepartmentModelPro? departmentModel = addDepartmentController
          .departmentModels
          .firstWhereOrNull((element) => element.departmentID == department);
      return departmentModel?.departmentNameInArabic ?? "";
    } catch (e) {
      debugPrint("⚠️ Error getting department name: $e");
      return "";
    }
  }
}
