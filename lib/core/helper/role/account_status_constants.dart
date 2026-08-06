import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

abstract class AccountStatusConstants {
  static List<EmployeeStatusEnum> employeeStatus = [
    EmployeeStatusEnum.all,
    EmployeeStatusEnum.active,
    EmployeeStatusEnum.willBeDeactivated,
    EmployeeStatusEnum.deactivated,
    EmployeeStatusEnum.willBeActivated,
    //  EmployeeStatusEnum.inactive,
    EmployeeStatusEnum.locked,
    //   EmployeeStatusEnum.lockedWithRequest,
    //   EmployeeStatusEnum.resetPassword,
  ];
}
