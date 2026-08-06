import 'package:grc_module/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'my_audit_entity.dart';
import 'my_audit_tab.dart';

/// One row on the Control Owner's My Audits list. [audit] and
/// [assignmentControl] are both null only for a derived-Overdue row (the
/// Champion never submitted, so no Approval/My_Audit chain exists yet) —
/// there is nothing to open or act on for those.
class MyAuditItem {
  final MyAuditEntity? audit;
  final AssignmentControlEntity? assignmentControl;
  final ControlEntity control;
  final PolicyEntity policy;
  final MyAuditTab tab;

  const MyAuditItem({
    required this.audit,
    required this.assignmentControl,
    required this.control,
    required this.policy,
    required this.tab,
  });
}
