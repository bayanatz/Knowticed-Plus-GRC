// ****************** FILE INFO ******************
// File Name: crm_client_quote_details_state.dart
// Purpose: Live details and edit state for one persisted client quote.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';

enum CrmQuoteDetailsOperation { idle, loading, saving, success, error }

class CrmClientQuoteDetailsState {
  final CrmQuoteDetailsOperation operation;
  final CrmClientQuoteRecordModel? quote;
  final List<CrmClientQuoteRecordModel> versions;
  final String? errorMessage;
  const CrmClientQuoteDetailsState(
      {this.operation = CrmQuoteDetailsOperation.idle,
      this.quote,
      this.versions = const <CrmClientQuoteRecordModel>[],
      this.errorMessage});
  bool get isLoading => operation == CrmQuoteDetailsOperation.loading;
  bool get isSaving => operation == CrmQuoteDetailsOperation.saving;
  CrmClientQuoteDetailsState copyWith(
          {CrmQuoteDetailsOperation? operation,
          CrmClientQuoteRecordModel? quote,
          List<CrmClientQuoteRecordModel>? versions,
          String? errorMessage,
          bool clearError = false}) =>
      CrmClientQuoteDetailsState(
          operation: operation ?? this.operation,
          quote: quote ?? this.quote,
          versions: versions ?? this.versions,
          errorMessage: clearError ? null : errorMessage ?? this.errorMessage);
}
