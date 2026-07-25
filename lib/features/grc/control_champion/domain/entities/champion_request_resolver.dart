/// Module: Control Champion Management
/// Description: Pure "would-be" decisions for the Champion Reassignment
///              Request workflow — mirrors control_status_resolver.dart's
///              shape. No persistence, no side effects: callers (Champion
///              Cubit) are responsible for acting on what these return.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestEntity, ApprovalStatus, AssigningControlEntity, ChampionEntity
library;

import 'package:demo_app/core/enums/approval_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';

/// function name: [findDueReassignmentRequests]
///
/// purpose: from a module's full request list, find every approved,
///          not-yet-applied Reassign Control Champion request whose Start
///          Date has arrived (today >= startDate, compared at day
///          granularity) — these are the requests a caller must apply.
///
/// parameters:
///            [List<GrcRequestEntity>] requests: every request for one module
///
/// return type: [List<GrcRequestEntity>] - requests ready to be applied
List<GrcRequestEntity> findDueReassignmentRequests(
  List<GrcRequestEntity> requests,
) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return requests.where((r) {
    if (r.type != GrcRequestType.reassignChampion) return false;
    if (r.status != ApprovalStatus.approved) return false;
    if (r.appliedAt != null) return false;
    final startDate = r.startDate;
    if (startDate == null) return false;
    final startOfStart = DateTime(startDate.year, startDate.month, startDate.day);
    return !startOfStart.isAfter(startOfToday);
  }).toList();
}

/// function name: [findExpiredControls]
///
/// purpose: from one Champion's current assigned controls, find every
///          control whose [AssigningControlEntity.expiresOn] has passed
///          (today >= expiresOn, compared at day granularity) — these must
///          be stripped so the control becomes unassigned.
///
/// parameters:
///            [ChampionEntity] champion: the champion whose controls to check
///
/// return type: [List<AssigningControlEntity>] - controls that have expired
List<AssigningControlEntity> findExpiredControls(ChampionEntity champion) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return champion.assigningControls.where((c) {
    final expiresOn = c.expiresOn;
    if (expiresOn == null) return false;
    final startOfExpiry = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return !startOfExpiry.isAfter(startOfToday);
  }).toList();
}
