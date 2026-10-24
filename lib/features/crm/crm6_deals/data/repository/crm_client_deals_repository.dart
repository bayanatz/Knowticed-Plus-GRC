// ****************** FILE INFO ******************
// File Name: crm_client_deals_repository.dart
// Purpose: Repository facade for client deal transaction persistence.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/data_source/crm_client_deals_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';

class CrmClientDealsRepository implements CrmClientDealsBaseRepository {
  final CrmClientDealsRemoteDataSource _source;
  CrmClientDealsRepository({CrmClientDealsRemoteDataSource? source})
      : _source = source ?? CrmClientDealsRemoteDataSource();
  @override
  Stream<Either<Failure, List<CrmClientDealRecordModel>>> watchClientDeals(
          {required String clientId}) =>
      _source.watchClientDeals(clientId: clientId);
  @override
  Stream<Either<Failure, CrmClientDealRecordModel?>> watchClientDeal(
          {required String clientId, required String dealId}) =>
      _source.watchClientDeal(clientId: clientId, dealId: dealId);
  @override
  Future<Either<Failure, CrmClientDealRecordModel>> createClientDeal(
          {required CrmClientDealRecordModel deal}) =>
      _source.createClientDeal(deal: deal);
  @override
  Future<Either<Failure, CrmClientDealRecordModel>> updateClientDeal(
          {required CrmClientDealRecordModel deal}) =>
      _source.updateClientDeal(deal: deal);
  @override
  Future<Either<Failure, Unit>> moveClientDealStage(
          {required String clientId,
          required String dealId,
          required String stageId,
          required String stageNameEn,
          required String stageNameAr,
          required String changedBy}) =>
      _source.moveClientDealStage(
          clientId: clientId,
          dealId: dealId,
          stageId: stageId,
          stageNameEn: stageNameEn,
          stageNameAr: stageNameAr,
          changedBy: changedBy);
  @override
  Future<Either<Failure, Unit>> updateChecklistProgress(
          {required String clientId,
          required String dealId,
          required List<Map<String, dynamic>> checklist,
          required String changedBy}) =>
      _source.updateChecklistProgress(
          clientId: clientId,
          dealId: dealId,
          checklist: checklist,
          changedBy: changedBy);
  @override
  Future<Either<Failure, Unit>> archiveClientDeal(
          {required String clientId, required String dealId}) =>
      _source.archiveClientDeal(clientId: clientId, dealId: dealId);
}
