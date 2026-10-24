// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_base_repository.dart
// Purpose: Feature-facing repository contract for CRM Billing & Contracts
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';

abstract class CrmBillingContractsBaseRepository {
  Stream<Either<Failure, List<CrmBillingContractModel>>>
      watchBillingContracts();

  Future<Either<Failure, List<CrmBillingContractModel>>> getBillingContracts();

  Future<Either<Failure, CrmBillingContractModel>> createBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  });

  Future<Either<Failure, void>> updateBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  });

  Future<Either<Failure, String>> uploadContentFile({
    required String controlId,
    required String field,
    required List<int> bytes,
    required String fileName,
  });

  Future<Either<Failure, void>> deleteBillingContract({
    required String id,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleBillingContractStatus({
    required String id,
    required bool isActive,
    required String changedBy,
  });
}
