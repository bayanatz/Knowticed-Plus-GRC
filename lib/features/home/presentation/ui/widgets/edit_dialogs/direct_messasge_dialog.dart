import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/custom_button.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/home/data/models/direct_message_model.dart';

import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/features/home/widgets/person_state_view.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/small_drop_down.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../department/presentation/controller/add_department_controller.dart';

class DirectMessageDialog extends StatefulWidget {
  DirectMessageDialog({required this.model, required this.onSave, super.key});
  DirectMessageModel model;
  Function() onSave;
  @override
  State<DirectMessageDialog> createState() => _DirectMessageDialogState();
}

class _DirectMessageDialogState extends State<DirectMessageDialog> {
  List<EmployeeEntityPro> allEmployees =
      Get.find<MainCoreEmployeeController>().allEmployeesEntities!;
  String? selectedDepartmentId;
  List<String> selectedUsers = [];
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<EmployeeEntityPro> employees = filterEmployees(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 15.sp,
      children: [
        Row(
          spacing: 8.sp,
          children: [
            CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 20,
                child: SvgPicture.asset(
                    'assets/skeleton/home/icons/contact.svg',
                    color: AppColors.textButton)),
            Text('Contact'.tr, style: AppTextStyles.font16BlackMediumCairo)
          ],
        ),
        Row(
          spacing: 10.sp,
          children: [
            AppSearchTextField(
              controller: controller,
              onChanged: (value) {
                setState(() {});
              },
              fillColor: AppColors.background,
            ),
            _buildDepartment(context)
          ],
        ),
        Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                          context),
                  mainAxisExtent: 75.sp,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: ContextExtension(context).isPhone ? 1.5 : 1.2,
                ),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  return PersonStateView(
                    color: AppColors.background,
                    person: employees[index],
                    isSelected: selectedUsers.contains(employees[index].email!),
                    onTap: () {
                      setState(() {
                        if (selectedUsers.contains(employees![index]!.email!)) {
                          selectedUsers.remove(employees[index]!.email!);
                        } else {
                          selectedUsers.add(employees![index]!.email!);
                        }
                      });
                    },
                  );
                })),
        SizedBox(height: 20.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomButton(
              buttonText: 'Cancel'.tr,
              onTap: () {
                Navigator.of(context).pop();
              },
              buttonColor: AppColors.secondaryButton,
              textStyle: AppTextStyles.font16BlackRegularCairo,
              width: 135,
            ),
            CustomButton(
              buttonText: 'Add'.tr,
              onTap: () {
                widget.model.usersEmails = selectedUsers.toSet().toList();
                Navigator.of(context).pop();
                widget.onSave?.call();
              },
              width: 135,
            )
          ],
        ),
        SizedBox(height: 20.sp)
      ],
    );
  }

  List<EmployeeEntityPro> filterEmployees(BuildContext context) {
    List<EmployeeEntityPro> filteredEmployees = [];
    for (EmployeeEntityPro employee in allEmployees) {
      if (employee.departmentId == selectedDepartmentId ||
          selectedDepartmentId == null) {
        if (EmployeeHelper.getEmployeeLocalizedName(
                employee: employee, context: context)
            .contains(controller.text)) {
          filteredEmployees.add(employee);
        }
      }
    }
    return filteredEmployees;
  }

  _buildDepartment(BuildContext context) {
    if (context.isTablett) {
      return SizedBox(
        width: 180.sp,
        height: 38.h,
        child: AppDropdown(
          value: selectedDepartmentId,
          width: double.infinity,
          fillColor: AppColors.background,
          textButton: 'Department'.tr,
          items: Get.find<MainCoreDepartmentController>()
              .departmentIds
              .map((String department) {
            bool isSelected = selectedDepartmentId == department;
            return DropdownMenuItem<String>(
              value: department.tr,
              child: Text(
                FormatHelper.capitalize(
                  context.isArabic
                      ? Get.find<MainCoreDepartmentController>()
                          .getArabicDepartmentNameFromDepartmentId(
                              departmentId: department)!
                      : Get.find<MainCoreDepartmentController>()
                          .getEnglishDepartmentNameFromDepartmentId(
                              departmentId: department)!,
                ),
                style: AppTextStyles.font14SecondaryBlackCairo.copyWith(
                  color: isSelected ? AppColors.text : AppColors.secondaryBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (p0) {
            if (selectedDepartmentId == p0)
              selectedDepartmentId = null;
            else
              selectedDepartmentId = p0;
            setState(() {});
          },
        ),
      );
    }

    return SizedBox(
      width: 36.sp,
      height: 36.sp,
      child: SmallDropdown(
        value: null,
        menuWidth: 300.w,

        //width: double.infinity,
        fillColor: AppColors.background,
        textButton: 'Department',
        items: Get.find<MainCoreDepartmentController>()
            .departmentIds
            .map((String department) {
          bool isSelected = selectedDepartmentId == department;
          return DropdownMenuItem<String>(
            value: department.tr,
            child: Text(
              FormatHelper.capitalize(
                context.isArabic
                    ? Get.find<MainCoreDepartmentController>()
                        .getArabicDepartmentNameFromDepartmentId(
                            departmentId: department)!
                    : Get.find<MainCoreDepartmentController>()
                        .getEnglishDepartmentNameFromDepartmentId(
                            departmentId: department)!,
              ),
              style: AppTextStyles.font14SecondaryBlackCairo.copyWith(
                color: isSelected ? AppColors.text : AppColors.secondaryBlack,
              ),
            ),
          );
        }).toList(),
        onChanged: (p0) {
          if (selectedDepartmentId == p0)
            selectedDepartmentId = null;
          else
            selectedDepartmentId = p0;
          setState(() {});
        },
      ),
    );
  }
}
