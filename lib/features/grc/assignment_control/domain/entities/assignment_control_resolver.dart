/// Module: Assignment Controls (Control Champion)
/// Description: Pure join/derivation logic for the Champion's Assignment
///              Controls list — no persistence, no side effects. See
///              docs/superpowers/specs/2026-07-27-assignment-controls-champion-design.md
///              Section "Building the champion's list".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
library;

import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'assignment_control_entity.dart';
import 'assignment_control_item.dart';
import 'assignment_control_status.dart';
import 'assignment_control_tab.dart';

/// Derives which tab [control] currently belongs to for this champion.
/// [assignment] is null when no Assignment_Controls document has ever been
/// created for this control+champion pair yet (nothing submitted).
AssignmentControlTab computeAssignmentControlTab({
  required ControlEntity control,
  required AssignmentControlEntity? assignment,
}) {
  if (assignment == null) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfEnd =
        DateTime(control.endDate.year, control.endDate.month, control.endDate.day);
    return startOfEnd.isBefore(startOfToday)
        ? AssignmentControlTab.overdue
        : AssignmentControlTab.pending;
  }

  switch (assignment.status) {
    case AssignmentControlStatus.submitted:
      return AssignmentControlTab.submitted;
    case AssignmentControlStatus.inReview:
      return AssignmentControlTab.inReview;
    case AssignmentControlStatus.rejected:
      return AssignmentControlTab.rejected;
    case AssignmentControlStatus.approved:
      return AssignmentControlTab.approved;
    case AssignmentControlStatus.pending:
    case AssignmentControlStatus.overdue:
      // Never actually persisted by this feature — defensive fallback only.
      return AssignmentControlTab.pending;
  }
}

/// Joins a champion's [assigningControls] with the already-loaded
/// [policyControls] (policyId -> its Controls) and [existingAssignments]
/// (controlId -> that control's Assignment_Controls doc, if any) into the
/// list of rows the Assignment Controls page renders. A pair whose Control
/// can't be found (e.g. deleted) is silently skipped.
List<AssignmentControlItem> buildAssignmentControlItems({
  required List<AssigningControlEntity> assigningControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, AssignmentControlEntity> existingAssignments,
}) {
  final items = <AssignmentControlItem>[];
  for (final ac in assigningControls) {
    final control = findControlInPolicy(policyControls, ac.policyId, ac.controlId);
    if (control == null) continue;
    final assignment = existingAssignments[ac.controlId];
    items.add(AssignmentControlItem(
      control: control,
      assignment: assignment,
      tab: computeAssignmentControlTab(control: control, assignment: assignment),
    ));
  }
  return items;
}

/// Finds the email of the Control Owner currently covering [policyId] +
/// [controlId], mirroring how a Champion is resolved for the same pair.
/// Returns null if no owner covers it (Control_Owner then stays null on the
/// created Assignment_Controls document).
String? findOwnerEmailForControl(
  List<OwnerEntity> owners, {
  required String policyId,
  required String controlId,
}) {
  for (final owner in owners) {
    final matches = owner.assigningControls
        .any((ac) => ac.policyId == policyId && ac.controlId == controlId);
    if (matches) return owner.ownerEmail;
  }
  return null;
}
