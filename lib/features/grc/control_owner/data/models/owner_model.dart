// lib/features/grc/control_owner/data/models/owner_model.dart
/// Module: Control Owner Management
/// Description: Defines the Model used to persist Control Owner records,
///              where every field except [controlOwnerPermissions] is
///              stored as a history List, exactly like GRCModuleModel.
///              Firestore path:
///              GRC Modules/{Module_ID}/Control Owners/{Owner_Email}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: AssigningControlModel, OwnerEntity, OwnerStatus, intl

import 'package:intl/intl.dart';
import 'package:demo_app/features/grc/control/data/models/assigning_control_model.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_status.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

/// class name: [OwnerModel]
///
/// purpose: represents a Control Owner record. [assigningControls],
///          [status], [modificationDate], [modifiers] are history Lists
///          (index i = one revision), exactly like ChampionModel.
///          [controlOwnerPermissions] is NOT a history list — it always
///          holds the CURRENT permissions, one inner List<String> per
///          control in the latest revision's assigningControls, in the
///          same order (controlOwnerPermissions[i] belongs to
///          assigningControls.last[i]).
class OwnerModel {
  final String ownerEmail;
  final List<List<AssigningControlModel>> assigningControls;
  final List<String> status; // 'Active' | 'Removed'
  final List<List<String>> controlOwnerPermissions;
  final List<DateTime> modificationDate;
  final List<String> modifiers;

  OwnerModel({
    required this.ownerEmail,
    required this.assigningControls,
    required this.status,
    required this.controlOwnerPermissions,
    required this.modificationDate,
    required this.modifiers,
  }) {
    assert(
      _allSameLength(),
      'All OwnerModel history Lists must have the same number of elements (same index count)',
    );
    assert(
      controlOwnerPermissions.length == assigningControls.last.length,
      'controlOwnerPermissions must have exactly one entry per control in the latest Assigning_Controls revision',
    );
  }

  bool _allSameLength() {
    final lengths = <int>{
      assigningControls.length,
      status.length,
      modificationDate.length,
      modifiers.length,
    };
    return lengths.length == 1;
  }

  factory OwnerModel.create({
    required String ownerEmail,
    required List<AssigningControlModel> initialAssigningControls,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    return OwnerModel(
      ownerEmail: ownerEmail,
      assigningControls: [initialAssigningControls],
      status: const ['Active'],
      controlOwnerPermissions: List<List<String>>.generate(
        initialAssigningControls.length,
        (_) => <String>[],
      ),
      modificationDate: [now],
      modifiers: [modifierEmail],
    );
  }

  /// Matches each entry of [newControls] against the CURRENT (pre-update)
  /// assigningControls.last by (policyId, controlId) and carries over that
  /// control's existing permissions; a control with no match (newly added)
  /// defaults to an empty permissions list.
  List<List<String>> _carryOverPermissions(List<AssigningControlModel> newControls) {
    final previousControls = assigningControls.last;
    return newControls.map((newControl) {
      final oldIndex = previousControls.indexWhere(
        (old) =>
            old.policyId == newControl.policyId &&
            old.controlId == newControl.controlId,
      );
      if (oldIndex == -1 || oldIndex >= controlOwnerPermissions.length) {
        return <String>[];
      }
      return controlOwnerPermissions[oldIndex];
    }).toList();
  }

  /// Appends a new revision. If [assigningControls] changes and
  /// [controlOwnerPermissions] is not explicitly passed, permissions are
  /// carried over via [_carryOverPermissions]; otherwise the existing
  /// permissions are kept as-is.
  OwnerModel copyWithUpdate({
    List<AssigningControlModel>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    String? status,
    required String modifierEmail,
  }) {
    final now = DateTime.now();
    final newAssigningControls = assigningControls ?? this.assigningControls.last;
    final newPermissions = controlOwnerPermissions ??
        (assigningControls == null
            ? this.controlOwnerPermissions
            : _carryOverPermissions(newAssigningControls));
    return OwnerModel(
      ownerEmail: ownerEmail,
      assigningControls: [...this.assigningControls, newAssigningControls],
      status: [...this.status, status ?? this.status.last],
      controlOwnerPermissions: newPermissions,
      modificationDate: [...modificationDate, now],
      modifiers: [...modifiers, modifierEmail],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Owner_Email': ownerEmail,
      'Assigning_Controls': assigningControls
          .map((rev) => {'Items': rev.map((a) => a.toJson()).toList()})
          .toList(),
      'Owners_Status': status,
      'Control_Owners_Permissions':
          controlOwnerPermissions.map((perms) => {'Items': perms}).toList(),
      'Modification_Date':
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      'Modifiers': modifiers,
    };
  }

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      ownerEmail: json['Owner_Email'] as String,
      assigningControls: (json['Assigning_Controls'] as List? ?? [])
          .map((rev) =>
              ((rev as Map<String, dynamic>)['Items'] as List? ?? [])
                  .map((item) => AssigningControlModel.fromJson(
                      item as Map<String, dynamic>))
                  .toList())
          .toList(),
      status: List<String>.from(json['Owners_Status'] ?? []),
      controlOwnerPermissions: (json['Control_Owners_Permissions'] as List? ?? [])
          .map((entry) =>
              List<String>.from((entry as Map<String, dynamic>)['Items'] ?? []))
          .toList(),
      modificationDate: (json['Modification_Date'] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      modifiers: List<String>.from(json['Modifiers'] ?? []),
    );
  }

  OwnerEntity toEntity() {
    return OwnerEntity(
      ownerEmail: ownerEmail,
      assigningControls:
          assigningControls.last.map((a) => a.toEntity()).toList(),
      controlOwnerPermissions: controlOwnerPermissions,
      status: OwnerStatus.fromString(status.last),
      createdAt: modificationDate.first,
      modificationDate: modificationDate.last,
      lastModifier: modifiers.last,
    );
  }
}
