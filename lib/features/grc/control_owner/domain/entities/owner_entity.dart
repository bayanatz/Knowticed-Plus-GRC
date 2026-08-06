// lib/features/grc/control_owner/domain/entities/owner_entity.dart
/// Module: Control Owner Management
/// Description: Flat (non-list) representation of a Control Owner record,
///              derived from the latest revision of [OwnerModel].
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlEntity, OwnerStatus

import 'package:grc_module/features/grc/control/domain/entities/assigning_control.dart';
import 'owner_status.dart';

/// class name: [OwnerEntity]
///
/// purpose: holds the current (latest) values of a Control Owner record.
///          [controlOwnerPermissions] is current-state only (not history)
///          and is positionally parallel to [assigningControls] —
///          controlOwnerPermissions[i] belongs to assigningControls[i].
class OwnerEntity {
  final String ownerEmail;
  final List<AssigningControlEntity> assigningControls;
  final List<List<String>> controlOwnerPermissions;
  final OwnerStatus status;

  // Tracking fields (latest values only)
  final DateTime createdAt;
  final DateTime modificationDate;
  final String lastModifier;

  const OwnerEntity({
    required this.ownerEmail,
    required this.assigningControls,
    required this.controlOwnerPermissions,
    required this.status,
    required this.createdAt,
    required this.modificationDate,
    required this.lastModifier,
  });
}
