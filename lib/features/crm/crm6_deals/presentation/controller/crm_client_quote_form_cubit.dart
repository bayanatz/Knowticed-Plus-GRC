// ****************** FILE INFO ******************
// File Name: crm_client_quote_form_cubit.dart
// Purpose: Loads deal snapshots and persists client quote drafts or submissions.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/domain/interfaces/crm_terms_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_quotes_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_form_state.dart';

class CrmClientQuoteFormCubit extends Cubit<CrmClientQuoteFormState> {
  final CrmClientDealsBaseRepository _deals;
  final CrmClientQuotesBaseRepository _quotes;
  final CrmTermsBaseRepository _terms;
  CrmClientQuoteFormCubit(
      {CrmClientDealsBaseRepository? deals,
      CrmClientQuotesBaseRepository? quotes,
      CrmTermsBaseRepository? terms})
      : _deals = deals ?? Get.find<CrmClientDealsBaseRepository>(),
        _quotes = quotes ?? Get.find<CrmClientQuotesBaseRepository>(),
        _terms = terms ?? Get.find<CrmTermsBaseRepository>(),
        super(CrmClientQuoteFormState.initial());

  Future<void> load(
      {required String clientId,
      required String dealId,
      String? sourceQuoteId}) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final Either<Failure, CrmClientDealRecordModel?> dealResult =
        await _deals.watchClientDeal(clientId: clientId, dealId: dealId).first;
    final Either<Failure, List<CrmTermModel>> termsResult =
        await _terms.watchTerms().first;
    final Either<Failure, CrmClientQuoteRecordModel?>? sourceResult =
        sourceQuoteId == null || sourceQuoteId.isEmpty
            ? null
            : await _quotes
                .watchClientDealQuote(
                    clientId: clientId, dealId: dealId, quoteId: sourceQuoteId)
                .first;
    dealResult.fold(
        (failure) => emit(
            state.copyWith(isLoading: false, errorMessage: failure.errMessage)),
        (deal) {
      termsResult.fold(
          (failure) => emit(state.copyWith(
              isLoading: false, errorMessage: failure.errMessage)), (groups) {
        final CrmTermModel? payment = _findGroup(groups, 'payment_terms');
        final CrmTermModel? delivery = _findGroup(groups, 'delivery_terms');
        final CrmClientQuoteRecordModel? source =
            sourceResult?.fold((_) => null, (quote) => quote);
        if (sourceResult != null && source == null) {
          emit(state.copyWith(
              isLoading: false, errorMessage: 'Source quote was not found.'));
        } else if (deal == null || deal.status == 'archived') {
          emit(state.copyWith(
              isLoading: false,
              errorMessage: 'The client deal is unavailable for quotes.'));
        } else {
          emit(state.copyWith(
              isLoading: false,
              deal: deal,
              sourceQuote: source,
              paymentGroup: payment,
              deliveryGroup: delivery,
              paymentClauseId: source?.paymentTerm['Clause_Id']?.toString(),
              deliveryClauseId: source?.deliveryTerm['Clause_Id']?.toString(),
              validUntil: source?.validUntil,
              noteEn: source?.noteEn,
              noteAr: source?.noteAr,
              attachments: source?.attachments,
              clearMessages: true));
        }
      });
    });
  }

  void setPaymentClause(String? id) =>
      emit(state.copyWith(paymentClauseId: id ?? '', clearMessages: true));
  void setDeliveryClause(String? id) =>
      emit(state.copyWith(deliveryClauseId: id ?? '', clearMessages: true));
  void setValidUntil(DateTime value) =>
      emit(state.copyWith(validUntil: value, clearMessages: true));
  void setNotes({required String noteEn, required String noteAr}) =>
      emit(state.copyWith(noteEn: noteEn, noteAr: noteAr, clearMessages: true));
  void addAttachmentMetadata(Map<String, dynamic> attachment) =>
      emit(state.copyWith(
          attachments: <Map<String, dynamic>>[...state.attachments, attachment],
          clearMessages: true));

  Future<bool> save({required bool submit, required String userId}) async {
    if (state.isSaving) {
      return false;
    }
    final String? validation = _validationError(submit);
    if (validation != null) {
      emit(state.copyWith(
        submissionStatus: CrmQuoteSubmissionStatus.error,
        errorMessage: validation,
      ));
      return false;
    }
    final CrmClientDealRecordModel deal = state.deal!;
    final CrmClientQuoteRecordModel? source = state.sourceQuote;
    final String auditUser = userId.trim().isEmpty ? 'system' : userId.trim();
    emit(state.copyWith(
      submissionStatus: CrmQuoteSubmissionStatus.loading,
      clearMessages: true,
    ));
    final CrmClientQuoteRecordModel quote = CrmClientQuoteRecordModel(
      id: '',
      clientId: deal.clientId,
      dealId: deal.id,
      quoteNo: '',
      status: submit ? 'pending' : 'draft',
      quoteFamilyId: source?.quoteFamilyId ?? '',
      sourceQuoteId: source?.id,
      version: (source?.version ?? 0) + 1,
      quoteDate: DateTime.now(),
      validUntil: state.validUntil,
      currency: source?.currency ?? deal.currency,
      productLines: source?.productLines ?? deal.productLines,
      serviceLines: source?.serviceLines ?? deal.serviceLines,
      subtotal: source?.subtotal ?? deal.subtotal,
      discountTotal: source?.discountTotal ?? deal.discountTotal,
      taxTotal: source?.taxTotal ?? deal.taxTotal,
      grandTotal: source?.grandTotal ?? deal.grandTotal,
      paymentTerm: state.paymentGroup != null &&
              state.paymentClauseId != null &&
              state.paymentClauseId!.isNotEmpty
          ? _termSnapshot(state.paymentGroup!, state.paymentClauseId!)
          : const <String, dynamic>{},
      deliveryTerm: state.deliveryGroup != null &&
              state.deliveryClauseId != null &&
              state.deliveryClauseId!.isNotEmpty
          ? _termSnapshot(state.deliveryGroup!, state.deliveryClauseId!)
          : const <String, dynamic>{},
      noteEn: state.noteEn.trim(),
      noteAr: state.noteAr.trim(),
      attachments: state.attachments,
      createdAt: DateTime.now(),
      createdBy: auditUser,
    );
    final Either<Failure, CrmClientQuoteRecordModel> result =
        await _quotes.createClientDealQuote(quote: quote);
    return result.fold((failure) {
      emit(state.copyWith(
        submissionStatus: CrmQuoteSubmissionStatus.error,
        errorMessage: failure.errMessage,
      ));
      return false;
    }, (saved) {
      emit(state.copyWith(
        submissionStatus: CrmQuoteSubmissionStatus.success,
        successMessage: saved.quoteNo,
      ));
      return true;
    });
  }

  CrmTermModel? _findGroup(List<CrmTermModel> terms, String key) => terms
      .cast<CrmTermModel?>()
      .firstWhere((group) => group!.systemKey == key, orElse: () => null);
  String? _validationError(bool submit) {
    if (state.deal == null) {
      return 'Deal data is still loading.';
    }
    if (!submit) {
      return null;
    }
    if (state.paymentGroup == null || state.paymentGroup!.clauses.isEmpty) {
      return 'Payment Terms are not configured.';
    }
    if (state.deliveryGroup == null || state.deliveryGroup!.clauses.isEmpty) {
      return 'Delivery Terms are not configured.';
    }
    if (state.paymentClauseId == null ||
        state.paymentClauseId!.isEmpty ||
        state.deliveryClauseId == null ||
        state.deliveryClauseId!.isEmpty) {
      return 'Select payment and delivery terms.';
    }
    if (state.validUntil.isBefore(DateTime.now())) {
      return 'Quote validity date must be in the future.';
    }
    return null;
  }

  Map<String, dynamic> _termSnapshot(CrmTermModel group, String clauseId) {
    final CrmTermClauseModel clause =
        group.clauses.firstWhere((item) => item.id == clauseId);
    return <String, dynamic>{
      'Group_Id': group.id,
      'System_Key': group.systemKey,
      'Group_Name_En': group.nameEn,
      'Group_Name_Ar': group.nameAr,
      'Clause_Id': clause.id,
      'Text_En': clause.textEn,
      'Text_Ar': clause.textAr,
      'Order': clause.order
    };
  }
}
