// ****************** FILE INFO ******************
// File Name: crm_deal_requests_state.dart
// Purpose: Live state for quote approval requests scoped to one deal.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';

enum CrmDealRequestsOperation { idle, loading, error }

class CrmDealRequestsState {
  final CrmDealRequestsOperation operation;
  final List<CrmClientQuoteRecordModel> requests;
  final String errorMessage;

  const CrmDealRequestsState({
    this.operation = CrmDealRequestsOperation.idle,
    this.requests = const <CrmClientQuoteRecordModel>[],
    this.errorMessage = '',
  });

  bool get isLoading => operation == CrmDealRequestsOperation.loading;

  CrmDealRequestsState copyWith({
    CrmDealRequestsOperation? operation,
    List<CrmClientQuoteRecordModel>? requests,
    String? errorMessage,
  }) =>
      CrmDealRequestsState(
        operation: operation ?? this.operation,
        requests: requests ?? this.requests,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
