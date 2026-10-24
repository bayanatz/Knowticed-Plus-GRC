// ****************** FILE INFO ******************
// File Name: crm_client_quote_details_cubit.dart
// Purpose: Loads and updates one persisted client-deal quote.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_quotes_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_details_state.dart';

class CrmClientQuoteDetailsCubit extends Cubit<CrmClientQuoteDetailsState> {
  final CrmClientQuotesBaseRepository _repository;
  StreamSubscription<Either<Failure, CrmClientQuoteRecordModel?>>?
      _subscription;
  StreamSubscription<Either<Failure, List<CrmClientQuoteRecordModel>>>?
      _versionsSubscription;
  CrmClientQuoteDetailsCubit({CrmClientQuotesBaseRepository? repository})
      : _repository = repository ?? Get.find<CrmClientQuotesBaseRepository>(),
        super(const CrmClientQuoteDetailsState());

  void load(
      {required String clientId,
      required String dealId,
      required String quoteId}) {
    emit(state.copyWith(
        operation: CrmQuoteDetailsOperation.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository
        .watchClientDealQuote(
            clientId: clientId, dealId: dealId, quoteId: quoteId)
        .listen((result) {
      result.fold(
          (failure) => emit(state.copyWith(
              operation: CrmQuoteDetailsOperation.error,
              errorMessage: failure.errMessage)), (quote) {
        if (quote == null) {
          emit(state.copyWith(
              operation: CrmQuoteDetailsOperation.error,
              errorMessage: 'Quote not found.'));
        } else {
          emit(state.copyWith(
              operation: CrmQuoteDetailsOperation.idle,
              quote: quote,
              clearError: true));
          _watchVersions(quote);
        }
      });
    });
  }

  void _watchVersions(CrmClientQuoteRecordModel quote) {
    _versionsSubscription?.cancel();
    _versionsSubscription = _repository
        .watchClientDealQuotes(clientId: quote.clientId, dealId: quote.dealId)
        .listen((result) {
      result.fold((_) {}, (quotes) {
        final List<CrmClientQuoteRecordModel> versions = quotes
            .where((item) => item.quoteFamilyId == quote.quoteFamilyId)
            .toList()
          ..sort((a, b) => b.version.compareTo(a.version));
        emit(state.copyWith(versions: versions));
      });
    });
  }

  Future<bool> saveEdit(
      {required DateTime validUntil,
      required String noteEn,
      required String noteAr,
      required Map<String, dynamic> paymentTerm,
      required Map<String, dynamic> deliveryTerm,
      required List<Map<String, dynamic>> attachments,
      required String changedBy}) async {
    final CrmClientQuoteRecordModel? current = state.quote;
    if (current == null || state.isSaving) return false;
    emit(state.copyWith(
        operation: CrmQuoteDetailsOperation.saving, clearError: true));
    final CrmClientQuoteRecordModel updated = CrmClientQuoteRecordModel(
      id: current.id,
      clientId: current.clientId,
      dealId: current.dealId,
      quoteNo: current.quoteNo,
      quoteFamilyId: current.quoteFamilyId,
      sourceQuoteId: current.sourceQuoteId,
      status: current.status,
      version: current.version,
      quoteDate: current.quoteDate,
      validUntil: validUntil,
      currency: current.currency,
      productLines: current.productLines,
      serviceLines: current.serviceLines,
      subtotal: current.subtotal,
      discountTotal: current.discountTotal,
      taxTotal: current.taxTotal,
      grandTotal: current.grandTotal,
      paymentTerm: paymentTerm,
      deliveryTerm: deliveryTerm,
      noteEn: noteEn.trim(),
      noteAr: noteAr.trim(),
      attachments: attachments,
      createdAt: current.createdAt,
      createdBy: current.createdBy,
      decisionBy: current.decisionBy,
      decisionAt: current.decisionAt,
      rejectReason: current.rejectReason,
    );
    final result = await _repository.updateClientDealQuote(
        quote: updated,
        changedBy: changedBy.trim().isEmpty ? 'system' : changedBy.trim());
    return result.fold((failure) {
      emit(state.copyWith(
          operation: CrmQuoteDetailsOperation.error,
          errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(
          operation: CrmQuoteDetailsOperation.success, quote: updated));
      return true;
    });
  }

  Future<bool> updateStatus(String status, String changedBy) async {
    final quote = state.quote;
    if (quote == null || state.isSaving) return false;
    emit(state.copyWith(
        operation: CrmQuoteDetailsOperation.saving, clearError: true));
    final result = await _repository.updateQuoteStatus(
        clientId: quote.clientId,
        dealId: quote.dealId,
        quoteId: quote.id,
        status: status,
        changedBy: changedBy);
    return result.fold((failure) {
      emit(state.copyWith(
          operation: CrmQuoteDetailsOperation.error,
          errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(operation: CrmQuoteDetailsOperation.success));
      return true;
    });
  }

  Future<bool> decideRequest({
    required String decision,
    required String rejectReason,
    required String decidedBy,
  }) async {
    final CrmClientQuoteRecordModel? quote = state.quote;
    if (quote == null || quote.status != 'pending' || state.isSaving) {
      return false;
    }
    emit(state.copyWith(
        operation: CrmQuoteDetailsOperation.saving, clearError: true));
    final result = await _repository.decideQuoteRequest(
      clientId: quote.clientId,
      dealId: quote.dealId,
      quoteId: quote.id,
      decision: decision,
      rejectReason: rejectReason,
      decidedBy: decidedBy.trim().isEmpty ? 'system' : decidedBy.trim(),
    );
    return result.fold((Failure failure) {
      emit(state.copyWith(
          operation: CrmQuoteDetailsOperation.error,
          errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(operation: CrmQuoteDetailsOperation.success));
      return true;
    });
  }

  Future<bool> delete(String changedBy) async {
    final quote = state.quote;
    if (quote == null || state.isSaving) return false;
    emit(state.copyWith(
        operation: CrmQuoteDetailsOperation.saving, clearError: true));
    final result = await _repository.deleteQuote(
        clientId: quote.clientId,
        dealId: quote.dealId,
        quoteId: quote.id,
        changedBy: changedBy.trim().isEmpty ? 'system' : changedBy.trim());
    return result.fold((failure) {
      emit(state.copyWith(
          operation: CrmQuoteDetailsOperation.error,
          errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(operation: CrmQuoteDetailsOperation.success));
      return true;
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _versionsSubscription?.cancel();
    return super.close();
  }
}
