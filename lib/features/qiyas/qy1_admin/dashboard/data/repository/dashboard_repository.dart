import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/data/models/evidence_submmision_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/data/data_source/dashboard_remote_data_source.dart';

class DashboardRepository {
  DashboardRemoteDataSource dashboardRemoteDataSource =
      DashboardRemoteDataSource();
  Future<Either<Failure, dynamic>> getAllChampionsActiveTasks() async {
    var result = await dashboardRemoteDataSource.getAllActiveChampionTasks();
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    List<QiyasChampionEntity> tasks = [];
    // print('tasks length: ${data.length}');
    for (var item in data) {
      tasks.add(QiyasChampionEntity.qiyasChampionFireBasetoEntity(
          QiyasChampionModel.fromMap(item)));
    }
    return result = Right(tasks);
  }

  Future<Either<Failure, dynamic>> getSubmissionStatus() async {
    var result = await dashboardRemoteDataSource.getSubmissionStatus();

    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    List<EvidenceSubmissionModel> submissions = [];
    for (var item in data) {
      EvidenceSubmissionModel submission =
          EvidenceSubmissionModel.fromMap(item);
      submissions.add(submission);
    }
    return result = Right(submissions);
  }

  Future<Either<Failure, dynamic>> getAllChampionsInactiveTasks() async {
    var result = await dashboardRemoteDataSource.getAllInactiveChampionTasks();
    if (result.isLeft()) return result;
    List<Map<String, dynamic>> data = result.fold((_) => [], (r) => r);
    List<QiyasChampionEntity> tasks = [];
    // print('inactive tasks length: ${data.length}');
    for (var item in data) {
      tasks.add(QiyasChampionEntity.qiyasChampionFireBasetoEntity(
          QiyasChampionModel.fromMap(item)));
    }
    return result = Right(tasks);
  }
}
