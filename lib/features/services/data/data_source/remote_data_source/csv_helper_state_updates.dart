/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: csv_helper_state_updates.dart
/// Purpose: Declares employeeFunctionHelper (the signed-in employee).
///          updateRequestState, updateApprovalState and
///          changeStateToInProgress were unused and are deleted (rule
///          "Remove dead or unused code").
/// Author: Amr Mesbah
/// Created At: 30/8/2025

part of 'csv_helper.dart';

//////////////////////////////////////////////////////////////////////////////////

EmployeeEntityPro get employeeFunctionHelper {
  final controller = AppControllers.employee;
  if (controller.employeeEntity == null) {
    throw Exception('EmployeeEntity is not initialized yet');
  }
  return controller.employeeEntity!;
}
