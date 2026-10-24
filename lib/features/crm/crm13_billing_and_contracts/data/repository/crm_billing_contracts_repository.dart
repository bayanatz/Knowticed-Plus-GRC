// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_repository.dart
// Purpose: Repository implementation for CRM Billing & Contracts
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/data_source/crm_billing_contracts_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/domain/interfaces/crm_billing_contracts_base_repository.dart';

class CrmBillingContractsRepository
    implements CrmBillingContractsBaseRepository {
  final CrmBillingContractsRemoteDataSource remoteDataSource;

  CrmBillingContractsRepository({
    CrmBillingContractsRemoteDataSource? remoteDataSource,
  }) : remoteDataSource =
            remoteDataSource ?? CrmBillingContractsRemoteDataSource();

  @override
  Stream<Either<Failure, List<CrmBillingContractModel>>>
      watchBillingContracts() {
    return remoteDataSource.watchBillingContracts();
  }

  @override
  Future<Either<Failure, List<CrmBillingContractModel>>> getBillingContracts() {
    return remoteDataSource.getBillingContracts();
  }

  @override
  Future<Either<Failure, CrmBillingContractModel>> createBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  }) {
    return remoteDataSource.createBillingContract(
      item: item,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> updateBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  }) {
    return remoteDataSource.updateBillingContract(
      item: item,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, String>> uploadContentFile({
    required String controlId,
    required String field,
    required List<int> bytes,
    required String fileName,
  }) {
    return remoteDataSource.uploadContentFile(
      controlId: controlId,
      field: field,
      bytes: bytes,
      fileName: fileName,
    );
  }

  @override
  Future<Either<Failure, void>> deleteBillingContract({
    required String id,
    required String changedBy,
  }) {
    return remoteDataSource.deleteBillingContract(
      id: id,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> toggleBillingContractStatus({
    required String id,
    required bool isActive,
    required String changedBy,
  }) {
    return remoteDataSource.toggleBillingContractStatus(
      id: id,
      isActive: isActive,
      changedBy: changedBy,
    );
  }
}
