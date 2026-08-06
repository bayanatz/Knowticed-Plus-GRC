
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';

class OrganizationHierarchyNode {
  NewEmployeeModelHistory employee;
  final List<OrganizationHierarchyNode> children = [];

  OrganizationHierarchyNode({required this.employee});
}
