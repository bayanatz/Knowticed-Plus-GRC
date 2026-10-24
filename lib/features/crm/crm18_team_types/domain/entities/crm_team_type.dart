// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type.dart
// Purpose: Immutable business entity for a reusable CRM team type
// Author: Mohand Adel
// Created At: 08/10/2026

/// Represents one configurable type that can be assigned to CRM teams.
class CrmTeamType {
  final String id;
  final String nameEn;
  final String nameAr;
  final String noteEn;
  final String noteAr;
  final bool isActive;
  final bool isDeleted;
  final DateTime updatedAt;
  final String updatedBy;

  const CrmTeamType({
    this.id = '',
    this.nameEn = '',
    this.nameAr = '',
    this.noteEn = '',
    this.noteAr = '',
    this.isActive = true,
    this.isDeleted = false,
    required this.updatedAt,
    this.updatedBy = '',
  });

  /// Returns an immutable copy with the provided values replaced.
  CrmTeamType copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? noteEn,
    String? noteAr,
    bool? isActive,
    bool? isDeleted,
    DateTime? updatedAt,
    String? updatedBy,
  }) =>
      CrmTeamType(
        id: id ?? this.id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        noteEn: noteEn ?? this.noteEn,
        noteAr: noteAr ?? this.noteAr,
        isActive: isActive ?? this.isActive,
        isDeleted: isDeleted ?? this.isDeleted,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );
}
