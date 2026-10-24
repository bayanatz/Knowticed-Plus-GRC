// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class ControlOwnerData {
  EmployeeEntityPro employee;
  List<String> policies;
  List<String> controls;
  Map<String, List<String>> policyControlMap;

  ControlOwnerData({
    required this.employee,
    required this.policies,
    required this.controls,
    required this.policyControlMap,
  });
}
