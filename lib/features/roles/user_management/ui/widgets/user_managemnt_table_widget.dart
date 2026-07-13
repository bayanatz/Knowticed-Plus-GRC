import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'dart:ui' as ui;

import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/domain/entity/user_permission_entity.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';

class UserManagementTableWidget extends StatelessWidget {
  final List<UserPermissionEntity> userPermissions;
  final String locale;

  const UserManagementTableWidget({
    Key? key,
    required this.userPermissions,
    required this.locale,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle => AppTextStyles.font14BlackCairoMedium.copyWith(
    color: Colors.white,
  );

  TextStyle _cellStyle(BuildContext context) {
    return AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
      color: AppColors.text,
    );
  }

  EmployeeEntityPro? _getEmployee(String employeeId) {
    try {
      return Get.find<MainCoreEmployeeController>()
          .allEmployeesEntities!
          .firstWhere((element) => element.id == employeeId);
    } catch (e) {
      return null;
    }
  }

  // ✅ Role name supports AR / EN (item value, not the header).
  // Reads RoleCubit via context.read (flutter_bloc) — same as the
  // UserPermissionOverview card, which is the access path that actually works.
  String _getRoleName(UserPermissionEntity user, BuildContext context) {
    final access = user.accessName;
    if (access == null || access.trim().isEmpty) return '-';

    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull(
            (r) =>
        r.roleId == access ||
            r.currentRoleName == access,
      );

      if (role != null) {
        return _isArabic ? role.currentRoleNameAr : role.currentRoleName;
      }
    } catch (e) {
      // RoleCubit not found in this widget's tree -> fall back to raw name.
    }

    return access;
  }

  String _getFirstName(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    if (context.isArabic) {
      return employee.firstNameInArabic ?? employee.firstName ?? '-';
    } else {
      return employee.firstName ?? '-';
    }
  }

  String _getLastName(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    if (context.isArabic) {
      return employee.lastNameInArabic ?? employee.lastName ?? '-';
    } else {
      return employee.lastName ?? '-';
    }
  }

  String _getEmail(EmployeeEntityPro? employee) {
    return employee?.email ?? '-';
  }

  // ✅ Phone now includes the country code (e.g. +20 1012345678).
  String _getMobilePhone(EmployeeEntityPro? employee) {
    final mobile = employee?.mobilePhone;
    if (mobile?.phone == null) return '-';

    // Clean phone (remove square brackets if present)
    final phone = (mobile!.phone ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (phone.isEmpty) return '-';

    // Clean country code and normalize the leading '+'
    final rawCode = (mobile.countryCode ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (rawCode.isEmpty) return phone;

    final code = rawCode.startsWith('+') ? rawCode : '+$rawCode';
    return '$code $phone';
  }

  String _getDepartment(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    return EmployeeHelper.getEmployeeLocalizeDepartment(
      employee: employee,
      context: context,
    );
  }

  String _getSupervisor(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';

    // Check if supervisor field is empty
    if (employee.supervisor == null || employee.supervisor!.isEmpty) {
      return '-';
    }

    try {
      // Get all employees
      final allEmployees = Get.find<MainCoreEmployeeController>().allEmployeesEntities;

      if (allEmployees == null || allEmployees.isEmpty) {
        return '-';
      }

      // Find supervisor by email (since supervisor field contains email)
      EmployeeEntityPro? supervisor = allEmployees.firstWhereOrNull(
            (element) => element.email?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
      );

      // If not found by email, try by ID as fallback
      if (supervisor == null) {
        supervisor = allEmployees.firstWhereOrNull(
              (element) => element.id?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
        );
      }

      if (supervisor == null) {
        return '-';
      }

      return EmployeeHelper.getEmployeeLocalizedName(
        employee: supervisor,
        context: context,
      );
    } catch (e) {
      return '-';
    }
  }

  String _getTitle(EmployeeEntityPro? employee, BuildContext context) {
    if (employee == null) return '-';
    return EmployeeHelper.getEmployeeLocalizedTitle(
      employee: employee,
      context: context,
    ) ?? '-';
  }

  // Width calculation methods
  double _calculateNoWidth(BuildContext context) {
    return context.isPortrait ? 60.w : 70.w;
  }

  double _calculateRoleTypeWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      // ✅ Use the localized role name so AR widths are correct too
      final roleName = _getRoleName(user, context);
      if (roleName.isNotEmpty && roleName != '-') {
        maxLength = maxLength > roleName.length ? maxLength : roleName.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateEmployeeIdWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  double _calculateFirstNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String name = _getFirstName(employee, context);
      if (name.isNotEmpty && name != '-') {
        maxLength = maxLength > name.length ? maxLength : name.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateLastNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String name = _getLastName(employee, context);
      if (name.isNotEmpty && name != '-') {
        maxLength = maxLength > name.length ? maxLength : name.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 140.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 120.w : 120.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateEmailWidth(BuildContext context) {
    return context.isPortrait ? 300.w : 300.w;
  }

  double _calculateMobilePhoneWidth(BuildContext context) {
    // ✅ A bit wider now that the country code is shown
    return context.isPortrait ? 150.w : 170.w;
  }

  double _calculateDepartmentWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String dept = _getDepartment(employee, context);
      if (dept.isNotEmpty && dept != '-') {
        maxLength = maxLength > dept.length ? maxLength : dept.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 220.w ? 220.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateSupervisorWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String supervisor = _getSupervisor(employee, context);
      if (supervisor.isNotEmpty && supervisor != '-') {
        maxLength = maxLength > supervisor.length ? maxLength : supervisor.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  double _calculateTitleWidth(BuildContext context) {
    double maxLength = 0;
    for (var user in userPermissions) {
      EmployeeEntityPro? employee = _getEmployee(user.employeeId);
      String title = _getTitle(employee, context);
      if (title.isNotEmpty && title != '-') {
        maxLength = maxLength > title.length ? maxLength : title.length.toDouble();
      }
    }
    if (maxLength == 0) return context.isPortrait ? 140.w : 160.w;
    double calculatedWidth = ((maxLength * 8.sp) + 40.w) > 200.w ? 200.w : (maxLength * 8.sp) + 40.w;
    double minWidth = context.isPortrait ? 140.w : 140.w;
    return calculatedWidth > minWidth ? calculatedWidth : minWidth;
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle(context),
        child: child,
      ),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2}) {
    return _cell(
      context,
      Text(
        text.isEmpty ? '-' : text,
        style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.text
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _numberCell(BuildContext context, int number) {
    return _cell(
      context,
      Text(
        number.toString(),
        maxLines: 1,
        style: _cellStyle(context).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      _isArabic ? 'رقم' : 'NO',
      _isArabic ? 'نوع الدور' : 'Role Type',
      _isArabic ? 'رقم الموظف' : 'Employee ID',
      _isArabic ? 'الاسم الأول' : 'First Name',
      _isArabic ? 'اسم العائلة' : 'Last Name',
      _isArabic ? 'البريد الإلكتروني' : 'Email',
      _isArabic ? 'رقم الهاتف المحمول' : 'Mobile Phone',
      _isArabic ? 'اسم القسم' : 'Department Name',
      _isArabic ? 'المشرف' : 'Supervisor',
      _isArabic ? 'المسمى الوظيفي' : 'Title',
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateNoWidth(context)),
      1: FixedColumnWidth(_calculateRoleTypeWidth(context)),
      2: FixedColumnWidth(_calculateEmployeeIdWidth(context)),
      3: FixedColumnWidth(_calculateFirstNameWidth(context)),
      4: FixedColumnWidth(_calculateLastNameWidth(context)),
      5: FixedColumnWidth(_calculateEmailWidth(context)),
      6: FixedColumnWidth(_calculateMobilePhoneWidth(context)),
      7: FixedColumnWidth(_calculateDepartmentWidth(context)),
      8: FixedColumnWidth(_calculateSupervisorWidth(context)),
      9: FixedColumnWidth(_calculateTitleWidth(context)),
    };

    return Directionality(
      textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: lightMode ? Colors.black : Colors.black45,
                ),
                children: headers.map((name) =>
                    Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: Text(
                        name,
                        style: _headerStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                ).toList(),
              ),

              // Data Rows
              ...List.generate(userPermissions.length, (index) {
                final user = userPermissions[index];
                final isEven = index.isEven;
                final rowColor = lightMode
                    ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                    : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                final employee = _getEmployee(user.employeeId);
                final roleName = _getRoleName(user, context);
                final firstName = _getFirstName(employee, context);
                final lastName = _getLastName(employee, context);
                final email = _getEmail(employee);
                final mobilePhone = _getMobilePhone(employee);
                final departmentName = _getDepartment(employee, context);
                final supervisor = _getSupervisor(employee, context);
                final title = _getTitle(employee, context);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    _numberCell(context, index + 1),
                    _textCell(context, FormatHelper.capitalize(roleName)),
                    _textCell(context, user.employeeId, maxLines: 1),
                    _textCell(context, FormatHelper.capitalize(firstName)),
                    _textCell(context, FormatHelper.capitalize(lastName)),
                    _textCell(context, email, maxLines: 1),
                    _textCell(context, mobilePhone, maxLines: 1),
                    _textCell(context, FormatHelper.capitalize(departmentName)),
                    _textCell(context, FormatHelper.capitalize(supervisor)),
                    _textCell(context, FormatHelper.capitalize(title)),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}