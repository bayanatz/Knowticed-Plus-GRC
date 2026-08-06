import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
class RoleTableView extends StatelessWidget {
  final List<RoleHistoryModel> roles;
  final String locale;

  const RoleTableView({
    Key? key,
    required this.roles,
    required this.locale,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle =>
      StyleText.fontSize15Weight600.copyWith(color: Colors.white);

  TextStyle _cellStyle(BuildContext context) {
    return AppTextStyles.font14BlackCairoRegular;
  }

  // ── Column widths ──────────────────────────────────────────────────────────

  double _calculateNoWidth(BuildContext context) => 60.w;

  double _calculateRoleNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var role in roles) {
      final roleName = role.currentRoleName;
      if (roleName.isNotEmpty) {
        maxLength = math.max(maxLength, roleName.length.toDouble());
      }
    }
    if (maxLength == 0) return 150.w;
    double calculatedWidth = math.min((maxLength * 10.sp) + 40.w, 200.w);
    return math.max(calculatedWidth, 150.w);
  }

  double _calculateRoleDescriptionWidth(BuildContext context) => 250.w;

  double _calculateModulesWidth(BuildContext context) => 150.w;

  double _calculateSwitchesWidth(BuildContext context) => 300.w;

  double _calculateStatusWidth(BuildContext context) => 100.w;

  double _calculateCreatedByWidth(BuildContext context) => 260.w;

  // ── Module name (AR/EN) ────────────────────────────────────────────────────

  String _getModuleName(BuildContext context, Modules module) {
    switch (module) {
      case Modules.employees:    return S.of(context).employees;
      case Modules.services:     return S.of(context).services;
      case Modules.tasks:        return S.of(context).tasks;
      case Modules.todo:         return S.of(context).todo;
      case Modules.events:       return S.of(context).events;
      case Modules.notes:        return S.of(context).notes;
      case Modules.requests:     return S.of(context).requests;
      case Modules.knowledgeHub: return S.of(context).knowledge_hub;
      case Modules.qiyas:        return S.of(context).qiyas;
      case Modules.grc:          return S.of(context).grc;
      case Modules.tracking:     return S.of(context).tracking;
      case Modules.inventory:    return S.of(context).inventory;
      case Modules.messages:     return S.of(context).messages;
      case Modules.database:     return S.of(context).database_builder;
      case Modules.formBuilder:  return S.of(context).services_app;
      case Modules.roles:        return S.of(context).roles;
      case Modules.settings:     return S.of(context).settings;
      case Modules.home:         return S.of(context).home;
      case Modules.notification: return S.of(context).notifications;
      default:                   return module.name;
    }
  }

  // ── Module enum from string ────────────────────────────────────────────────

  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':                  return Modules.employees;
      case 'services':                   return Modules.services;
      case 'tasks':                      return Modules.tasks;
      case 'todo':                       return Modules.todo;
      case 'events':                     return Modules.events;
      case 'notes':                      return Modules.notes;
      case 'requests':                   return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':               return Modules.knowledgeHub;
      case 'qiyas':                      return Modules.qiyas;
      case 'grc':                        return Modules.grc;
      case 'tracking':                   return Modules.tracking;
      case 'inventory':                  return Modules.inventory;
      case 'messages':                   return Modules.messages;
      case 'database_builder':
      case 'database':                   return Modules.database;
      case 'services_app':
      case 'formbuilder':                return Modules.formBuilder;
      case 'roles':                      return Modules.roles;
      case 'settings':                   return Modules.settings;
      case 'home':                       return Modules.home;
      case 'notification':
      case 'notifications':              return Modules.notification;
      case 'crm':                        return Modules.crm;
      default:
        return null;
    }
  }

  // ── Expand roles by modules ────────────────────────────────────────────────

  List<Map<String, dynamic>> _expandRolesByModules(RoleHistoryModel role) {
    List<Map<String, dynamic>> expandedRows = [];
    List<String> activeModuleStrings =
    ModulesCubit().getRoleActiveModules(role);

    if (activeModuleStrings.isEmpty) {
      expandedRows.add({
        'role': role,
        'moduleString': null,
        'module': null,
        'permissionsCount': 0,
        'activeSwitches': <String>[],
      });
    } else {
      for (String moduleString in activeModuleStrings) {
        Modules? moduleEnum = _getModuleEnum(moduleString);
        int permissionCount = _getModulePermissionCount(moduleString);
        expandedRows.add({
          'role': role,
          'moduleString': moduleString,
          'module': moduleEnum,
          'permissionsCount': permissionCount,
        });
      }
    }
    return expandedRows;
  }

  int _getModulePermissionCount(String moduleString) {
    Map<String, bool> defaultPermissions =
    ModulesCubit().getDefaultPermissionsForModule(moduleString);
    return defaultPermissions.length;
  }

  // ── Permission name (AR/EN via .tr) ───────────────────────────────────────

  String _formatPermissionName(String permissionKey) {
    return permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ')
        ; // ← .tr resolves AR/EN from GetX translations
  }

  // ── Created By: resolve full name from employee controller ────────────────

  String _resolveCreatedByName(String createdBy) {
    if (createdBy.isEmpty) return '-';

    try {
      final employeeController = Get.find<MainCoreEmployeeController>();

      // Try match by email first
      final employee = employeeController.allEmployeesEntities?.firstWhereOrNull(
            (e) => e.email?.toLowerCase() == createdBy.toLowerCase(),
      );

      if (employee != null) {
        final isArabic = Get.locale?.languageCode == 'ar';
        if (isArabic) {
          final arName =
          '${employee.firstNameInArabic ?? ''} ${employee.middleNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'
              .trim();
          if (arName.isNotEmpty) return arName;
        }
        final enName =
        '${employee.firstName ?? ''} ${employee.middleName ?? ''} ${employee.lastName ?? ''}'
            .trim();
        if (enName.isNotEmpty) return enName;
      }
    } catch (_) {}

    // Fallback: parse email to a readable name
    return _extractNameFromEmail(createdBy);
  }

  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return '-';
    if (!email.contains('@')) return email;

    String username = email.split('@')[0];
    username = username.replaceAll(RegExp(r'[._-]'), ' ');

    List<String> words = username
        .split(' ')
        .where((w) => w.isNotEmpty && !RegExp(r'^\d+$').hasMatch(w))
        .toList();

    if (words.isEmpty) return email;

    String firstName =
        '${words[0][0].toUpperCase()}${words[0].substring(1).toLowerCase()}';
    String lastName = words.length > 1
        ? '${words[1][0].toUpperCase()}${words[1].substring(1).toLowerCase()}'
        : '';

    return lastName.isNotEmpty ? '$firstName $lastName' : firstName;
  }

  // ── Cell helpers ───────────────────────────────────────────────────────────

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
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        style: StyleText.fontSize12Weight600.copyWith(color: AppColors.text),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(date);
    } catch (e) {
      return '-';
    }
  }

  // ── Switches cell ──────────────────────────────────────────────────────────

  Widget _switchesCell(
      BuildContext context, RoleHistoryModel role, String? moduleString) {
    if (moduleString == null) {
      return _cell(context, Text('-'));
    }

    return _cell(
      context,
      FutureBuilder<List<String>>(
        future: _loadActivePermissions(role, moduleString),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 20.sp,
              width: 20.sp,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (snapshot.hasError) {
            return Text(
              S.of(context).error_loading,
              style: AppTextStyles.font12BlackCairoRegular.copyWith(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            );
          }

          List<String> activeSwitches = snapshot.data ?? [];

          if (activeSwitches.isEmpty) {
            return Text(
              S.of(context).no_specific_permissions,
              style: AppTextStyles.font12BlackCairoRegular.copyWith(
                fontStyle: FontStyle.italic,
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 6.sp,
              runSpacing: 6.sp,
              children: activeSwitches.map((permission) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.sp,
                    vertical: 4.sp,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(.3),
                    borderRadius: BorderRadius.circular(4.sp),
                  ),
                  child: Text(
                    permission,
                    style: AppTextStyles.font12BlackCairoRegular,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Future<List<String>> _loadActivePermissions(
      RoleHistoryModel role,
      String moduleString,
      ) async {
    try {
      final roleRepository = RoleRepository();
      var result = await roleRepository.getRolePermissions(
        roleId: role.roleId,
        module: moduleString,
      );

      if (result.isRight()) {
        Map<String, dynamic>? moduleData = result.getOrElse(() => null);
        if (moduleData == null) return [];

        List<String> activePermissions = [];
        moduleData.forEach((key, value) {
          if (key != 'Role_Id' && key != 'timestamps') {
            bool isActive = false;
            if (value is List && value.isNotEmpty) {
              var lastValue = value.last;
              isActive =
              (lastValue == true || lastValue == 1 || lastValue == '1');
            } else if (value is bool) {
              isActive = value;
            }
            if (isActive) {
              activePermissions.add(_formatPermissionName(key));
            }
          }
        });

        return activePermissions;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final headers = <String>[
      s.no,
      s.role_name,
      s.role_name_ar,
      s.role_description,
      s.role_description_ar,
      s.status,
      s.created_by,
      s.created_at,
      s.modules,
      s.active_permissions,
    ];

    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateNoWidth(context)),
      1: FixedColumnWidth(_calculateRoleNameWidth(context)),
      2: FixedColumnWidth(_calculateRoleNameWidth(context)),
      3: FixedColumnWidth(_calculateRoleDescriptionWidth(context)),
      4: FixedColumnWidth(_calculateRoleDescriptionWidth(context)),
      5: FixedColumnWidth(_calculateStatusWidth(context)),
      6: FixedColumnWidth(_calculateCreatedByWidth(context)),
      7: FixedColumnWidth(_calculateStatusWidth(context)),
      8: FixedColumnWidth(_calculateModulesWidth(context)),
      9: FixedColumnWidth(_calculateSwitchesWidth(context)),
    };

    // Expand roles by modules
    List<Map<String, dynamic>> expandedData = [];
    int rowNumber = 1;

    for (var role in roles) {
      // Skip master admin role
      final roleName = role.currentRoleName.toLowerCase().trim();
      final roleNameAr = role.currentRoleNameAr.toLowerCase().trim();
      final roleId = role.roleId.toLowerCase();

      if (roleName == 'master admin' ||
          roleName == 'masteradmin' ||
          roleName == 'admin' ||
          roleNameAr == 'مسؤول رئيسي' ||
          roleNameAr == 'مدير النظام' ||
          roleId == 'master_admin' ||
          roleId == 'masteradmin') {
        continue;
      }

      var roleRows = _expandRolesByModules(role);
      for (int i = 0; i < roleRows.length; i++) {
        expandedData.add({
          ...roleRows[i],
          'rowNumber': rowNumber,
          'isFirstRow': i == 0,
          'rowSpan': roleRows.length,
        });
        rowNumber++;
      }
    }

    return Directionality(
      textDirection:
      _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // ── Header row ───────────────────────────────────────────────
              TableRow(
                decoration: BoxDecoration(
                  color: lightMode ? Colors.black : Colors.black45,
                ),
                children: headers
                    .map((name) => Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Text(
                    name,
                    style: _headerStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ))
                    .toList(),
              ),

              // ── Data rows ─────────────────────────────────────────────────
              ...List.generate(expandedData.length, (index) {
                final data = expandedData[index];
                final role = data['role'] as RoleHistoryModel;
                final moduleString = data['moduleString'] as String?;
                final module = data['module'] as Modules?;
                final rowNumber = data['rowNumber'] as int;

                final isEven = rowNumber.isEven;
                final rowColor = lightMode
                    ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                    : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    // No
                    _textCell(context, rowNumber.toString(), maxLines: 1),

                    // Role Name EN
                    _textCell(context, role.currentRoleName, maxLines: 2),

                    // Role Name AR
                    _textCell(
                      context,
                      role.currentRoleNameAr.isNotEmpty
                          ? role.currentRoleNameAr
                          : '-',
                      maxLines: 2,
                    ),

                    // Role Description EN
                    _textCell(
                      context,
                      role.currentRoleDescription.isNotEmpty
                          ? role.currentRoleDescription
                          : '-',
                      maxLines: 3,
                    ),

                    // Role Description AR
                    _textCell(
                      context,
                      role.currentRoleDescriptionAr.isNotEmpty
                          ? role.currentRoleDescriptionAr
                          : '-',
                      maxLines: 3,
                    ),

                    // Status — localized via .tr on the enum name
                    _cell(
                      context,
                      Text(
                        role.currentStatus.name.capitalize ??
                            role.currentStatus.name,
                        style:
                        AppTextStyles.font12BlackCairoRegular.copyWith(
                          color: role.currentStatus.color,
                        ),
                      ),
                    ),

                    // Created By — resolved full name (AR/EN)
                    _textCell(
                      context,
                      _resolveCreatedByName(role.currentCreatedBy),
                      maxLines: 2,
                    ),

                    // Created At
                    _textCell(
                      context,
                      _formatDate(role.currentCreatedAt.toDate()),
                      maxLines: 1,
                    ),

                    // Module — localized via S.of(context)
                    _textCell(
                      context,
                      module != null
                          ? _getModuleName(context, module)
                          : '-',
                      maxLines: 1,
                    ),

                    // Active Permissions — localized chips via .tr
                    _switchesCell(context, role, moduleString),
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