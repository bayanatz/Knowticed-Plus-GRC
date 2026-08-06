part of './main_core_employee_cubit.dart';

sealed class MainCoreEmployeeState {
  const MainCoreEmployeeState();
}

final class MainCoreEmployeeInitial extends MainCoreEmployeeState {
  const MainCoreEmployeeInitial();
}

final class MainCoreEmployeeLoading extends MainCoreEmployeeState {
  const MainCoreEmployeeLoading();
}

/// Published whenever the employee list, the signed-in employee, the role, or
/// the permission cache changes.
///
/// Deliberately NOT value-equatable: every emit must reach listeners, because
/// permission rebuilds are driven by identity, mirroring the `update()` calls
/// in the GetxController this replaced.
final class MainCoreEmployeeReady extends MainCoreEmployeeState {
  final EmployeeEntityPro? employeeEntity;
  final List<EmployeeEntityPro> allEmployees;
  final RoleHistoryModel? currentEmployeeRole;

  const MainCoreEmployeeReady({
    required this.employeeEntity,
    required this.allEmployees,
    required this.currentEmployeeRole,
  });
}

final class MainCoreEmployeeError extends MainCoreEmployeeState {
  final String message;

  const MainCoreEmployeeError(this.message);
}
