import 'package:flutter/material.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';

enum EmployeeStatusEnum {
  all,
  active,
  inactive,
  resetPassword,
  lockedWithRequest,
  locked,
  deactivated,
  willBeDeactivated,
  willBeActivated;

  String localizedName(BuildContext context) {
    switch (this) {
      case EmployeeStatusEnum.all:
        return S.of(context).employeeStatusAll;
      case EmployeeStatusEnum.active:
        return S.of(context).employeeStatusActive;
      case EmployeeStatusEnum.inactive:
        return S.of(context).employeeStatusInactive;
      case EmployeeStatusEnum.resetPassword:
        return S.of(context).employeeStatusResetPassword;
      case EmployeeStatusEnum.lockedWithRequest:
        return S.of(context).employeeStatusLockedWithRequest;
      case EmployeeStatusEnum.locked:
        return S.of(context).employeeStatusLocked;
      case EmployeeStatusEnum.deactivated:
        return S.of(context).employeeStatusDeactivated;
      case EmployeeStatusEnum.willBeDeactivated:
        return S.of(context).employeeStatusWillBeDeactivated;
      case EmployeeStatusEnum.willBeActivated:
        return S.of(context).employeeStatusWillBeActivated;
      default:
        return S.of(context).employeeStatusActive;
    }
  }

  Color get color {
    switch (this) {
      case EmployeeStatusEnum.all:
        return AppColors.text;
      case EmployeeStatusEnum.active:
        return AppColors.green;
      case EmployeeStatusEnum.deactivated:
        return AppColors.red;
      case EmployeeStatusEnum.locked:
        return Color(0xFFB02A37);
      case EmployeeStatusEnum.willBeDeactivated:
        return AppColors.orange;
      case EmployeeStatusEnum.willBeActivated:
        return AppColors.grey;
      default:
        return Colors.transparent;
    }
  }
}
