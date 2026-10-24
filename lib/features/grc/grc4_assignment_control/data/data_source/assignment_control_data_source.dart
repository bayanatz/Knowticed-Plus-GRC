import 'package:knowticed_plus/features/grc/grc4_assignment_control/data/models/assignment_control_model.dart';

abstract class AssignmentControlDataSource {
  Future<AssignmentControlModel?> get(String id, {required String moduleId});

  Future<AssignmentControlModel> create(
    AssignmentControlModel model, {
    required String moduleId,
  });

  Future<AssignmentControlModel> update(
    AssignmentControlModel model, {
    required String moduleId,
  });
}
