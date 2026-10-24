// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commissions_cubit.dart
// Purpose: Owns commission package streaming, filtering, and deletion
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/interfaces/crm_commissions_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commissions_state.dart';

class CrmCommissionsCubit extends Cubit<CrmCommissionsState> {
  final CrmCommissionsBaseRepository _repository;
  StreamSubscription<List<CrmCommissionPackage>>? _subscription;

  CrmCommissionsCubit({required CrmCommissionsBaseRepository repository})
      : _repository = repository,
        super(const CrmCommissionsState());

  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchPackages().listen(
      (List<CrmCommissionPackage> packages) {
        if (!isClosed) {
          emit(state.copyWith(packages: packages, isLoading: false));
        }
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
  }

  void search(String query) => emit(state.copyWith(query: query));
  void setCategory(String category) => emit(state.copyWith(category: category));
  void setSort(String? sort) => emit(state.copyWith(selectedSort: sort));
  void clearError() => emit(state.copyWith(clearError: true));

  Future<bool> deletePackage(CrmCommissionPackage package) async {
    try {
      await _repository
          .deletePackage(package.copyWith(updatedAt: DateTime.now()));
      return true;
    } catch (error) {
      if (!isClosed) emit(state.copyWith(errorMessage: error.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
