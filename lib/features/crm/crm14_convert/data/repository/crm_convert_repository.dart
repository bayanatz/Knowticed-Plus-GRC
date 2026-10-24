// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_repository.dart
// Purpose: Repository implementation for CRM conversion stages
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm14_convert/data/data_source/crm_convert_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/interfaces/crm_convert_base_repository.dart';

class CrmConvertRepository implements CrmConvertBaseRepository {
  final CrmConvertRemoteDataSource _remoteDataSource;

  CrmConvertRepository({CrmConvertRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CrmConvertRemoteDataSource();

  @override
  Stream<List<CrmConvertStage>> watchStages() =>
      _remoteDataSource.watchStages();

  @override
  Future<void> createStage(CrmConvertStage stage) =>
      _remoteDataSource.createStage(stage);

  @override
  Future<void> updateStage(CrmConvertStage stage) =>
      _remoteDataSource.updateStage(stage);

  @override
  Future<void> deleteStage(CrmConvertStage stage) =>
      _remoteDataSource.deleteStage(stage);
}
