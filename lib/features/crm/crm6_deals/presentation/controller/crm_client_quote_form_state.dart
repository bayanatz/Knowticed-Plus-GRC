// ****************** FILE INFO ******************
// File Name: crm_client_quote_form_state.dart
// Purpose: Immutable state for the persisted client quote wizard.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';

enum CrmQuoteSubmissionStatus { idle, loading, success, error }

class CrmClientQuoteFormState {
  final bool isLoading;
  final CrmQuoteSubmissionStatus submissionStatus;
  final CrmClientDealRecordModel? deal;
  final CrmClientQuoteRecordModel? sourceQuote;
  final CrmTermModel? paymentGroup;
  final CrmTermModel? deliveryGroup;
  final String? paymentClauseId;
  final String? deliveryClauseId;
  final DateTime validUntil;
  final String noteEn;
  final String noteAr;
  final List<Map<String, dynamic>> attachments;
  final String? errorMessage;
  final String? successMessage;

  const CrmClientQuoteFormState({
    this.isLoading = false,
    this.submissionStatus = CrmQuoteSubmissionStatus.idle,
    this.deal,
    this.sourceQuote,
    this.paymentGroup,
    this.deliveryGroup,
    this.paymentClauseId,
    this.deliveryClauseId,
    required this.validUntil,
    this.noteEn = '',
    this.noteAr = '',
    this.attachments = const <Map<String, dynamic>>[],
    this.errorMessage,
    this.successMessage,
  });

  bool get isSaving => submissionStatus == CrmQuoteSubmissionStatus.loading;

  factory CrmClientQuoteFormState.initial() => CrmClientQuoteFormState(
      validUntil: DateTime.now().add(const Duration(days: 7)));

  CrmClientQuoteFormState copyWith({
    bool? isLoading,
    CrmQuoteSubmissionStatus? submissionStatus,
    CrmClientDealRecordModel? deal,
    CrmClientQuoteRecordModel? sourceQuote,
    CrmTermModel? paymentGroup,
    CrmTermModel? deliveryGroup,
    String? paymentClauseId,
    String? deliveryClauseId,
    DateTime? validUntil,
    String? noteEn,
    String? noteAr,
    List<Map<String, dynamic>>? attachments,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      CrmClientQuoteFormState(
          isLoading: isLoading ?? this.isLoading,
          submissionStatus: submissionStatus ?? this.submissionStatus,
          deal: deal ?? this.deal,
          sourceQuote: sourceQuote ?? this.sourceQuote,
          paymentGroup: paymentGroup ?? this.paymentGroup,
          deliveryGroup: deliveryGroup ?? this.deliveryGroup,
          paymentClauseId: paymentClauseId ?? this.paymentClauseId,
          deliveryClauseId: deliveryClauseId ?? this.deliveryClauseId,
          validUntil: validUntil ?? this.validUntil,
          noteEn: noteEn ?? this.noteEn,
          noteAr: noteAr ?? this.noteAr,
          attachments: attachments ?? this.attachments,
          errorMessage:
              clearMessages ? null : errorMessage ?? this.errorMessage,
          successMessage:
              clearMessages ? null : successMessage ?? this.successMessage);
}
