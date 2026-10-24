// ****************** FILE INFO ******************
// File Name: crm_client_quotes_base_repository.dart
// Purpose: Contract for persisted quotes scoped to one client deal.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';

abstract class CrmClientQuotesBaseRepository {
  Stream<Either<Failure, List<CrmClientQuoteRecordModel>>>
      watchClientDealQuotes({required String clientId, required String dealId});
  Stream<Either<Failure, CrmClientQuoteRecordModel?>> watchClientDealQuote(
      {required String clientId,
      required String dealId,
      required String quoteId});
  Stream<Either<Failure, List<CrmClientQuoteRecordModel>>>
      watchDealQuoteRequests(
          {required String clientId, required String dealId});
  Future<Either<Failure, CrmClientQuoteRecordModel>> createClientDealQuote(
      {required CrmClientQuoteRecordModel quote});
  Future<Either<Failure, void>> updateClientDealQuote({
    required CrmClientQuoteRecordModel quote,
    required String changedBy,
  });
  Future<Either<Failure, void>> updateQuoteStatus(
      {required String clientId,
      required String dealId,
      required String quoteId,
      required String status,
      required String changedBy});
  Future<Either<Failure, void>> decideQuoteRequest({
    required String clientId,
    required String dealId,
    required String quoteId,
    required String decision,
    required String rejectReason,
    required String decidedBy,
  });
  Future<Either<Failure, void>> deleteQuote(
      {required String clientId,
      required String dealId,
      required String quoteId,
      required String changedBy});
}
