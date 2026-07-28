/// Module: Approvals (Department Manager)
/// Description: Pure join/derivation logic for the manager's Approvals
///              list, and the Chief-title Department Manager resolution
///              used at Champion submit time — no persistence, no side
///              effects. See docs/superpowers/specs/2026-07-28-approvals-design.md.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'approval_entity.dart';
import 'approval_item.dart';
import 'approval_status.dart';

/// Finds the Department Manager for [championEmail]: another employee
/// sharing the champion's `departmentId` whose `title` starts with "Chief"
/// (case-insensitive). Returns null if the champion isn't found, has no
/// department, or no such peer exists — a valid, expected outcome (the
/// submission still succeeds with `Department_Manager` left null).
String? findDepartmentManagerEmail(
  List<EmployeeEntityPro> employees, {
  required String championEmail,
}) {
  EmployeeEntityPro? champion;
  for (final e in employees) {
    if (e.email == championEmail) {
      champion = e;
      break;
    }
  }
  final departmentId = champion?.departmentId;
  if (departmentId == null) return null;

  for (final e in employees) {
    if (e.email == championEmail) continue;
    if (e.departmentId != departmentId) continue;
    if (e.title?.trim().toLowerCase().startsWith('chief') ?? false) {
      return e.email;
    }
  }
  return null;
}

/// Joins every Pending [approvals] entry with its linked
/// [assignmentControls] (keyed by Assignment_Controls doc id, i.e.
/// [ApprovalEntity.submissionId]), keeping only the ones whose Assignment
/// Control's `departmentManager` matches [managerEmail], then resolves each
/// one's Control/Policy from the already-loaded [policyControls]/[policies]
/// maps. A pair whose Assignment Control, Control, or Policy can't be found
/// is silently skipped.
List<ApprovalItem> buildApprovalItems({
  required List<ApprovalEntity> approvals,
  required Map<String, AssignmentControlEntity> assignmentControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, PolicyEntity> policies,
  required String managerEmail,
}) {
  final items = <ApprovalItem>[];
  for (final approval in approvals) {
    if (approval.status != ApprovalStatus.pending) continue;
    final assignmentControl = assignmentControls[approval.submissionId];
    if (assignmentControl == null) continue;
    if (assignmentControl.departmentManager != managerEmail) continue;
    final control = findControlInPolicy(
      policyControls,
      assignmentControl.policyId,
      assignmentControl.controlId,
    );
    if (control == null) continue;
    final policy = policies[assignmentControl.policyId];
    if (policy == null) continue;
    items.add(ApprovalItem(
      approval: approval,
      assignmentControl: assignmentControl,
      control: control,
      policy: policy,
    ));
  }
  return items;
}
