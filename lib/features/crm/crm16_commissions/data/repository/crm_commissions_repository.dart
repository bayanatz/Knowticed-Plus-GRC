// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_repository.dart
// Purpose: Repository implementation for flat-rate commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm16_commissions/data/data_source/crm_commissions_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/interfaces/crm_commissions_base_repository.dart';

class CrmCommissionsRepository implements CrmCommissionsBaseRepository {
  final CrmCommissionsRemoteDataSource _remoteDataSource;

  CrmCommissionsRepository({CrmCommissionsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? CrmCommissionsRemoteDataSource();

  @override
  Stream<List<CrmCommissionPackage>> watchPackages() =>
      _remoteDataSource.watchPackages();

  @override
  Future<void> createPackage(CrmCommissionPackage package) =>
      _remoteDataSource.createPackage(package);

  @override
  Future<void> updatePackage(CrmCommissionPackage package) =>
      _remoteDataSource.updatePackage(package);

  @override
  Future<void> deletePackage(CrmCommissionPackage package) =>
      _remoteDataSource.deletePackage(package);
}
