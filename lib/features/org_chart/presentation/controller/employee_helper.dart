import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/org_chart/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

abstract class EmployeeHelper {
  static String getEmployeeFirstAndLastNames(
      {required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize('${employee.firstName.last} ${employee.lastName.last}');
    } else {
      // 23/10/2026 (Moataz: the head's card was blank in Arabic): a person
      // with no Arabic name is shown by the English one, not as an empty card.
      final String arabic =
          '${employee.firstNameInArabic.last} ${employee.lastNameInArabic.last}'
              .trim();
      if (arabic.isNotEmpty) return capitalize(arabic);
      return capitalize('${employee.firstName.last} ${employee.lastName.last}');
    }
  }

  /// The supervisor is stored as an EMAIL; this returns that person's name in
  /// the active language (Moataz 23/10/2026: "the name, not the email"). Looks
  /// in the org-chart employee list, then the core employee map; an email
  /// nobody owns is returned as stored.
  static String supervisorName(String stored) {
    final String email = stored.trim().toLowerCase();
    if (email.isEmpty) return stored;
    final bool english = Get.locale?.languageCode == 'en';
    if (Get.isRegistered<OrgChartEmployeeController>()) {
      for (final NewEmployeeModelHistory e
          in Get.find<OrgChartEmployeeController>().allEmployees ??
              const <NewEmployeeModelHistory>[]) {
        if ((e.email.lastOrNull ?? '').trim().toLowerCase() != email) continue;
        final String name = getEmployeeFirstAndLastNames(employee: e).trim();
        if (name.isNotEmpty) return name;
      }
    }
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final MainCoreEmployeeController core =
          Get.find<MainCoreEmployeeController>();
      if (core.isKnownEmployee(stored)) {
        final String name =
            core.getEmployeeNameEnglishArabic(stored, english).trim();
        if (name.isNotEmpty) return name;
      }
    }
    return stored;
  }

  static String getEmployeeJobTitle(
      {required NewEmployeeModelHistory employee}) {
    if (Get.locale!.languageCode == 'en') {
      return capitalize(employee.title.last);
    } else {
      // Same fallback for the job title.
      final String arabic = employee.titleInArabic.last.trim();
      return capitalize(arabic.isNotEmpty ? arabic : employee.title.last);
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
