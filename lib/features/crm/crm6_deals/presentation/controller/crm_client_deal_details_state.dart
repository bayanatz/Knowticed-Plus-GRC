// ****************** FILE INFO ******************
// File Name: crm_client_deal_details_state.dart
// Purpose: State for a persisted client deal details record.
// Author: Mohand Adel
// Created At: 30/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';

class CrmClientDealDetailsState {
  final bool isLoading;
  final bool isSaving;
  final CrmClientDealRecordModel? deal;
  final List<CrmDealStageModel> stages;
  final String? errorMessage;
  const CrmClientDealDetailsState(
      {this.isLoading = false,
      this.isSaving = false,
      this.deal,
      this.stages = const <CrmDealStageModel>[],
      this.errorMessage});
  CrmClientDealDetailsState copyWith(
          {bool? isLoading,
          bool? isSaving,
          CrmClientDealRecordModel? deal,
          List<CrmDealStageModel>? stages,
          String? errorMessage,
          bool clearError = false}) =>
      CrmClientDealDetailsState(
          isLoading: isLoading ?? this.isLoading,
          isSaving: isSaving ?? this.isSaving,
          deal: deal ?? this.deal,
          stages: stages ?? this.stages,
          errorMessage:
              clearError ? null : (errorMessage ?? this.errorMessage));
}
