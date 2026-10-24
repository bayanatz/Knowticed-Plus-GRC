// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_repository.dart
// Purpose: Repository implementation for CRM client-status reason sets
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:knowticed_plus/features/crm/crm15_reasons/data/data_source/crm_reasons_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/interfaces/crm_reasons_base_repository.dart';

class CrmReasonsRepository implements CrmReasonsBaseRepository {
  final CrmReasonsRemoteDataSource _remoteDataSource;

  CrmReasonsRepository({CrmReasonsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CrmReasonsRemoteDataSource();

  @override
  Stream<List<CrmReason>> watchReasons(String reasonSetId) =>
      _remoteDataSource.watchReasons(reasonSetId);

  @override
  Future<void> saveReasons({
    required String reasonSetId,
    required List<CrmReason> reasons,
    required String updatedBy,
  }) =>
      _remoteDataSource.saveReasons(
        reasonSetId: reasonSetId,
        reasons: reasons,
        updatedBy: updatedBy,
      );
}
