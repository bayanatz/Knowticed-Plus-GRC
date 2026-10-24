// ****************** FILE INFO ******************
// File Name: crm_client_deal_details_cubit.dart
// Purpose: Controls live client deal details, stage moves, progress, and archive.
// Author: Mohand Adel
// Created At: 30/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_deals_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_details_state.dart';

class CrmClientDealDetailsCubit extends Cubit<CrmClientDealDetailsState> {
  final CrmClientDealsBaseRepository _clientDeals;
  final CrmDealsBaseRepository _deals;
  StreamSubscription<Either<Failure, CrmClientDealRecordModel?>>?
      _dealSubscription;
  StreamSubscription<Either<Failure, List<CrmDealStageModel>>>?
      _stagesSubscription;
  String _clientId = '';
  String _dealId = '';
  CrmClientDealDetailsCubit(
      {CrmClientDealsBaseRepository? clientDeals,
      CrmDealsBaseRepository? deals})
      : _clientDeals = clientDeals ?? Get.find<CrmClientDealsBaseRepository>(),
        _deals = deals ?? Get.find<CrmDealsBaseRepository>(),
        super(const CrmClientDealDetailsState());

  void init({required String clientId, required String dealId}) {
    _clientId = clientId;
    _dealId = dealId;
    _emit(state.copyWith(isLoading: true, clearError: true));
    _dealSubscription = _clientDeals
        .watchClientDeal(clientId: clientId, dealId: dealId)
        .listen((Either<Failure, CrmClientDealRecordModel?> result) =>
            result.fold(
                (Failure failure) => _emit(state.copyWith(
                    isLoading: false, errorMessage: failure.message)),
                (CrmClientDealRecordModel? deal) => _emit(state.copyWith(
                    isLoading: false,
                    deal: deal,
                    errorMessage:
                        deal == null ? 'Deal was not found.' : null))));
    _stagesSubscription = _deals.watchStages().listen(
        (Either<Failure, List<CrmDealStageModel>> result) =>
            result.fold((_) {}, (List<CrmDealStageModel> stages) {
              final active = stages
                  .where((CrmDealStageModel item) =>
                      item.isActive && !item.isDeleted)
                  .toList()
                ..sort((a, b) => a.order.compareTo(b.order));
              _emit(state.copyWith(stages: active));
            }));
  }

  Future<void> moveStage(CrmDealStageModel stage) async {
    _emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _clientDeals.moveClientDealStage(
        clientId: _clientId,
        dealId: _dealId,
        stageId: stage.id,
        stageNameEn: stage.nameEn,
        stageNameAr: stage.nameAr,
        changedBy: _userEmail);
    result.fold(
        (Failure failure) => _emit(
            state.copyWith(isSaving: false, errorMessage: failure.message)),
        (_) => _emit(state.copyWith(isSaving: false)));
  }

  Future<void> toggleChecklist(int index) async {
    final CrmClientDealRecordModel? deal = state.deal;
    if (deal == null || index < 0 || index >= deal.checklist.length) return;
    final checklist = deal.checklist
        .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
    checklist[index]['Completed'] = checklist[index]['Completed'] != true;
    _emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _clientDeals.updateChecklistProgress(
        clientId: _clientId,
        dealId: _dealId,
        checklist: checklist,
        changedBy: _userEmail);
    result.fold(
        (Failure failure) => _emit(
            state.copyWith(isSaving: false, errorMessage: failure.message)),
        (_) => _emit(state.copyWith(isSaving: false)));
  }

  Future<bool> archive() async {
    _emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _clientDeals.archiveClientDeal(
        clientId: _clientId, dealId: _dealId);
    return result.fold((Failure failure) {
      _emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      return false;
    }, (_) {
      _emit(state.copyWith(isSaving: false));
      return true;
    });
  }

  String get _userEmail => Get.isRegistered<MainCoreEmployeeController>()
      ? Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? ''
      : '';
  void _emit(CrmClientDealDetailsState value) {
    if (!isClosed) emit(value);
  }

  @override
  Future<void> close() {
    _dealSubscription?.cancel();
    _stagesSubscription?.cancel();
    return super.close();
  }
}
