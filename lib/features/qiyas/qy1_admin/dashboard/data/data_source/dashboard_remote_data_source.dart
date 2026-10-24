import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/qiyas_get_it.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

class DashboardRemoteDataSource {
  Future<Either<FirebaseFailure, dynamic>> getAllActiveChampionTasks() async {
    return await FirebaseRepository.getDocumentsWithOneFilter(
        collectionPath: getBaseUrl(kQiyasChampionNameCollection),
        filterKey: QiyasChampionModel.statusKey,
        filterValue: 'active');
  }

  Future<Either<Failure, dynamic>> getSubmissionStatus() async {
    return await FirebaseRepository.getCollection(
        collectionPath:
            getBaseUrl(ApiConstant.kQiyasEvidenceSubmissionsCollection));
  }

  Future<Either<FirebaseFailure, dynamic>> getAllInactiveChampionTasks() async {
    return await FirebaseRepository.getDocumentsWithOneFilter(
        collectionPath: getBaseUrl(kQiyasChampionNameCollection),
        filterKey: QiyasChampionModel.statusKey,
        filterValue: 'inactive');
  }
}
