import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';

import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/utils/role_log_service.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/dialog.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/module_switches_builder.dart';
import 'settings_switches_page.dart';

class RolePermissionSwitches extends StatelessWidget {
  RolePermissionSwitches({super.key});
  late bool isTablet;
  late RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 30.sp : 15.sp,
            ),
            child: BlocBuilder<RoleCubit, RoleState>(
              buildWhen: (previous, current) =>
              current is RoleSwitchToggled ||
                  current is RoleSelected ||
                  current is RolePermissionLoaded ||
                  current is RolePermissionUpdated,
              builder: (context, state) {
                List<Modules> selectedModulesAsEnum = controller.selectedModules
                    .map((moduleString) => _stringToModuleEnum(moduleString))
                    .toList();

                List<Modules> modulesWithPermissions = selectedModulesAsEnum
                    .where((module) => Modules.modulesHasPermission.contains(module))
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                        screensTitles: controller.isEditing
                            ? [
                          s.platformControlsAndManagement,
                          s.roleDetails,
                          s.editingRole,
                          s.editRolePermissions,
                        ]
                            : [
                          s.platformControlsAndManagement,
                          s.addingNewRole,
                          s.rolePermissions,
                        ]),
                    Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 15.sp,
                            children: [
                              if (modulesWithPermissions.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(20.sp),
                                  margin: EdgeInsets.symmetric(vertical: 20.sp),
                                  decoration: BoxDecoration(
                                    color: AppColors.field,
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.info_outline, size: 48, color: AppColors.primary),
                                      SizedBox(height: 16),
                                      Text(
                                        '${s.selectedModules}: ${controller.selectedModules.join(", ")}',
                                        style: AppTextStyles.font16BlackRegularCairo,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        s.noPermissionNeeded,
                                        style: AppTextStyles.font14BlackRegularCairo,
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        s.clickNextToContinue,
                                        style: AppTextStyles.font16BlackRegularCairo.copyWith(
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                              for (Modules module in modulesWithPermissions)
                                ModuleSwitchesBuilder(module: module),
                            ],
                          ),
                        )),
                    SizedBox(height: 20.sp),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          spacing: 5.sp,
                          children: [
                            CustomButton(
                              buttonText: s.back,
                              buttonColor: AppColors.secondaryButton,
                              textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                                color: Colors.black,
                              ),
                              width: isTablet ? 135 : 120,
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            if (!controller.isEditing)
                              CustomButton(
                                buttonText: s.saveForLater,
                                buttonColor: AppColors.secondaryButton,
                                textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                                    color: lightMode ? Colors.black : Colors.white
                                ),
                                width: isTablet ? 135 : 120,
                                onTap: () {
                                  RoleLogService.log(RoleLogService.actionCreateRole);
                                  RoleDialogs.showSaveForLaterDialog(
                                    context: context,
                                    controller: controller,
                                    pagesToPop: 2,
                                  );
                                },
                              )
                          ],
                        ),
                        CustomButton(
                          buttonText: s.next,
                          width: isTablet ? 135 : 120,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BlocProvider<RoleCubit>.value(
                                  value: controller,
                                  child: SettingsSwitchesPage(),
                                )));
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 20.sp),
                  ],
                );
              },
            ),
          )),
    );
  }

  Modules _stringToModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'employees': return Modules.employees;
      case 'services': return Modules.services;
      case 'tasks': return Modules.tasks;
      case 'todo': return Modules.todo;
      case 'events': return Modules.events;
      case 'notes': return Modules.notes;
      case 'requests': return Modules.requests;
      case 'knowledge_hub': return Modules.knowledgeHub;
      case 'qiyas': return Modules.qiyas;
      case 'grc': return Modules.grc;
      case 'tracking': return Modules.tracking;
      case 'inventory': return Modules.inventory;
      case 'messages': return Modules.messages;
      case 'database_builder': return Modules.database;
      case 'form_builder': return Modules.formBuilder;
      case 'roles': return Modules.roles;
      case 'hr': return Modules.hr;
      case 'notification': return Modules.notification;
      case 'settings': return Modules.settings;
      default:
        return Modules.employees;
    }
  }
}