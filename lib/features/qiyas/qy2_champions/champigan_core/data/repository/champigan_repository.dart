import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/data/data/champigan_remote_data_source.dart';

class OwnerRepository {
  ChampiganRemoteDataSource ownerRemoteDataSource = ChampiganRemoteDataSource();
  Future<Either<Failure, dynamic>> getOwnerAccessList(
      {required String ownerId}) async {
    List<String> managerChampions = getManagerChampions(ownerId);

    var response = await ownerRemoteDataSource.getChampionsAccessList();
    if (response.isLeft()) return response;
    var data =
        response.fold((_) => List<Map<String, dynamic>>.from([]), (r) => r);
    List<QiyasChampionEntity> entity = [];
    List<QiyasChampionModel> models = [];

    for (var item in data) {
      models.add(QiyasChampionModel.fromMap(item));
    }

    for (var model in models) {
      entity.add(QiyasChampionEntity.qiyasChampionFireBasetoEntity(model));
      if (!managerChampions
          .contains(entity.last.controlChampion.toLowerCase())) {
        entity.removeLast();
      } else {
        // print("Added Champion: ${entity.last.controlChampion}");
        // print("managerChampions: $managerChampions");
      }
    }

    // print("Champigannn Access List: ${entity.length}");
    return response = Right(entity);
  }

  // Either<dynamic, …>: the data source returns the core FirebaseFailure,
  // Qiyas's own Failure type is a different class (runtime type error).
  Future<Either<dynamic, dynamic>> getAccessedCriteriaList(
      {required List<String> criteriaNumbers}) async {
    // print("searched criteria numbers: $criteriaNumbers");
    var response = await ownerRemoteDataSource.getAccessedCriteriaList(
        criteriaNumbers: criteriaNumbers);
    if (response.isLeft()) return response;
    var data =
        response.fold((_) => List<Map<String, dynamic>>.from([]), (r) => r);
    List<VisionModel> entity = [];
    for (var item in data) {
      entity.add(VisionModel.fromMap(item));
    }
    List<Visions> visionsList = [];
    for (var vision in entity) {
      visionsList.add(Visions.visionFireBasetoEntity(vision));
    }
    //  print("Accessed Criteria List: ${visionsList.length}");
    return Right(visionsList);
  }

  /// function name: [getManagerChampions]
  ///
  /// purpose: This function retrieves a list of unique champions managed by the current employee.
  List<String> getManagerChampions(String currentEmployeeId) {
    List<EmployeeEntityPro>? allEmployees =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities;
    Map<String, String?> managerChampions = {};
    for (var employee in allEmployees!) {
      managerChampions[employee.email!] = employee.supervisor;
    }
    Set<String> uniqueChampions = {};
    uniqueChampions
        .add(currentEmployeeId.trim().toLowerCase().replaceAll(' ', ''));

    for (EmployeeEntityPro employee in allEmployees) {
      bool isChampion = false;
      String employeeId = employee.email!;
      while (managerChampions[employeeId] != null) {
        // print("entered here as inifnite loop");
        // print(
        //     "current user id: $employeeId and admin id: ${managerChampions[employeeId]}");
        if (managerChampions[employeeId] == currentEmployeeId) {
          isChampion = true;
          break;
        }
        if (employeeId.toLowerCase().trim() ==
            managerChampions[employeeId]?.toLowerCase().trim()) {
          break;
        }

        employeeId = managerChampions[employeeId]!;
      }
      if (isChampion) {
        uniqueChampions
            .add(employee.email!.trim().toLowerCase().replaceAll(' ', ''));
      }
    }
    return uniqueChampions.toList();
  }
}
