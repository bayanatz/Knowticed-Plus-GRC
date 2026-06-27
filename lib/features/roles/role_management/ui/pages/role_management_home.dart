import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/role_overview.dart';
import 'package:flutter/src/services/haptic_feedback.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/roles/role_management/utils/role_log_service.dart';
import 'package:demo_app/core/helper/main_helper/circle_progress.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/export_role_widget.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/grid_table_export.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/platform_roles_header.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/roles_filter_row.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/table_widget.dart';

class PlatFormRoleContainer extends StatefulWidget {
  const PlatFormRoleContainer.RoleManagementHome({super.key});

  @override
  State<PlatFormRoleContainer> createState() => _PlatFormRoleContainerState();
}

class _PlatFormRoleContainerState extends State<PlatFormRoleContainer> {
  bool isGridView = true; // Default to grid view

  @override
  void initState() {
    super.initState();

    // CLEAR SEARCH WHEN PAGE LOADS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoleCubit>().searchController.clear();
      context.read<RoleCubit>().getUnDeletedRoles(); // CHANGED: Call getUnDeletedRoles instead of filterRoles
      RoleLogService.log(RoleLogService.pageRoleManagementHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    RoleCubit controller = context.read<RoleCubit>();

    return BlocBuilder<RoleCubit, RoleState>(
        buildWhen: (previous, current) =>
        current is RoleLoading ||        // ADD THIS
            current is RoleStatusSelected ||
            current is RoleFetched ||
            current is RoleFiltered ||
            current is RoleError,            // ADD THIS
        builder: (context, state) {

          // ADD THIS LOADING CHECK
          if (state is RoleLoading) {
            return Column(
              spacing: 15.sp,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformRolesHeader(),
                Row(
                  children: [
                    RolesFilterRow(),
                    Spacer(),
                    ViewToggleButtons(
                      isGridView: isGridView,
                      onTableViewTap: () {
                        setState(() {
                          isGridView = false;
                        });
                      },
                      onGridViewTap: () {
                        setState(() {
                          isGridView = true;
                        });
                      },
                      showExport: true,
                      onExportTap: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.heavyImpact,
                            hapticFeedback: HapticFeedback.heavyImpact
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => RoleExportDialog(
                            roles: controller.filteredRoles,
                          ),
                        );
                      },
                    )
                  ],
                ),
                Expanded(
                  child: CircleProgressMaster(),
                )
              ],
            );
          }

          return Column(
            spacing: 15.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlatformRolesHeader(),
              Row(
                children: [
                  RolesFilterRow(),
                  Spacer(),
                  ViewToggleButtons(
                    isGridView: isGridView,
                    onTableViewTap: () {
                      setState(() {
                        isGridView = false;
                      });
                    },
                    onGridViewTap: () {
                      setState(() {
                        isGridView = true;
                      });
                    },
                    showExport: true,
                    onExportTap: () {
                      hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback: HapticFeedback.heavyImpact
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => RoleExportDialog(
                          roles: controller.filteredRoles,
                        ),
                      );
                    },
                  )
                ],
              ),
              Expanded(
                child: controller.filteredRoles.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/empty.json',
                        width: 400.sp,
                        height: 400.sp,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                )
                    : isGridView
                    ? _buildGridView(controller.filteredRoles)
                    : _buildTableView(controller.filteredRoles),
              )
            ],
          );
        });
  }

  Widget _buildGridView(List<RoleHistoryModel> roles) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10.sp,
        children: [
          for (RoleHistoryModel role in roles) RoleOverview(role: role)
        ],
      ),
    );
  }

  Widget _buildTableView(List<RoleHistoryModel> roles) {
    return SingleChildScrollView(
      child: RoleTableView(
        roles: roles,
        locale: Get.locale?.languageCode ?? 'en',
      ),
    );
  }
}