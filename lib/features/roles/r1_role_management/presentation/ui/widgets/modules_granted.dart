import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class ModulesGranted extends StatefulWidget {
  const ModulesGranted({super.key});

  @override
  State<ModulesGranted> createState() => _ModulesGrantedState();
}

class _ModulesGrantedState extends State<ModulesGranted> {
  bool isHide = false;
  late RoleCubit controller;

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // Get modules directly from selected role
    List<String> moduleStrings = controller.selectedRole?.currentSelectedModules ?? [];


    // Convert to enums
    List<Modules> moduleEnums = [];
    for (String moduleName in moduleStrings) {
      try {
        moduleEnums.add(_stringToModuleEnum(moduleName));
      } catch (e) {
      }
    }


    return Column(
      spacing: 8.sp,
      children: [
        Row(
          children: [
            Text(
              S.of(context).modules,
              style: AppTextStyles.font16BlackSemiBoldCairo,
            ),
            Spacer(),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                setState(() {
                  isHide = !isHide;
                });
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).show : S.of(context).hide,
                      style: AppTextStyles.font10BlackCairoRegular.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      height: 1,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        if (!isHide)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: moduleEnums.isEmpty
                ? Center(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Text(
                  S.of(context).noModulesGranted,
                  style: AppTextStyles.font14BlackCairoRegular,
                ),
              ),
            )
                : GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: moduleEnums.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 14 : 4,
                mainAxisSpacing: 10.sp,
                crossAxisSpacing: 10.sp,
                mainAxisExtent: 55.w,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) {
                return _moduleItem(moduleEnums[index]);
              },
            ),
          )
      ],
    );
  }

  Widget _moduleItem(Modules module) {
    return Container(
      width: 40.sp,
      height: 40.sp,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.6),
        borderRadius: BorderRadius.circular(4.sp),
      ),
      child: CustomSvgImage(assetPath: 
        module.iconPath,
        height: 30.sp,
        width: 30.sp,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          AppColors.textButton,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Modules _stringToModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return Modules.services;
      case 'todo':
        return Modules.todo;
      case 'notes':
        return Modules.notes;
      case 'knowledge_hub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'employees':
        return Modules.employees;
      case 'grc':
        return Modules.grc;
      case 'inventory':
        return Modules.inventory;
      case 'messages':
        return Modules.messages;
      case 'services_app':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'employees':
        return Modules.employees;
      case 'tasks':
        return Modules.tasks;
      case 'events':
        return Modules.events;
      case 'requests':
        return Modules.requests;
      case 'tracking':
        return Modules.tracking;
      case 'database_builder':
        return Modules.database;
      default:
        throw Exception("Unknown module: $moduleName");
    }
  }
}