// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type_model.dart
// Purpose: Firestore DTO for CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';

/// Serializes a [CrmTeamType] to and from its Firestore representation.
class CrmTeamTypeModel {
  static const String _id = 'Id';
  static const String _nameEn = 'Name_En';
  static const String _nameAr = 'Name_Ar';
  static const String _noteEn = 'Note_En';
  static const String _noteAr = 'Note_Ar';
  static const String _isActive = 'Is_Active';
  static const String _isDeleted = 'Is_Deleted';
  static const String _updatedAt = 'Updated_At';
  static const String _updatedBy = 'Updated_By';

  final CrmTeamType teamType;

  const CrmTeamTypeModel(this.teamType);

  /// Converts this DTO into a Firestore-safe map.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _id: teamType.id,
        _nameEn: teamType.nameEn,
        _nameAr: teamType.nameAr,
        _noteEn: teamType.noteEn,
        _noteAr: teamType.noteAr,
        _isActive: teamType.isActive,
        _isDeleted: teamType.isDeleted,
        _updatedAt: teamType.updatedAt.toIso8601String(),
        _updatedBy: teamType.updatedBy,
      };

  /// Creates a DTO from a Firestore document map.
  factory CrmTeamTypeModel.fromMap(Map<String, dynamic> map) =>
      CrmTeamTypeModel(
        CrmTeamType(
          id: (map[_id] ?? '').toString(),
          nameEn: (map[_nameEn] ?? '').toString(),
          nameAr: (map[_nameAr] ?? '').toString(),
          noteEn: (map[_noteEn] ?? '').toString(),
          noteAr: (map[_noteAr] ?? '').toString(),
          isActive: map[_isActive] != false,
          isDeleted: map[_isDeleted] == true,
          updatedAt: DateTime.tryParse((map[_updatedAt] ?? '').toString()) ??
              DateTime.now(),
          updatedBy: (map[_updatedBy] ?? '').toString(),
        ),
      );

  /// Returns a DTO for a modified entity.
  CrmTeamTypeModel copyWith({CrmTeamType? teamType}) =>
      CrmTeamTypeModel(teamType ?? this.teamType);
}
