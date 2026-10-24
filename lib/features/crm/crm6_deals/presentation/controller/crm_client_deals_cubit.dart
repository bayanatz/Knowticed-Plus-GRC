// ****************** FILE INFO ******************
// File Name: crm_client_deals_cubit.dart
// Purpose: Cubit managing CRM Client Deals UI state, searching, sorting, filtering, and view toggles
// Author: Mohand Adel
// Created At: 29/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deals_state.dart';

class CrmClientDealsCubit extends Cubit<CrmClientDealsState> {
  final String? clientId;
  final CrmClientDealsBaseRepository _repository;
  final CrmDealsBaseRepository _dealsRepository;
  StreamSubscription<Either<Failure, List<CrmClientDealRecordModel>>>?
      _subscription;
  StreamSubscription<Either<Failure, List<CrmDealStageModel>>>?
      _stagesSubscription;

  CrmClientDealsCubit({
    this.clientId,
    CrmClientDealsBaseRepository? repository,
    CrmDealsBaseRepository? dealsRepository,
  })  : _repository = repository ?? Get.find<CrmClientDealsBaseRepository>(),
        _dealsRepository =
            dealsRepository ?? Get.find<CrmDealsBaseRepository>(),
        super(const CrmClientDealsState());

  /// Function Name: init
  ///
  /// Purpose: Initializes the client deals stream and dynamic deal stages from Controls.
  void init() {
    _watchStages();
    if (clientId == null || clientId!.isEmpty) {
      return;
    }
    emit(state.copyWith(isLoading: true));
    _subscription?.cancel();
    _subscription = _repository.watchClientDeals(clientId: clientId!).listen(
      (Either<Failure, List<CrmClientDealRecordModel>> result) {
        result.fold(
          (Failure failure) {
            if (!isClosed) {
              emit(state.copyWith(isLoading: false));
            }
          },
          (List<CrmClientDealRecordModel> records) => _setDeals(records),
        );
      },
    );
  }

  List<CrmClientDealRecordModel> _cachedRecords =
      const <CrmClientDealRecordModel>[];

  void _watchStages() {
    _stagesSubscription?.cancel();
    _stagesSubscription = _dealsRepository.watchStages().listen(
      (Either<Failure, List<CrmDealStageModel>> result) {
        result.fold(
          (_) {},
          (List<CrmDealStageModel> stages) {
            if (!isClosed) {
              final List<CrmDealStageModel> activeStages = stages
                  .where((CrmDealStageModel s) => s.isActive && !s.isDeleted)
                  .toList()
                ..sort((CrmDealStageModel a, CrmDealStageModel b) =>
                    a.order.compareTo(b.order));
              emit(state.copyWith(stages: activeStages));
              if (_cachedRecords.isNotEmpty) {
                _setDeals(_cachedRecords);
              }
            }
          },
        );
      },
    );
  }

  void _setDeals(List<CrmClientDealRecordModel> records) {
    _cachedRecords = records;
    final List<CrmClientDealModel> rawDeals =
        records.map(_toPresentationModel).toList();
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: rawDeals,
      query: state.searchQuery,
      sort: state.sortOption,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(
      state.copyWith(
        isLoading: false,
        deals: rawDeals,
        filteredDeals: filtered,
        totalDeals: rawDeals.length,
        wonDeals: rawDeals
            .where((CrmClientDealModel deal) => deal.stage == 'won')
            .length,
        lostDeals: rawDeals
            .where((CrmClientDealModel deal) => deal.stage == 'lost')
            .length,
        totalValue: _money(rawDeals
            .where((CrmClientDealModel deal) => deal.stage == 'active')
            .fold<double>(
                0,
                (double total, CrmClientDealModel deal) =>
                    total + deal.expectedValue)),
        revenue: _money(rawDeals
            .where((CrmClientDealModel deal) => deal.stage == 'won')
            .fold<double>(
                0,
                (double total, CrmClientDealModel deal) =>
                    total + deal.amount)),
      ),
    );
  }

  CrmClientDealModel _toPresentationModel(CrmClientDealRecordModel record) {
    // 1. Top Percentage: Single Stage Likelihood / Probability (نسبة اكتمال المرحلة الواحدة)
    double stageProb = record.likelihood;
    if (state.stages.isNotEmpty) {
      for (final CrmDealStageModel s in state.stages) {
        if (s.id.toLowerCase() == record.currentStageId.toLowerCase() ||
            s.nameEn.toLowerCase() == record.stageNameEn.toLowerCase() ||
            s.id.toLowerCase() == record.status.toLowerCase()) {
          stageProb = s.probability.toDouble();
          break;
        }
      }
    }

    // 2. Bottom Progress Bar: Overall Deal Progress across ALL stages / tasks (نسبة الاكتمال على مستوى المراحل كلها)
    double computedProgress = 0.0;
    if (record.checklist.isNotEmpty) {
      final int completed = record.checklist
          .where((Map<String, dynamic> item) =>
              item['Completed'] == true || item['completed'] == true)
          .length;
      computedProgress = (completed / record.checklist.length) * 100.0;
    } else if (state.stages.isNotEmpty) {
      int stageIndex = -1;
      for (int i = 0; i < state.stages.length; i++) {
        final CrmDealStageModel s = state.stages[i];
        if (s.id.toLowerCase() == record.currentStageId.toLowerCase() ||
            s.nameEn.toLowerCase() == record.stageNameEn.toLowerCase() ||
            s.id.toLowerCase() == record.status.toLowerCase()) {
          stageIndex = i;
          break;
        }
      }
      if (stageIndex >= 0) {
        computedProgress = ((stageIndex + 1) / state.stages.length) * 100.0;
      } else {
        computedProgress = stageProb > 0 ? stageProb : 5.0;
      }
    } else {
      computedProgress = stageProb > 0 ? stageProb : 5.0;
    }

    return CrmClientDealModel(
      id: record.id,
      clientId: record.clientId,
      no: 0,
      categoryId: record.categoryId,
      category: record.categoryNameEn,
      dealNameEn: record.nameEn,
      dealNameAr: record.nameAr,
      expectedValue: record.expectedValue,
      expectedValueFormatted: _money(record.expectedValue),
      currentStageId: record.currentStageId,
      stage: record.status,
      stageLabelEn: record.stageNameEn,
      stageLabelAr: record.stageNameAr,
      noteEn: record.noteEn,
      noteAr: record.noteAr,
      currency: record.currency.isNotEmpty ? record.currency : 'EGP',
      likelihood: '${stageProb.toInt()}%',
      likelihoodValue: stageProb,
      isPositiveTrend: stageProb >= 50,
      assignedEmployeeId: record.assignedEmployeeId,
      assignedEmployee: record.assignedEmployeeName,
      startDate:
          '${record.startDate.day}/${record.startDate.month}/${record.startDate.year}',
      closeDate:
          '${record.closeDate.day}/${record.closeDate.month}/${record.closeDate.year}',
      progress: computedProgress,
      amount: record.grandTotal,
      checklist: record.checklist,
      rawProductLines: record.productLines,
      rawServiceLines: record.serviceLines,
      createdAt: record.createdAt,
      products: record.productLines.map((Map<String, dynamic> line) {
        final String cat = _lineText(line, <String>[
          'Category_Name_En',
          'categoryNameEn',
          'Category_Name',
          'Category_Name_Ar',
          'Category',
        ]);
        return CrmDealProductItem(
            productName: _lineName(line, 'Product'),
            category: cat.isNotEmpty ? cat : 'Software',
            qty: (line['Quantity'] ?? line['quantity'] as num?)?.toInt() ?? 1,
            price: (line['Unit_Price'] ??
                        line['unitPrice'] ??
                        line['Price'] as num?)
                    ?.toDouble() ??
                0,
            discount: (line['Discount'] ??
                        line['discount'] ??
                        line['Discount_Value'] as num?)
                    ?.toDouble() ??
                0,
            tax: (line['Tax'] ?? line['tax'] ?? line['Tax_Rate'] as num?)
                    ?.toDouble() ??
                0,
            total: (line['Total'] ?? line['total'] as num?)?.toDouble() ?? 0);
      }).toList(),
      services: record.serviceLines.map((Map<String, dynamic> line) {
        final String cat = _lineText(line, <String>[
          'Category_Name_En',
          'categoryNameEn',
          'Category_Name',
          'Category_Name_Ar',
          'Category',
        ]);
        return CrmDealServiceItem(
            serviceName: _lineName(line, 'Service'),
            category: cat.isNotEmpty ? cat : 'Services',
            price: (line['Unit_Price'] ??
                        line['unitPrice'] ??
                        line['Price'] as num?)
                    ?.toDouble() ??
                0,
            discount: (line['Discount'] ??
                        line['discount'] ??
                        line['Discount_Value'] as num?)
                    ?.toDouble() ??
                0,
            tax: (line['Tax'] ?? line['tax'] ?? line['Tax_Rate'] as num?)
                    ?.toDouble() ??
                0,
            total: (line['Total'] ?? line['total'] as num?)?.toDouble() ?? 0);
      }).toList(),
    );
  }

  String _lineName(Map<String, dynamic> line, String type) {
    final String itemId = _lineText(line, <String>['Item_Id', 'itemId', 'Id']);
    final List<String> keys = <String>[
      '${type}_Name_En',
      '${type}_Name_Ar',
      'Item_Name_En',
      'Item_Name_Ar',
      'Name_En',
      'Name_Ar',
      'nameEn',
      'nameAr',
      'Name',
    ];
    for (final String key in keys) {
      final String value = _lineText(line, <String>[key]);
      if (value.isNotEmpty && value != itemId) return value;
    }
    return '';
  }

  String _lineText(Map<String, dynamic> line, List<String> keys) {
    for (final String key in keys) {
      final String value = '${line[key] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  /// Function Name: setSearchQuery
  ///
  /// Purpose: Filters deals by text search query.
  void setSearchQuery(String query) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: query,
      sort: state.sortOption,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(state.copyWith(searchQuery: query, filteredDeals: filtered));
  }

  /// Function Name: setSortOption
  ///
  /// Purpose: Sorts deals by 'newest' or 'oldest'.
  void setSortOption(String sort) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: sort,
      stage: state.selectedStage,
      category: state.selectedCategory,
      valFrom: state.expectedValueFrom,
      valTo: state.expectedValueTo,
      start: state.startDate,
      close: state.closeDate,
      employee: state.assignedEmployee,
    );

    emit(state.copyWith(sortOption: sort, filteredDeals: filtered));
  }

  /// Function Name: setViewMode
  ///
  /// Purpose: Toggles between Grid (Kanban Board) and Table view.
  void setViewMode({required bool isGridView}) {
    emit(state.copyWith(isGridView: isGridView));
  }

  /// Function Name: applyFilter
  ///
  /// Purpose: Applies dialog filter parameters to deals list.
  void applyFilter({
    String? stage,
    String? category,
    double? expectedValueFrom,
    double? expectedValueTo,
    DateTime? startDate,
    DateTime? closeDate,
    String? assignedEmployee,
  }) {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: state.sortOption,
      stage: stage,
      category: category,
      valFrom: expectedValueFrom,
      valTo: expectedValueTo,
      start: startDate,
      close: closeDate,
      employee: assignedEmployee,
    );

    emit(
      state.copyWith(
        selectedStage: stage,
        selectedCategory: category,
        expectedValueFrom: expectedValueFrom,
        expectedValueTo: expectedValueTo,
        startDate: startDate,
        closeDate: closeDate,
        assignedEmployee: assignedEmployee,
        filteredDeals: filtered,
      ),
    );
  }

  /// Function Name: resetFilter
  ///
  /// Purpose: Resets all active filters.
  void resetFilter() {
    final List<CrmClientDealModel> filtered = _filterAndSort(
      deals: state.deals,
      query: state.searchQuery,
      sort: state.sortOption,
    );

    emit(state.copyWith(clearFilters: true, filteredDeals: filtered));
  }

  List<CrmClientDealModel> _filterAndSort({
    required List<CrmClientDealModel> deals,
    required String query,
    required String sort,
    String? stage,
    String? category,
    double? valFrom,
    double? valTo,
    DateTime? start,
    DateTime? close,
    String? employee,
  }) {
    List<CrmClientDealModel> list = List<CrmClientDealModel>.from(deals);

    // 1. Search Query
    if (query.trim().isNotEmpty) {
      final String q = query.trim().toLowerCase();
      list = list.where((d) {
        return d.dealNameEn.toLowerCase().contains(q) ||
            d.dealNameAr.toLowerCase().contains(q) ||
            d.category.toLowerCase().contains(q) ||
            d.assignedEmployee.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Stage Filter
    if (stage != null && stage.isNotEmpty && stage.toLowerCase() != 'all') {
      list = list
          .where((CrmClientDealModel deal) =>
              deal.currentStageId.toLowerCase() == stage.toLowerCase() ||
              deal.stageLabelEn.toLowerCase() == stage.toLowerCase() ||
              deal.stageLabelAr.toLowerCase() == stage.toLowerCase())
          .toList();
    }

    // 3. Category Filter
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      list = list
          .where((d) => d.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // 4. Value From
    if (valFrom != null) {
      list = list.where((d) => d.expectedValue >= valFrom).toList();
    }

    // 5. Value To
    if (valTo != null) {
      list = list.where((d) => d.expectedValue <= valTo).toList();
    }

    // 6. Assigned Employee
    if (employee != null &&
        employee.isNotEmpty &&
        employee.toLowerCase() != 'all') {
      list = list
          .where(
              (d) => d.assignedEmployee.toLowerCase() == employee.toLowerCase())
          .toList();
    }

    // 7. Sort
    if (sort == 'oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _stagesSubscription?.cancel();
    return super.close();
  }
}
