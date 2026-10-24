import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/features/roles/r4_active_directory/presentation/controller/add_department_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/home/presentation/controller/qiyas_home_cubit.dart';

class TaskHelper {
  String visionName(String criteriaNumber) {
    Visions vision = getVison(criteriaNumber);
    return vision.visionName;
  }

  String topicName(String criteriaNumber) {
    return getVison(criteriaNumber).topicName;
  }

  String criteriaName(String criteriaNumber) {
    return getVison(criteriaNumber).criterionName;
  }

  Visions getVison(String criteriaNumber) {
    QiyasHomeCubit qiyasHomeCubit = sl();
    return qiyasHomeCubit.visionsList.firstWhere(
      (vision) => vision.criterionNumber == criteriaNumber,
    );
  }

  String getEvidenceName(
      {required String criteriaNumber, required String evidenceNumber}) {
    Visions vision = getVison(criteriaNumber);
    QiyasHomeCubit qiyasHomeCubit = sl();
    return qiyasHomeCubit.getDocumentsNames(
        criterionName: vision.criterionName,
        topicName: vision.topicName,
        visionName: vision.visionName)[int.parse(evidenceNumber)];
  }

  String getChampionImage(String championId) {
    EmployeeEntityPro? entity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhere((element) =>
            element.email!.toLowerCase() == championId.toLowerCase());
    if (entity == null) return '';
    if (entity.photo != null && entity.photo!.isNotEmpty) {
      return entity.photo!;
    }
    return (entity.gender == 'female')
        ? 'assets/icons_assets/qiyas_assets/ic_user_female.svg'
        : 'assets/icons_assets/qiyas_assets/ic_user_male.svg';
  }

  String getChampionName(String championId) {
    debugPrint('Champion ID: $championId');
    EmployeeEntityPro? entity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhere((element) =>
            element.email?.toLowerCase() == championId.toLowerCase().trim());
    if (entity != null) {
      return '${entity.firstNameInArabic!} ${entity.lastNameInArabic!}';
    } else {
      return '';
    }
  }

  String getChampionDepartmentArabicName(String championId) {
    EmployeeEntityPro? entity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhere((element) =>
            element.email?.toLowerCase() == championId.toLowerCase().trim());
    if (entity != null) {
      return Get.find<MainCoreDepartmentController>()
          .getArabicDepartmentNameFromDepartmentId(
              departmentId: entity.departmentId!)!;
    }
    return "";
  }

  String? getChampionDepartmentId(String controlChampion) {
    EmployeeEntityPro? entity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhere((element) =>
            element.email?.toLowerCase() ==
            controlChampion.toLowerCase().trim());
    if (entity != null) {
      return entity.departmentId;
    }
    return "";
  }

  String? getManagerId(String controlChampion) {
    EmployeeEntityPro? entity = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhere((element) =>
            element.email?.toLowerCase() ==
            controlChampion.toLowerCase().trim());
    if (entity != null) {
      return entity.supervisor;
    }
    return "";
  }
}
