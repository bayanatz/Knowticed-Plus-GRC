// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_sets_cubit.dart
// Purpose: Owns filtering and sorting for CRM reason-set categories
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reason_sets_state.dart';

class CrmReasonSetsCubit extends Cubit<CrmReasonSetsState> {
  CrmReasonSetsCubit()
      : super(const CrmReasonSetsState(reasonSets: _reasonSets));

  static const List<CrmReasonSetDefinition> _reasonSets =
      <CrmReasonSetDefinition>[
    CrmReasonSetDefinition(id: 'Remove_Clients', title: 'Remove Clients'),
    CrmReasonSetDefinition(id: 'Delete_Deal', title: 'Delete Deal'),
    CrmReasonSetDefinition(id: 'Delete_Quotation', title: 'Delete Quotation'),
    CrmReasonSetDefinition(id: 'Reject_Request', title: 'Reject Request'),
    CrmReasonSetDefinition(id: 'Cancel_Activity', title: 'Cancel Activity'),
    CrmReasonSetDefinition(id: 'Block', title: 'Block'),
  ];

  void search(String query) => emit(state.copyWith(query: query));
  void setSort(String? sort) => emit(state.copyWith(selectedSort: sort));
}
