// ****************** FILE INFO ******************
// File Name: crm_quotes_cubit.dart
// Purpose: Controller Cubit for Deal Quotes managing filtering, search, view mode, and compare selection
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_quotes_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_quotes_state.dart';

class CrmQuotesCubit extends Cubit<CrmQuotesState> {
  final CrmClientQuotesBaseRepository _repository;
  StreamSubscription<Either<Failure, List<CrmClientQuoteRecordModel>>>?
      _subscription;
  CrmQuotesCubit({CrmClientQuotesBaseRepository? repository})
      : _repository = repository ?? Get.find<CrmClientQuotesBaseRepository>(),
        super(const CrmQuotesState());

  void init({required String clientId, required String dealId}) {
    emit(state.copyWith(isLoading: true));
    _subscription?.cancel();
    _subscription = _repository
        .watchClientDealQuotes(clientId: clientId, dealId: dealId)
        .listen((result) {
      result.fold(
          (failure) => emit(state.copyWith(
              isLoading: false, errorMessage: failure.errMessage)), (records) {
        final List<CrmQuoteModel> quotes =
            records.map(_toPresentation).toList();
        emit(state.copyWith(
            isLoading: false,
            allQuotes: quotes,
            filteredQuotes: _filtered(quotes, state),
            clearError: true));
      });
    });
  }

  void filterByStatus(CrmQuoteStatus status) {
    emit(state.copyWith(selectedStatus: status));
    _applyFilters();
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void setViewMode({required bool isGridView}) {
    emit(state.copyWith(isGridView: isGridView));
  }

  void toggleCompareMode() {
    final bool nextMode = !state.isCompareMode;
    emit(state.copyWith(
      isCompareMode: nextMode,
      selectedQuoteIds: nextMode ? state.selectedQuoteIds : const <String>{},
    ));
  }

  bool toggleQuoteSelection(String quoteId) {
    final Set<String> updated = Set<String>.from(state.selectedQuoteIds);
    if (updated.contains(quoteId)) {
      updated.remove(quoteId);
      emit(state.copyWith(selectedQuoteIds: updated));
      return true;
    } else {
      if (updated.length >= 3) {
        return false;
      }
      updated.add(quoteId);
      emit(state.copyWith(selectedQuoteIds: updated));
      return true;
    }
  }

  void toggleSelectAll() {
    if (state.selectedQuoteIds.length == state.filteredQuotes.length &&
        state.filteredQuotes.isNotEmpty) {
      emit(state.copyWith(selectedQuoteIds: const <String>{}));
    } else {
      final Set<String> allIds =
          state.filteredQuotes.map((CrmQuoteModel q) => q.id).toSet();
      emit(state.copyWith(selectedQuoteIds: allIds));
    }
  }

  void _applyFilters() {
    emit(state.copyWith(filteredQuotes: _filtered(state.allQuotes, state)));
  }

  List<CrmQuoteModel> _filtered(
      List<CrmQuoteModel> source, CrmQuotesState sourceState) {
    List<CrmQuoteModel> list = List<CrmQuoteModel>.from(source);

    // Status filter
    if (sourceState.selectedStatus != CrmQuoteStatus.all) {
      list = list
          .where(
              (CrmQuoteModel q) => q.clientStatus == sourceState.selectedStatus)
          .toList();
    }

    // Search query
    final String query = sourceState.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((CrmQuoteModel q) {
        return q.quoteNo.toLowerCase().contains(query) ||
            q.clientStatus.labelEn.toLowerCase().contains(query) ||
            q.approvalStatus.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  CrmQuoteModel _toPresentation(CrmClientQuoteRecordModel quote) {
    final CrmQuoteStatus status = switch (quote.status) {
      'draft' => CrmQuoteStatus.draft,
      'pending' => CrmQuoteStatus.pending,
      'approved' => CrmQuoteStatus.approved,
      'adjustment' => CrmQuoteStatus.adjustment,
      'reject' => CrmQuoteStatus.reject,
      _ => CrmQuoteStatus.expired,
    };
    final Map<String, dynamic> product = quote.productLines.isEmpty
        ? const <String, dynamic>{}
        : quote.productLines.first;
    final Map<String, dynamic> service = quote.serviceLines.isEmpty
        ? const <String, dynamic>{}
        : quote.serviceLines.first;
    return CrmQuoteModel(
        id: quote.id,
        no: quote.createdAt.millisecondsSinceEpoch,
        quoteNo: quote.quoteNo,
        version: '${quote.version}',
        clientStatus: status,
        approvalStatus: status.labelEn,
        approvalStatusColor: status.color,
        validUntil:
            '${quote.validUntil.day}/${quote.validUntil.month}/${quote.validUntil.year}',
        createdDate:
            '${quote.quoteDate.day}/${quote.quoteDate.month}/${quote.quoteDate.year}',
        total: quote.grandTotal,
        totalFormatted:
            '${quote.currency} ${quote.grandTotal.toStringAsFixed(2)}',
        productsCategory: '${product['Category_Name_En'] ?? ''}',
        products: '${product['Name_En'] ?? product['Product_Name_En'] ?? ''}',
        qty: (product['Quantity'] as num?)?.toInt() ?? 0,
        productDiscount:
            '${product['Discount_Percentage'] ?? product['Discount'] ?? 0}%',
        productTax: '${product['Tax_Amount'] ?? product['Tax'] ?? 0}',
        productTotal: '${product['Line_Total'] ?? product['Total'] ?? 0}',
        servicesCategory: '${service['Category_Name_En'] ?? ''}',
        services: '${service['Name_En'] ?? service['Service_Name_En'] ?? ''}',
        serviceDiscount:
            '${service['Discount_Percentage'] ?? service['Discount'] ?? 0}%',
        serviceTax: '${service['Tax_Amount'] ?? service['Tax'] ?? 0}',
        serviceTotal: '${service['Line_Total'] ?? service['Total'] ?? 0}',
        paymentTerms: '${quote.paymentTerm['Text_En'] ?? ''}',
        deliveryTerms: '${quote.deliveryTerm['Text_En'] ?? ''}',
        noteEn: quote.noteEn,
        noteAr: quote.noteAr);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
