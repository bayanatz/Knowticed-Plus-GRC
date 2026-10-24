// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_cubit.dart
// Purpose: Streams and filters CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/interfaces/crm_team_types_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_types_state.dart';

/// Coordinates the Team Types live list, filters, and soft deletion.
class CrmTeamTypesCubit extends Cubit<CrmTeamTypesState> {
  final CrmTeamTypesBaseRepository _repository;
  StreamSubscription<List<CrmTeamType>>? _subscription;

  CrmTeamTypesCubit({required CrmTeamTypesBaseRepository repository})
      : _repository = repository,
        super(const CrmTeamTypesState());

  /// Starts the live Team Types subscription.
  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchTeamTypes().listen(
      (List<CrmTeamType> items) {
        if (!isClosed) {
          emit(state.copyWith(items: items, isLoading: false));
        }
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
            state.copyWith(isLoading: false, errorMessage: error.toString()),
          );
        }
      },
    );
  }

  /// Filters list entries by their English or Arabic name.
  void search(String value) => emit(state.copyWith(query: value));

  /// Filters list entries by their activation status.
  void setStatus(String value) => emit(state.copyWith(status: value));

  /// Clears an error after it is surfaced by the page.
  void clearError() => emit(state.copyWith(clearError: true));

  /// Soft deletes [teamType], emitting a recoverable error when it fails.
  Future<bool> deleteTeamType(CrmTeamType teamType) async {
    try {
      await _repository
          .deleteTeamType(teamType.copyWith(updatedAt: DateTime.now()));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: error.toString()));
      }
      return false;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
