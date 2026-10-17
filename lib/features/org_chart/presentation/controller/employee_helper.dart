import 'package:get/get.dart';
import 'package:grc_module/features/org_chart/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

abstract class EmployeeHelper {
  static String getEmployeeFirstAndLastNames(
      {required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize('${employee.firstName.last} ${employee.lastName.last}');
    } else {
      return capitalize(
          '${employee.firstNameInArabic.last} ${employee.lastNameInArabic.last}');
    }
  }

  static String getEmployeeJobTitle(
      {required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize(employee.title.last);
    } else {
      return capitalize(employee.titleInArabic.last);
    }
  }

  static String getImageUrl({required NewEmployeeModelHistory employee}) {
    String employeeImageUrl =
        "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png";
    if (employee.gender.last == "female") {
      employeeImageUrl =
          "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png";
    }
    if (employee.photo.lastOrNull != null) {
      employeeImageUrl = employee.photo.last;
    }
    return employeeImageUrl;
  }
}
