// ****************** FILE INFO ******************
// File Name: crm_client_quotes_repository.dart
// Purpose: Repository facade for client-deal quote persistence.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/data_source/crm_client_quotes_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_quotes_base_repository.dart';

class CrmClientQuotesRepository implements CrmClientQuotesBaseRepository {
  final CrmClientQuotesRemoteDataSource _source;
  CrmClientQuotesRepository({CrmClientQuotesRemoteDataSource? source})
      : _source = source ?? CrmClientQuotesRemoteDataSource();
  @override
  Stream<Either<Failure, List<CrmClientQuoteRecordModel>>>
      watchClientDealQuotes(
              {required String clientId, required String dealId}) =>
          _source.watchClientDealQuotes(clientId: clientId, dealId: dealId);
  @override
  Stream<Either<Failure, CrmClientQuoteRecordModel?>> watchClientDealQuote(
          {required String clientId,
          required String dealId,
          required String quoteId}) =>
      _source.watchClientDealQuote(
          clientId: clientId, dealId: dealId, quoteId: quoteId);
  @override
  Stream<Either<Failure, List<CrmClientQuoteRecordModel>>>
      watchDealQuoteRequests(
              {required String clientId, required String dealId}) =>
          _source.watchClientDealQuotes(clientId: clientId, dealId: dealId);
  @override
  Future<Either<Failure, CrmClientQuoteRecordModel>> createClientDealQuote(
          {required CrmClientQuoteRecordModel quote}) =>
      _source.createClientDealQuote(quote: quote);
  @override
  Future<Either<Failure, void>> updateClientDealQuote({
    required CrmClientQuoteRecordModel quote,
    required String changedBy,
  }) =>
      _source.updateClientDealQuote(quote: quote, changedBy: changedBy);
  @override
  Future<Either<Failure, void>> updateQuoteStatus(
          {required String clientId,
          required String dealId,
          required String quoteId,
          required String status,
          required String changedBy}) =>
      _source.updateQuoteStatus(
          clientId: clientId,
          dealId: dealId,
          quoteId: quoteId,
          status: status,
          changedBy: changedBy);
  @override
  Future<Either<Failure, void>> decideQuoteRequest({
    required String clientId,
    required String dealId,
    required String quoteId,
    required String decision,
    required String rejectReason,
    required String decidedBy,
  }) =>
      _source.decideQuoteRequest(
        clientId: clientId,
        dealId: dealId,
        quoteId: quoteId,
        decision: decision,
        rejectReason: rejectReason,
        decidedBy: decidedBy,
      );
  @override
  Future<Either<Failure, void>> deleteQuote(
          {required String clientId,
          required String dealId,
          required String quoteId,
          required String changedBy}) =>
      _source.deleteQuote(
          clientId: clientId,
          dealId: dealId,
          quoteId: quoteId,
          changedBy: changedBy);
}
