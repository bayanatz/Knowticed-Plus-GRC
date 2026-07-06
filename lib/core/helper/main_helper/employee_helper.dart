import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/core/helper/messaging/core/configs/extensions/extensions.dart';

import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';

abstract class EmployeeHelper {
  static String getEmployeeLocalizedName(
      {required EmployeeEntityPro employee, required BuildContext context}) {
  //  print('getEmployeeLocalizedName: ${employee.email} ${employee.lastName}');
    String name = '';
    if (!context.isArabic) {
      name = '${employee.firstName!} ${employee.lastName!}';
    } else {
      // print(
      //     'getEmployeeLocalizedName: ${employee.firstNameInArabic} ${employee.lastNameInArabic}');
      name = '${employee.firstNameInArabic!} ${employee.lastNameInArabic!}';
    }
    //print('getEmployeeLocalizedName name: $name');
    return name;
  }

  static String getEmployeeLocalizedNameWithId(
      {required String employeeId, required BuildContext context}) {
    EmployeeEntityPro employee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.id == employeeId);
    return getEmployeeLocalizedName(employee: employee, context: context);
  }

  static String getEmployeeImageWithId({required String employeeId}) {
    EmployeeEntityPro employee =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities!.firstWhere(
              (element) => element.id == employeeId,
            );
    return getEmployeeImage(employee: employee);
  }

  static String getEmployeeImageWithEmail({required String employeeEmail}) {
    EmployeeEntityPro employee =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities!.firstWhere(
              (element) => element.email == employeeEmail,
            );
    return getEmployeeImage(employee: employee);
  }

  static String getEmployeeImage({required EmployeeEntityPro employee}) {
    String employeeImageUrl = employee.photo ?? "";

    // ✅ Check for null, empty string, or "[]"
    if (employee.photo == null ||
        employee.photo!.isEmpty ||
        employee.photo == "[]") {
      if (employee.gender == 'female') {
        employeeImageUrl = "assets/icons_assets/main_icons_assets/images_female.svg";
      } else {
        employeeImageUrl = "assets/icons_assets/main_icons_assets/assets_male.svg";
      }
    }

    print('getEmployeeImage: $employeeImageUrl');
    return employeeImageUrl;
  }

  static String getEmployeeLocalizedNameWithEmail(
      {required String employeeEmail}) {
    EmployeeEntityPro employee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.email == employeeEmail);
    return getEmployeeLocalizedName(employee: employee, context: Get.context!);
  }

  static String getEmployeeLocalizeDepartment(
      {required EmployeeEntityPro employee, required BuildContext context}) {
    if (context.isArabic) {
      return Get.find<MainCoreDepartmentController>()
              .getArabicDepartmentNameFromDepartmentId(
                  departmentId: employee.departmentId!) ??
          "";
    } else {
      return Get.find<MainCoreDepartmentController>()
              .getEnglishDepartmentNameFromDepartmentId(
                  departmentId: employee.departmentId!) ??
          "";
    }
  }

  static getEmployeeLocalizedTitle(
      {required EmployeeEntityPro employee, required BuildContext context}) {
    if (context.isArabic) {
      return employee.titleInArabic;
    } else {
      return employee.title;
    }
  }
}
