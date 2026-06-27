// ... (keeping all imports the same)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';

import 'package:demo_app/features/roles/widgets/confirm_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/text_single_field.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/data/models/role_model.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/role_image_editor.dart';
import 'package:demo_app/features/roles/role_management/utils/role_log_service.dart';

class EditingRolePage extends StatefulWidget {
  EditingRolePage({super.key});

  @override
  State<EditingRolePage> createState() => _EditingRolePageState();
}

class _EditingRolePageState extends State<EditingRolePage> {
  late RoleCubit controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    controller = context.read<RoleCubit>();

    return Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: isTablet ? 30.sp : 15.sp, end: 15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'Platform Controls and Management'.tr,
                      'Role Details'.tr,
                      'Editing Role'.tr
                    ],
                  ),
                  Expanded(
                      child: Container(
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 15.sp,
                              children: [
                                RoleImageEditor(),
                                Row(
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: SizedBox(
                                        width: MediaQuery.sizeOf(context).width * .415,
                                        child: CustomTextField(
                                          label: 'Role Name'.tr,
                                          controller: controller.roleNameController,
                                          hint: '',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 20.sp),
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: SizedBox(
                                        width: MediaQuery.sizeOf(context).width * .415,
                                        child: TextSingleField(
                                          isReadOnly: false,
                                          height: 36,
                                          typeName: 'اسم الدور',
                                          hintText: "آكتب هنا",
                                          controller: controller.roleNameControllerAr,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextSingleField(
                                  typeName: 'Role Description'.tr,
                                  maxLines: 3,
                                  showCounter: true,
                                  maxLength: 500,
                                  controller: controller.roleDescriptionController,
                                ),
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextSingleField(
                                    typeName: 'وصف الدور',
                                    maxLines: 3,
                                    maxLength: 500,
                                    hintText: "آكتب هنا",
                                    showCounter: true,
                                    controller: controller.roleDescriptionControllerAr,
                                  ),
                                ),
                                Container(),
                                Text(
                                  "Select Module".tr,
                                  style: AppTextStyles.font16BlackRegularCairo,
                                ),
                                BlocBuilder<RoleCubit, RoleState>(
                                  buildWhen: (_, state) {
                                    return (state is RoleModuleSelected);
                                  },
                                  builder: (context, state) {

                                    // ✅ FIXED: Search for MULTIPLE admin role names
                                    RoleHistoryModel? superAdminRole;
                                    List<String> adminRoleNames = [
                                      'admin_role',
                                      'super admin',
                                      'master admin',
                                      'superadmin',
                                      'masteradmin',
                                    ];

                                    for (var role in controller.roles) {
                                      String roleName = role.currentRoleName.toLowerCase().trim();

                                      if (adminRoleNames.contains(roleName)) {
                                        superAdminRole = role;
                                        break;
                                      }
                                    }

                                    if (superAdminRole == null) {
                                      for (var role in controller.roles) {
                                      }

                                      return Container(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Text(
                                              "No admin role found to copy modules from.",
                                              style: TextStyle(color: Colors.red, fontSize: 16),
                                            ),
                                            SizedBox(height: 10),
                                            Text("Available roles_module:"),
                                            ...controller.roles.map((r) => Text("  • ${r.currentRoleName}")),
                                          ],
                                        ),
                                      );
                                    }


                                    List<String> activeModuleStrings =
                                    List<String>.from(superAdminRole.currentSelectedModules);


                                    // ✅ ALLOWED MODULES INCLUDING TRACKING
                                    List<String> allowedModuleNames = [
                                      'services',
                                      'todo',
                                      'notes',
                                      'knowledge_hub',
                                      'qiyas',
                                      'database',
                                      'grc',
                                      'inventory',
                                      'messages',
                                      'form_builder',
                                      'tracking',
                                      'roles',
                                      'settings',
                                    ];

                                    // ✅ Filter to only allowed modules
                                    activeModuleStrings = activeModuleStrings
                                        .where((module) => allowedModuleNames.contains(module))
                                        .toList();


                                    // ✅ Ensure settings is always included
                                    if (!activeModuleStrings.contains('settings')) {
                                      activeModuleStrings.add('settings');
                                    }

                                    // ✅ Convert to enum
                                    List<Modules> activeModules = [];

                                    for (var moduleName in activeModuleStrings) {
                                      try {
                                        Modules moduleEnum = _stringToModuleEnum(moduleName);
                                        activeModules.add(moduleEnum);
                                      } catch (e) {
                                      }
                                    }

                                    if (activeModules.isEmpty) {
                                      return Container(
                                        padding: EdgeInsets.all(20),
                                        child: Text(
                                          "No modules available to display.",
                                          style: TextStyle(color: Colors.red, fontSize: 16),
                                        ),
                                      );
                                    }


                                    return GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: activeModules.length,
                                      gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isTablet ? 14 : 4,
                                        mainAxisSpacing: 10.sp,
                                        crossAxisSpacing: 10.sp,
                                        mainAxisExtent: 55.w,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (_, index) {
                                        return moduleItem(activeModules[index], context);
                                      },
                                    );
                                  },
                                )
                              ]),
                        ),
                      )),
                  SizedBox(height: 20.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        width: isTablet ? 135 : 120,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        buttonText: 'Discard'.tr,
                        buttonColor: AppColors.secondaryButton,
                        textStyle: AppTextStyles.font16BlackRegularCairo,
                      ),
                      CustomButton(
                        width: isTablet ? 135 : 120,
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            ConfirmDialog().show(context,
                                title: 'Edit Role'.tr,
                                subtitle: 'Are you sure you want to edit this role?'.tr,
                                icon: 'assets/lottie/Edit Document.json',
                                onCancel: () {},
                                onConfirm: () async {
                                  RoleLogService.log(RoleLogService.actionUpdateRole);
                                  showLoadingIndicator();
                                  try {
                                    await controller.updateRole();
                                    hideLoadingIndicator();
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    hideLoadingIndicator();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update role: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                });
                          }
                        },
                        buttonText: 'Save'.tr,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ));
  }

  Widget moduleItem(Modules module, BuildContext context) {
    String moduleString = _moduleEnumToString(module);
    bool isSelected = controller.selectedModules.contains(moduleString);

    return InkWell(
      onTap: () {
        if (module != Modules.settings) {
          controller.selectModule(moduleString);
        }
      },
      child: Container(
        width: 55.w,
        height: 55.w,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: (isSelected || module == Modules.settings)
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: SvgPicture.asset(
          module.iconPath,
          height: 30.sp,
          width: 30.sp,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            (isSelected || module == Modules.settings)
                ? AppColors.textButton
                : AppColors.secondaryBlack,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Modules _stringToModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return Modules.services;
      case 'employees':
        return Modules.employees;
      case 'todo':
        return Modules.todo;
      case 'notes':
        return Modules.notes;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'form_builder':
        return Modules.formBuilder;
      case 'grc':
        return Modules.grc;
      case 'tracking':
        return Modules.tracking;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      default:
        throw Exception("Unknown module: $moduleName");
    }
  }

  String _moduleEnumToString(Modules module) {
    switch (module) {
      case Modules.services:
        return 'services';
      case Modules.todo:
        return 'todo';
      case Modules.notes:
        return 'notes';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.formBuilder:
        return 'form_builder';
      case Modules.grc:  // ✅ ADD THIS
        return 'grc';
      case Modules.employees:  // ✅ ADD THIS
        return 'employees';
      case Modules.tracking:
        return 'tracking';
      case Modules.roles:
        return 'roles';
      case Modules.settings:
        return 'settings';
      default:
        return 'settings';
    }
  }
}