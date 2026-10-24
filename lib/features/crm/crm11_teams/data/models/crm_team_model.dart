// ****************** FILE INFO ******************
// File Name: crm_team_model.dart
// Purpose: Main CRM Team model with serialization and validation logic.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_condition_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_member_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/entities/crm_team_entity.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/domain/enums/crm_team_status_enum.dart';

class CrmTeamModel extends CrmTeamEntity {
  static const String kId = 'id';
  static const String kTeamType = 'teamType';
  static const String kNameEn = 'nameEn';
  static const String kNameAr = 'nameAr';
  static const String kManager = 'manager';
  static const String kMembers = 'members';
  static const String kNoteEn = 'noteEn';
  static const String kNoteAr = 'noteAr';
  static const String kConditions = 'conditions';
  static const String kStatus = 'status';
  static const String kCreatedAt = 'createdAt';
  static const String kUpdatedAt = 'updatedAt';

  const CrmTeamModel({
    required super.id,
    required super.teamType,
    required super.nameEn,
    required super.nameAr,
    super.manager,
    super.members = const <CrmTeamMemberModel>[],
    super.noteEn = '',
    super.noteAr = '',
    super.conditions = const <CrmTeamConditionModel>[],
    super.status = CrmTeamStatus.active,
    required super.createdAt,
    required super.updatedAt,
  });

  bool get isActive => status == CrmTeamStatus.active;
  bool get isInactive => status == CrmTeamStatus.inactive;
  String get displayName => nameEn.isNotEmpty ? nameEn : nameAr;
  int get membersCount => members.length;

  /// Returns condition value for a given category (or 'Choose' / empty).
  String getConditionValue(String category) {
    for (final condition in conditions) {
      if (condition.category.toLowerCase() == category.toLowerCase()) {
        return condition.value;
      }
    }
    return 'Choose';
  }

  /// Returns condition priority for a given category.
  String getConditionPriority(String category) {
    for (final condition in conditions) {
      if (condition.category.toLowerCase() == category.toLowerCase()) {
        return condition.priority;
      }
    }
    return 'Choose';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      kId: id,
      kTeamType: teamType,
      kNameEn: nameEn,
      kNameAr: nameAr,
      kManager: manager != null
          ? (manager is CrmTeamMemberModel
              ? (manager as CrmTeamMemberModel).toMap()
              : CrmTeamMemberModel.fromEntity(manager!).toMap())
          : null,
      kMembers: members
          .map((m) => m is CrmTeamMemberModel
              ? m.toMap()
              : CrmTeamMemberModel.fromEntity(m).toMap())
          .toList(),
      kNoteEn: noteEn,
      kNoteAr: noteAr,
      kConditions: conditions
          .map((c) => c is CrmTeamConditionModel
              ? c.toMap()
              : CrmTeamConditionModel.fromEntity(c).toMap())
          .toList(),
      kStatus: status.code,
      kCreatedAt: createdAt.toIso8601String(),
      kUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  factory CrmTeamModel.fromMap(Map<String, dynamic> map) {
    CrmTeamMemberModel? mgr;
    if (map[kManager] is Map<String, dynamic>) {
      mgr = CrmTeamMemberModel.fromMap(map[kManager] as Map<String, dynamic>);
    }

    final List<CrmTeamMemberModel> mbrs = <CrmTeamMemberModel>[];
    if (map[kMembers] is List) {
      for (final dynamic item in map[kMembers] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          mbrs.add(CrmTeamMemberModel.fromMap(item));
        }
      }
    }

    final List<CrmTeamConditionModel> conds = <CrmTeamConditionModel>[];
    if (map[kConditions] is List) {
      for (final dynamic item in map[kConditions] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          conds.add(CrmTeamConditionModel.fromMap(item));
        }
      }
    }

    return CrmTeamModel(
      id: map[kId]?.toString() ?? '',
      teamType: map[kTeamType]?.toString() ?? 'Sales',
      nameEn: map[kNameEn]?.toString() ?? '',
      nameAr: map[kNameAr]?.toString() ?? '',
      manager: mgr,
      members: mbrs,
      noteEn: map[kNoteEn]?.toString() ?? '',
      noteAr: map[kNoteAr]?.toString() ?? '',
      conditions: conds,
      status: CrmTeamStatus.fromString(map[kStatus]?.toString()),
      createdAt: map[kCreatedAt] != null
          ? DateTime.tryParse(map[kCreatedAt].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map[kUpdatedAt] != null
          ? DateTime.tryParse(map[kUpdatedAt].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CrmTeamModel copyWith({
    String? id,
    String? teamType,
    String? nameEn,
    String? nameAr,
    CrmTeamMemberModel? manager,
    List<CrmTeamMemberModel>? members,
    String? noteEn,
    String? noteAr,
    List<CrmTeamConditionModel>? conditions,
    CrmTeamStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrmTeamModel(
      id: id ?? this.id,
      teamType: teamType ?? this.teamType,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      manager: manager ?? (this.manager as CrmTeamMemberModel?),
      members: members ??
          this.members.map((m) => CrmTeamMemberModel.fromEntity(m)).toList(),
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      conditions: conditions ??
          this
              .conditions
              .map((c) => CrmTeamConditionModel.fromEntity(c))
              .toList(),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
