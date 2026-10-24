// ****************** FILE INFO ******************
// File Name: crm_client_deals_base_repository.dart
// Purpose: Contract for persisted deals owned by a CRM client record.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';

abstract class CrmClientDealsBaseRepository {
  Stream<Either<Failure, List<CrmClientDealRecordModel>>> watchClientDeals(
      {required String clientId});
  Stream<Either<Failure, CrmClientDealRecordModel?>> watchClientDeal(
      {required String clientId, required String dealId});
  Future<Either<Failure, CrmClientDealRecordModel>> createClientDeal(
      {required CrmClientDealRecordModel deal});
  Future<Either<Failure, CrmClientDealRecordModel>> updateClientDeal(
      {required CrmClientDealRecordModel deal});
  Future<Either<Failure, Unit>> moveClientDealStage(
      {required String clientId,
      required String dealId,
      required String stageId,
      required String stageNameEn,
      required String stageNameAr,
      required String changedBy});
  Future<Either<Failure, Unit>> updateChecklistProgress(
      {required String clientId,
      required String dealId,
      required List<Map<String, dynamic>> checklist,
      required String changedBy});
  Future<Either<Failure, Unit>> archiveClientDeal(
      {required String clientId, required String dealId});
}
