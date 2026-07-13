import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/small_drop_down.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';

class AccessSearchAndFilter extends StatefulWidget {
  AccessSearchAndFilter({super.key});

  @override
  State<AccessSearchAndFilter> createState() => _AccessSearchAndFilterState();
}

class _AccessSearchAndFilterState extends State<AccessSearchAndFilter> {
  late UserManagementAccessCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Row(
          spacing: 10.sp,
          children: [
            AppSearchTextField(

              controller: controller.addNewSearchController,
              onChanged: (value) {
                controller.filterEmployeesToGiveAccess(value);
              },
            ),
            _buildDepartment(context)
          ],
        ),
      ],
    );
  }

  Widget _buildDepartment(BuildContext context) {
    final departmentItems = Get.find<MainCoreDepartmentController>()
        .departmentIds
        .map((String department) => department)
        .toList();

    final width = ContextExtension(context).isTablet ? 180.sp : 120.sp;

    return SizedBox(
      width: width,
      child: CustomDropdown<String>(
        hint: context.isArabic ? S.of(context).department : 'Select Department',
        items: departmentItems.map((department) {
          final label = FormatHelper.capitalize(
            context.isArabic
                ? Get.find<MainCoreDepartmentController>()
                        .getArabicDepartmentNameFromDepartmentId(
                            departmentId: department) ??
                    ''
                : Get.find<MainCoreDepartmentController>()
                        .getEnglishDepartmentNameFromDepartmentId(
                            departmentId: department) ??
                    '',
          );
          return DropdownItem<String>(value: department, label: label);
        }).toList(),
        value: controller.addNewAccessDepartmentId,
        triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        borderRadius: BorderRadius.circular(8.r),
        onChanged: (value) {
          if (controller.addNewAccessDepartmentId == value) {
            controller.addNewAccessDepartmentId = null;
          } else {
            controller.addNewAccessDepartmentId = value;
          }
          controller.filterEmployeesToGiveAccess(
              controller.addNewSearchController.text);
          setState(() {});
        },
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText.withOpacity(.7),
        ),
        itemStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
        ),
        required: false,
      ),
    );
  }
}