import 'dart:io';
import 'package:grc_module/core/custom/2-custom_textfield.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:path_provider/path_provider.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
class UserManagementExportDialog extends StatefulWidget {
  final List<UserPermissionEntity> userPermissions;

  const UserManagementExportDialog({
    Key? key,
    required this.userPermissions,
  }) : super(key: key);

  @override
  State<UserManagementExportDialog> createState() => _UserManagementExportDialogState();
}

class _UserManagementExportDialogState extends State<UserManagementExportDialog> {
  final TextEditingController controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    controller.text = _getDefaultFileName();
  }

  String _getDefaultFileName() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = "${now.day} ${months[now.month - 1]} ${now.year}";
    return "User_Management_export_$dateStr";
  }

  Future<void> _showLoadingIndicator(BuildContext context) async {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Container(
              width: 411,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void _hideLoadingIndicator() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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

  // ✅ Localized role name (matches the table). Drop this and use
  // `user.accessName` in the CSV if you want the export to stay raw English.
  String _getRoleName(UserPermissionEntity user, BuildContext context) {
    final access = user.accessName;
    if (access == null || access.trim().isEmpty) return '';

    try {
      final roleCubit = Get.find<RoleCubit>();
      final target = access.trim().toLowerCase();

      final role = roleCubit.roles.firstWhereOrNull(
            (r) =>
        (r.roleId?.toString().trim().toLowerCase() == target) ||
            (r.currentRoleName?.trim().toLowerCase() == target),
      );

      if (role != null) {
        if (context.isArabic) {
          final ar = role.currentRoleNameAr;
          if (ar != null && ar.trim().isNotEmpty) return ar;
        }
        final en = role.currentRoleName;
        if (en != null && en.trim().isNotEmpty) return en;
      }
    } catch (e) {
      // RoleCubit not available -> fall back to raw access name.
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

  // ✅ Phone now includes the country code (matches the table).
  String _getMobilePhone(EmployeeEntityPro? employee) {
    final mobile = employee?.mobilePhone;
    if (mobile?.phone == null) return '-';

    final phone = (mobile!.phone ?? '').replaceAll(RegExp(r'[\[\]]'), '').trim();
    if (phone.isEmpty) return '-';

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
    if (employee == null || employee.supervisor == null || employee.supervisor!.isEmpty) {
      return '-';
    }

    try {
      final allEmployees = Get.find<MainCoreEmployeeController>().allEmployeesEntities;

      if (allEmployees == null || allEmployees.isEmpty) {
        return '-';
      }

      EmployeeEntityPro? supervisor = allEmployees.firstWhereOrNull(
            (element) => element.email?.toLowerCase().trim() == employee.supervisor?.toLowerCase().trim(),
      );

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

  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      Get.snackbar(
        S.of(context).error,
        S.of(context).pleaseEnterAFileName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _showLoadingIndicator(context);

      if (widget.userPermissions.isEmpty) {
        _hideLoadingIndicator();
        setState(() {
          _isExporting = false;
        });
        Get.snackbar(
          S.of(context).noData,
          S.of(context).noUserPermissionsToExport,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      String finalFileName = fileName.toLowerCase().endsWith('.csv')
          ? fileName
          : '$fileName.csv';

      final filePath = '${directory.path}/$finalFileName';
      final file = File(filePath);

      String csvContent = _generateCSVContent();

      await file.writeAsString(csvContent);

      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      SuccessDialog.show(context);

    } catch (e) {
      _hideLoadingIndicator();
      setState(() {
        _isExporting = false;
      });

      Get.snackbar(
        S.of(context).exportFailed,
        '${S.of(context).error}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  String _generateCSVContent() {
    List<List<dynamic>> rows = [
      [
        'NO',
        'Role Type',
        'Employee ID',
        'First Name',
        'Last Name',
        'Email',
        'Mobile Phone',
        'Department Name',
        'Supervisor',
        'Title',
      ],
    ];

    for (int i = 0; i < widget.userPermissions.length; i++) {
      final user = widget.userPermissions[i];
      final employee = _getEmployee(user.employeeId);

      rows.add([
        i + 1,
        _safeString(_getRoleName(user, context)),
        _safeString(user.employeeId),
        _safeString(_getFirstName(employee, context)),
        _safeString(_getLastName(employee, context)),
        _safeString(_getEmail(employee)),
        _safeString(_getMobilePhone(employee)),
        _safeString(_getDepartment(employee, context)),
        _safeString(_getSupervisor(employee, context)),
        _safeString(_getTitle(employee, context)),
      ]);
    }

    return _convertToCSV(rows);
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _convertToCSV(List<List<dynamic>> rows) {
    StringBuffer csvBuffer = StringBuffer();
    for (List<dynamic> row in rows) {
      csvBuffer.writeln(row.join(','));
    }
    return csvBuffer.toString();
  }

  @override
  void dispose() {
    _hideLoadingIndicator();
    controller.dispose();
    super.dispose();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 900 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: 411.sp,
        child: Padding(
          padding: EdgeInsets.all(20.sp), // ✅ Equal padding on all sides
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Dialog now fits its content height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30.sp,
                    height: 30.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Center(
                      child: CustomSvgImage(assetPath: 
                        "assets/icons_assets/main_icons_assets/export_arrow.svg",
                        width: 16.sp,
                        height: 16.sp,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    S.of(context).exportUserManagement,
                    style: StyleText.fontSize16Weight500.copyWith(
                     color: AppColors.text
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomTextField(
                label: S.of(context).fileName,
                hint: S.of(context).textHere,
                controller: controller,
                height: 36,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: S.of(context).discard,
                    width: isMobile ? 100.w : 135.w,
                    color: _isExporting ? Colors.grey : const Color(0xffcccccccc),
                    height: 38.sp,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: _isExporting ? Colors.grey[600] : const Color(0xff2D2D2D),
                    ),
                    radius: 8.r,
                    function: () {
                      if (!_isExporting) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  customButton(
                    title: _isExporting ? S.of(context).exporting : S.of(context).exportCsv,
                    width: isMobile ? 100.w : 135.w,
                    color: _isExporting ? Colors.grey : AppColors.primary,
                    height: 38.sp,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                    radius: 8.r,
                    function: () {
                      if (!_isExporting) {
                        _exportData(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}