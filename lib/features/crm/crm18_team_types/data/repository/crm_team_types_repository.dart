// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_types_repository.dart
// Purpose: Repository implementation for CRM team type data
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm18_team_types/data/data_source/crm_team_types_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/interfaces/crm_team_types_base_repository.dart';

/// Bridges the Team Types cubits and their Firestore data source.
class CrmTeamTypesRepository implements CrmTeamTypesBaseRepository {
  final CrmTeamTypesRemoteDataSource _remoteDataSource;

  CrmTeamTypesRepository({CrmTeamTypesRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CrmTeamTypesRemoteDataSource();

  @override
  Stream<List<CrmTeamType>> watchTeamTypes() =>
      _remoteDataSource.watchTeamTypes();

  @override
  Future<void> createTeamType(CrmTeamType teamType) =>
      _remoteDataSource.createTeamType(teamType);

  @override
  Future<void> updateTeamType(CrmTeamType teamType) =>
      _remoteDataSource.updateTeamType(teamType);

  @override
  Future<void> deleteTeamType(CrmTeamType teamType) =>
      _remoteDataSource.deleteTeamType(teamType);
}
