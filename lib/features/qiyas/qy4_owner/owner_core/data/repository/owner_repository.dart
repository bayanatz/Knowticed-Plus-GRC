import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_core/data/data/owner_remote_data_source.dart';

class ChampiganRepository {
  ChampiganRemoteDataSource champiganRemoteDataSource =
      ChampiganRemoteDataSource();
  Future<Either<Failure, dynamic>> getChampiganAccessList(
      {required String championId}) async {
    // `final`, not Either<Failure, dynamic>: the data source returns the core
    // FirebaseFailure, not Qiyas's legacy Failure, which crashed at runtime.
    var response = await champiganRemoteDataSource.getChampiganAccessList(
        championId: championId);
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
    }
    //  print("Champigan Access List: ${entity.length}");
    return Right(entity);
  }

  // Either<dynamic, …>: the data source returns the core FirebaseFailure,
  // Qiyas's own Failure type is a different class (runtime type error).
  Future<Either<dynamic, dynamic>> getAccessedCriteriaList(
      {required List<String> criteriaNumbers}) async {
    //   print("searched criteria numbers: $criteriaNumbers");
    var response = await champiganRemoteDataSource.getAccessedCriteriaList(
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
    // print("Accessed Criteria List: ${visionsList.length}");
    return Right(visionsList);
  }
}
