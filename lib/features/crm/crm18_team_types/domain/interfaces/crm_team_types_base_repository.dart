// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_base_repository.dart
// Purpose: Contract for CRM team type persistence
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';

/// Abstract persistence boundary consumed by the Team Types cubits.
abstract class CrmTeamTypesBaseRepository {
  /// Streams every non-deleted team type.
  Stream<List<CrmTeamType>> watchTeamTypes();

  /// Creates a new team type.
  Future<void> createTeamType(CrmTeamType teamType);

  /// Updates an existing team type.
  Future<void> updateTeamType(CrmTeamType teamType);

  /// Soft deletes an existing team type.
  Future<void> deleteTeamType(CrmTeamType teamType);
}
