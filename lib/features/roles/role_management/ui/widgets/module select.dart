import 'package:demo_app/features/roles/core_widgets/main_widget/custom_svg.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'dart:ui' as ui;

import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';


class ModulePermissionsWidget extends StatefulWidget {
  const ModulePermissionsWidget({super.key});

  @override
  State<ModulePermissionsWidget> createState() => _ModulePermissionsWidgetState();
}

class _ModulePermissionsWidgetState extends State<ModulePermissionsWidget> {
  Map<String, bool> expandedModules = {};
  late RoleCubit controller;
  bool isLoading = true;
  Map<String, Map<String, bool>> allModulePermissions = {};

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    if (controller.selectedRole == null) return;

    setState(() {
      isLoading = true;
    });

    // Get modules from selected role
    List<String> moduleStrings = List<String>.from(controller.selectedRole!.currentSelectedModules);


    // Load permissions for all modules
    var result = await controller.roleRepository.getAllRolePermissions(
      roleId: controller.selectedRole!.roleId,
      selectedModules: moduleStrings,
    );

    if (result.isRight()) {
      Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(() => {});

      for (String moduleName in moduleStrings) {
        if (allPermissions.containsKey(moduleName)) {
          Map<String, dynamic> moduleData = allPermissions[moduleName]!;
          Map<String, bool> permissions = {};

          moduleData.forEach((key, value) {
            if (key != 'Role_Id' && key != 'timestamps') {
              if (value is List && value.isNotEmpty) {
                var lastValue = value.last;
                permissions[key] = (lastValue == true || lastValue == 1);
              } else if (value is bool) {
                permissions[key] = value;
              }
            }
          });

          allModulePermissions[moduleName] = permissions;
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.selectedRole == null) {
      return SizedBox.shrink();
    }

    List<String> moduleStrings = List<String>.from(controller.selectedRole!.currentSelectedModules);

    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).permissionControls,
          style: AppTextStyles.font16BlackSemiBoldCairo,
        ),
        if (isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: CircleProgressMaster(),
            ),
          )
        else
          Column(
            spacing: 10.sp,
            children: [
              for (String moduleName in moduleStrings)
                _buildModuleSection(moduleName),
              SizedBox(height: 10.h,)
            ],
          ),
      ],
    );
  }

  Widget _buildModuleSection(String moduleName) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isExpanded = expandedModules[moduleName] ?? false;
    Map<String, bool> permissions = allModulePermissions[moduleName] ?? {};

    String displayName = _getModuleDisplayName(moduleName);

    List<String> activePermissions = permissions.entries
        .where((entry) => entry.value == true)
        .map((entry) => _formatPermissionName(entry.key))
        .toList();

    // ✅ No active permissions = no arrow, no tap
    final bool hasPermissions = activePermissions.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: hasPermissions
                ? () {
              setState(() {
                expandedModules[moduleName] = !isExpanded;
              });
            }
                : null, // ✅ Disabled if no permissions
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 12.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: AppTextStyles.font14BlackCairoMedium,
                    ),
                  ),
                  // ✅ Only show arrow if there are active permissions
                  if (hasPermissions)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomSvg(
                        assetPath: "assets/icons_assets/main_icons_assets/arrowdown.svg",
                        width: 12.w,
                        height: 15.h,
                        fit: BoxFit.scaleDown,
                        color: AppColors.text
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded && hasPermissions
                ? Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.sp),
                  bottomRight: Radius.circular(8.sp),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildPermissionChips(
                    activePermissions,
                    constraints.maxWidth,
                  );
                },
              ),
            )
                : SizedBox.shrink(),
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

    // Calculate actual width for each chip using TextPainter
    for (int i = 0; i < permissions.length; i++) {
      final chipWidth = _calculateChipWidth(permissions[i]);
      final spaceNeeded = firstRowChips.isEmpty ? 0 : spacing;

      // Try to add to first row if it fits (with safety margin)
      if (!firstRowFull && firstRowWidth + spaceNeeded + chipWidth <= maxWidth - 5) {
        if (firstRowChips.isNotEmpty) {
          firstRowChips.add(SizedBox(width: spacing));
          firstRowWidth += spacing;
        }
        firstRowChips.add(_buildChip(permissions[i], i));
        firstRowWidth += chipWidth;
      }
      // First row is full, start second row
      else if (!firstRowFull) {
        firstRowFull = true;
        // Add current chip to second row
        secondRowChips.add(_buildChip(permissions[i], i));
        secondRowWidth += chipWidth;
      }
      // Both rows started, now alternate between them
      else {
        // Check which row is shorter and add to that row
        if (firstRowWidth <= secondRowWidth) {
          // Add to first row
          firstRowChips.add(SizedBox(width: spacing));
          firstRowChips.add(_buildChip(permissions[i], i));
          firstRowWidth += spacing + chipWidth;
        } else {
          // Add to second row
          if (secondRowChips.isNotEmpty) {
            secondRowChips.add(SizedBox(width: spacing));
            secondRowWidth += spacing;
          }
          secondRowChips.add(_buildChip(permissions[i], i));
          secondRowWidth += chipWidth;
        }
      }
    }

    // Check if we need scroll (either row exceeds maxWidth)
    bool needsScroll = firstRowWidth > maxWidth || secondRowWidth > maxWidth;

    // Build content with both rows
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // First Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: firstRowChips,
        ),
        if (secondRowChips.isNotEmpty) ...[
          SizedBox(height: 8.w),
          // Second Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: secondRowChips,
          ),
        ],
      ],
    );

    // Wrap in SingleChildScrollView if needed (both rows scroll together)
    if (needsScroll) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    return content;
  }

  // ✅ Added fade-in animation for each chip
  Widget _buildChip(String text, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 30)), // Staggered animation
      curve: Curves.bounceIn,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)), // Slide up effect
            child: child,
          ),
        );
      },
      child: Container(
        height: 32.sp,
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.font12BlackCairoRegular,
        ),
      ),
    );
  }

  double _calculateChipWidth(String text) {
    // Use TextPainter for accurate text width measurement
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.font12BlackCairoRegular,
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    // Add horizontal padding (10.sp on each side = 20.sp total)
    // Add extra margin for border radius and rendering safety
    return textPainter.width + 20.sp + 4; // Extra 4 pixels for safety
  }

  String _getModuleDisplayName(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return 'Service'.tr;
      case 'todo':
        return 'To Do List'.tr;
      case 'notes':
        return 'Notes'.tr;
      case 'knowledge_hub':
        return 'Knowledge Hub'.tr;
      case 'notification':
        return S.of(context).notifications;
      case 'qiyas':
      case 'grc':
        return 'Qiyas'.tr;
      case 'inventory':
        return 'Inventory'.tr;
      case 'messages':
        return 'Messages'.tr;
      case 'form_builder':
        return 'Form Builder'.tr;
      case 'roles':
        return 'Roles'.tr;
      case 'settings':
        return 'Settings'.tr;
      case 'employees':
        return 'Employees'.tr;
      case 'tasks':
        return 'Tasks'.tr;
      case 'events':
        return 'Events'.tr;
      case 'requests':
        return 'Requests'.tr;
      case 'tracking':
        return 'Tracking'.tr;
      case 'database_builder':
        return 'Database Builder'.tr;
      default:
        return moduleName.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : ''
        ).join(' ');
    }
  }

  String _formatPermissionName(String permissionKey) {
    // Convert snake_case to Title Case
    String formatted = permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');

    // ✅ ADD THIS LINE:
    return formatted.tr;
  }
}