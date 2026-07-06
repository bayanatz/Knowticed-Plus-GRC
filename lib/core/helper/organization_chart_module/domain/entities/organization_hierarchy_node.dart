
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/new_employee_model.dart';

class OrganizationHierarchyNode {
  NewEmployeeModelHistory employee;
  final List<OrganizationHierarchyNode> children = [];

  OrganizationHierarchyNode({required this.employee});
}
