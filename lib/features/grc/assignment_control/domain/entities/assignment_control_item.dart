import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';

/// One row on the Champion's Assignment Controls list: a Control this
/// champion is assigned to, its (possibly absent) Assignment_Controls
/// submission, and the tab it currently belongs to.
class AssignmentControlItem {
  final ControlEntity control;
  final AssignmentControlEntity? assignment;
  final AssignmentControlTab tab;

  const AssignmentControlItem({
    required this.control,
    required this.assignment,
    required this.tab,
  });
}
