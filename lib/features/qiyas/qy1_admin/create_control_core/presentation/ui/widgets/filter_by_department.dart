import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/features/roles/r4_active_directory/presentation/controller/add_department_controller.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

abstract class FilterByDepartmentDialog {
  static Future<dynamic> show(
      ControlCoreCubit controller, BuildContext context) {
    return showAppDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(child: FilterByDepartment(controller: controller));
        });
  }
}

class FilterByDepartment extends StatelessWidget {
  const FilterByDepartment({super.key, required this.controller});
  final ControlCoreCubit controller;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(16.sp),
          width: isTablet ? 360.w : 300.w,
          child: Column(
            spacing: 20.sp,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 20./16./16. row.
              CustomDialogHeader(
                  title: "فرز",
                  icon:
                      "assets/icons_assets/main_icons_assets/ic_action_sort.svg"),
              /* MIGRATED 17/10/2026: AppMultiSelectDropdown → CustomMultiSelectFilter (one multi-select for filters) */ CustomMultiSelectFilter<
                  String>(
                values: List<String>.from(controller.selectedDepartmentsFilter),
                items: [
                  for (final String i
                      in Get.find<MainCoreDepartmentController>()
                          .departmentsArabicName)
                    MultiSelectDropdownItem<String>(value: i, label: i)
                ],
                onChanged: multiSelectToggleBridge(
                    List<String>.from(controller.selectedDepartmentsFilter),
                    (String item) {
                  controller.selectDepartmentFilter(item);
                }),
                hint: "قسم",
                height: 38.sp,
                fillColor: AppColors.background,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: 'إعادة',
                    color: AppColors.secondaryButton,
                    function: () {
                      Navigator.pop(context);
                      controller.clearHomeFilters();
                    },
                    textStyle: StyleText.fontSize16Weight500,
                    width: isTablet ? 150 : 130,
                  ),
                  customButton(
                    title: 'تطبيق',
                    function: () {
                      Navigator.pop(context);
                      controller.filterEmployees();
                    },
                    width: isTablet ? 150 : 130,
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
