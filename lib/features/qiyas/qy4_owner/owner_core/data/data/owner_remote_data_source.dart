import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';

class ChampiganRemoteDataSource {
  Future<Either<FirebaseFailure, List<Map<String, dynamic>>>>
      getChampiganAccessList({required String championId}) async {
    return await FirebaseRepository.getDocumentsWithTwoFieldsValue(
        collectionPath: getBaseUrl(kQiyasChampionNameCollection),
        field1: QiyasChampionModel.controlChampionKey,
        value1: championId,
        field2: QiyasChampionModel.statusKey,
        value2: 'active');
  }

  Future<Either<FirebaseFailure, dynamic>> getAccessedCriteriaList(
      {required List<String> criteriaNumbers}) async {
    return await FirebaseRepository.getDocumentsContainsFieldValue(
        collectionPath: getBaseUrl(kVisionNameCollection),
        field: VisionModel.criterionNumberKey,
        values: criteriaNumbers);
  }
}
