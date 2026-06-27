import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/inventory_module/core/circle_progress.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/controller/modules_controller.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';

import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/roles/widgets/custom_title_value_widget.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/adding_new_role.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_details_page.dart';

class RoleOverview extends StatefulWidget {
  RoleOverview({required this.role, super.key});

  final RoleHistoryModel role;

  @override
  State<RoleOverview> createState() => _RoleOverviewState();
}

class _RoleOverviewState extends State<RoleOverview> {
  late List<String> activeModuleStrings;
  late List<Modules> activeModules;
  late RoleCubit roleCubit;
  late ModulesController modulesController;
  bool _permissionsLoaded = false;
  Map<String, List<String>> _modulePermissions = {};

  @override
  void initState() {
    super.initState();
  }

  /// ✅ CHECK IF THIS ROLE IS MASTER ADMIN
  bool _isMasterAdminRole() {
    String roleName = widget.role.currentRoleName.toLowerCase().trim();
    String roleNameAr = widget.role.currentRoleNameAr.toLowerCase().trim();

    return roleName == 'master admin' ||
        roleName == 'masteradmin' ||
        roleName == 'admin' ||
        roleNameAr == 'مسؤول رئيسي' ||
        roleNameAr == 'مدير النظام' ||
        widget.role.roleId.toLowerCase() == 'master_admin' ||
        widget.role.roleId.toLowerCase() == 'masteradmin';
  }

  Future<void> _loadPermissions() async {
    if (_permissionsLoaded) return;

    roleCubit = context.read<RoleCubit>();
    modulesController = ModulesController();

    activeModuleStrings = modulesController.getRoleActiveModules(widget.role);

    var result = await roleCubit.roleRepository.getAllRolePermissions(
      roleId: widget.role.roleId,
      selectedModules: activeModuleStrings,
    );

    if (result.isRight()) {
      Map<String, Map<String, dynamic>> allPermissions =
      result.getOrElse(() => {});

      for (String moduleName in activeModuleStrings) {
        List<String> activePermissions = [];

        if (allPermissions.containsKey(moduleName)) {
          Map<String, dynamic> moduleData = allPermissions[moduleName]!;

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
                // ✅ FIX 1: Store raw key, NOT formatted string
                activePermissions.add(key);
              }
            }
          });
        }

        _modulePermissions[moduleName] = activePermissions;
      }
    }

    setState(() {
      _permissionsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ IF MASTER ADMIN ROLE - HIDE THE ENTIRE CONTAINER
    if (_isMasterAdminRole()) {
      return SizedBox.shrink();
    }

    // ✅ GET PERMISSIONS FROM CACHE INSTEAD OF LOADING
    roleCubit = context.read<RoleCubit>();
    modulesController = ModulesController();
    activeModuleStrings = modulesController.getRoleActiveModules(widget.role);

    // ✅ FIX 2: Get cached permissions (raw keys stored in cache)
    var cachedPermissions = roleCubit.getRolePermissions(widget.role.roleId);
    if (cachedPermissions != null) {
      _modulePermissions = cachedPermissions;
      _permissionsLoaded = true;
    }

    // Convert to Modules enums for UI display
    activeModules = _convertModuleStringsToEnums(activeModuleStrings);

    return InkWell(
      onTap: () {
        context.read<RoleCubit>().selectRole(widget.role);

        if (widget.role.currentStatus.name.toLowerCase() == 'draft') {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return BlocProvider<RoleCubit>.value(
              value: (context.read<RoleCubit>()),
              child: AddingNewRole(),
            );
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return BlocProvider<RoleCubit>.value(
              value: (context.read<RoleCubit>()),
              child: RoleDetailsPage(),
            );
          }));
        }
      },
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          spacing: 5.sp,
          children: [
            Row(
              children: [
                roleImage(),
                SizedBox(width: 10.sp),
                Expanded(
                  child: SizedBox(
                    height: 50.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic &&
                                        widget.role.currentRoleNameAr
                                            .isNotEmpty
                                        ? widget.role.currentRoleNameAr
                                        : FormatHelper.capitalize(
                                        widget.role.currentRoleName),
                                    style: StyleText.fontSize16Weight500
                                        .copyWith(
                                        color: AppColors.text, height: 1.2),
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: isArabic
                                        ? ui.TextDirection.rtl
                                        : ui.TextDirection.ltr,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${'status'.tr}: ",
                                  style: StyleText.fontSize12Weight500.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                Text(
                                  FormatHelper.capitalize(widget.role.currentStatus.name).tr,
                                  style: StyleText.fontSize12Weight500.copyWith(
                                      color: widget.role.currentStatus.color),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 4.sp),
                        CustomTitleValueWidget(
                            title: "${'Created By'.tr}: ",
                            value: FormatHelper.capitalize(
                                _getCreatorName(context))),
                        SizedBox(height: 4.sp),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTitleValueWidget(
                                    title: "${S.of(context).totalModules}: ",
                                    value: activeModules.length.toString()),
                              ),
                              CustomTitleValueWidget(
                                title: "${'Created At'.tr}: ",
                                value: DateFormat('dd MMMM yyyy',
                                    (context.isArabic) ? 'ar' : 'en')
                                    .format(widget.role.currentCreatedAt
                                    .toDate()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_permissionsLoaded)
              Column(
                spacing: 10.sp,
                children: [
                  for (String moduleString in activeModuleStrings)
                    buildModuleRow(moduleString),
                ],
              )
            else
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.sp),
                  child: CircleProgressMaster()),
          ],
        ),
      ),
    );
  }

  List<Modules> _convertModuleStringsToEnums(List<String> moduleStrings) {
    List<Modules> enums = [];
    for (String moduleName in moduleStrings) {
      Modules? moduleEnum = _getModuleEnum(moduleName);
      if (moduleEnum != null) {
        enums.add(moduleEnum);
      }
    }
    return enums;
  }

  Modules? _getModuleEnum(String moduleName) {
    String normalized =
    moduleName.toLowerCase().trim().replaceAll(' ', '_');

    switch (normalized) {
      case 'employees':
        return Modules.employees;
      case 'services':
        return Modules.services;
      case 'tasks':
        return Modules.tasks;
      case 'todo':
        return Modules.todo;
      case 'events':
        return Modules.events;
      case 'notes':
        return Modules.notes;
      case 'requests':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'grc':
        return Modules.grc;
      case 'tracking':
        return Modules.tracking;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'database_builder':
      case 'database':
        return Modules.database;
      case 'form_builder':
      case 'formbuilder':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'home':
        return Modules.home;
      default:
        return null;
    }
  }

  String _getCreatorName(BuildContext context) {
    try {
      final employeeController = Get.find<MainCoreEmployeeController>();
      final creator =
      employeeController.getLocaleEmployee(widget.role.currentCreatedBy);

      if (creator != null) {
        return EmployeeHelper.getEmployeeLocalizedName(
            employee: creator, context: context);
      }
      return widget.role.currentCreatedBy;
    } catch (e) {
      return widget.role.currentCreatedBy;
    }
  }

  Widget roleImage() {
    if (widget.role.currentRoleImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          widget.role.currentRoleImage,
          width: 50.sp,
          height: 50.sp,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
                width: 50.sp,
                height: 50.sp,
                color: Colors.grey.shade200,
                child: const CircleProgressMaster());
          },
          errorBuilder: (context, error, stackTrace) {
            return _defaultRoleIcon();
          },
        ),
      );
    }
    return _defaultRoleIcon();
  }

  Widget _defaultRoleIcon() {
    return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        width: 50.sp,
        height: 50.sp,
        child: SvgPicture.asset(
          'assets/image_roles.svg',
          width: 30.sp,
          height: 30.sp,
          color: AppColors.text,
          fit: BoxFit.scaleDown,
        ));
  }

  Widget buildModuleRow(String moduleString) {
    Modules? module = _getModuleEnum(moduleString);
    if (module == null) return SizedBox.shrink();

    // ✅ FIX 3: Format at render time so .tr uses current locale (Arabic/English)
    List<String> activeSwitches =
    (_modulePermissions[moduleString] ?? [])
        .map((key) => _formatPermissionName(key))
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.sp,
            alignment: Alignment.center,
            width: 20.sp,
            child: SvgPicture.asset(
              module.iconPathRole,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: activeSwitches.isEmpty
                ? SizedBox()
                : LayoutBuilder(
              builder: (context, constraints) {
                return _buildPermissionChips(
                  activeSwitches,
                  constraints.maxWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionChips(List<String> permissions, double maxWidth) {
    List<Widget> firstRowChips = [];
    List<Widget> secondRowChips = [];

    double firstRowWidth = 0;
    double secondRowWidth = 0;
    final double spacing = 8.w;
    bool firstRowFull = false;

    for (int i = 0; i < permissions.length; i++) {
      final chipWidth = _calculateChipWidth(permissions[i]);

      if (!firstRowFull &&
          firstRowWidth + (firstRowChips.isEmpty ? 0 : spacing) + chipWidth <=
              maxWidth) {
        if (firstRowChips.isNotEmpty) {
          firstRowChips.add(SizedBox(width: spacing));
          firstRowWidth += spacing;
        }
        firstRowChips.add(_buildChip(permissions[i]));
        firstRowWidth += chipWidth;
      } else if (!firstRowFull) {
        firstRowFull = true;
        secondRowChips.add(_buildChip(permissions[i]));
        secondRowWidth += chipWidth;
      } else {
        if (secondRowWidth + spacing + chipWidth <= maxWidth) {
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
            secondRowWidth += spacing;
          }
          secondRowChips.add(_buildChip(permissions[i]));
          secondRowWidth += chipWidth;
        } else {
          // overflow chip goes to scrollable second row anyway
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
          }
          secondRowChips.add(_buildChip(permissions[i]));
        }
      }
    }

    return SizedBox(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: firstRowChips,
            ),
          ),
          if (secondRowChips.isNotEmpty) ...[
            SizedBox(height: 8.w),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: secondRowChips,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      height: 32.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4.sp),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
      alignment: Alignment.center,
      child: Text(
          text,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          )),
    );
  }

  double _calculateChipWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.font12BlackCairoRegular,
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();
    return textPainter.width + 20.sp + 4;
  }

  /// ✅ Format permission name at render time so .tr resolves current locale
  String _formatPermissionName(String permissionKey) {
    String formatted = permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');

    return formatted.tr;
  }
}