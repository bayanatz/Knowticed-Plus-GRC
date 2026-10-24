/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_department_filter.dart
/// Purpose: Phone-only department filter for the Approvals queue.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ApprovalsDepartmentFilterButton extends StatelessWidget {
  const ApprovalsDepartmentFilterButton({
    super.key,
    required this.selectedKeys,
    required this.onChanged,
  });

  /// Selected department IDs.
  final List<String> selectedKeys;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool active = selectedKeys.isNotEmpty;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () async {
        final result = await _showDepartmentDialog(context, selectedKeys);
        if (result != null) onChanged(result);
      },
      child: Container(
        width: 38.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          // Yellow while a department filter is on, like the Sort button when
          // a sort is chosen, so an active filter is visible at a glance.
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CustomSvgImage.natural(
            assetPath:
                "assets/icons_assets/main_icons_assets/ic_org_department_people_yellow.svg",
            width: 20.sp,
            height: 20.sp,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              active ? AppColors.textButton : AppColors.secondaryText,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>?> _showDepartmentDialog(
    BuildContext context,
    List<String> initial,
  ) async {
    final departments = context.read<MainCoreDepartmentCubit>();
    if (departments.departmentIds.isEmpty) {
      await departments.getAllDepartments();
    }
    if (!context.mounted) return null;

    final List<String> ids = List<String>.from(departments.departmentIds);
    final List<String> picked = List<String>.from(initial);

    return showAppDialog<List<String>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.card,
          child: StatefulBuilder(
            builder: (builderContext, setDialogState) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: 645.sp,
                  minWidth: 300.sp,
                  maxHeight: MediaQuery.sizeOf(builderContext).height * 0.7,
                ),
                padding: EdgeInsets.all(15.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30.sp,
                          height: 30.sp,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/main_icons_assets/ic_org_department_people_yellow.svg",
                              width: 16.sp,
                              height: 16.sp,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                AppColors.textButton,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.sp),
                        Text(
                          S.of(builderContext).department,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: ids.length,
                        separatorBuilder: (_, __) => SizedBox(height: 4.sp),
                        itemBuilder: (_, i) {
                          final id = ids[i];
                          final bool isOn = picked.contains(id);
                          return InkWell(
                            onTap: withHaptic(
                              () => setDialogState(() {
                                isOn ? picked.remove(id) : picked.add(id);
                              }),
                              HapticLevel.low,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.sp),
                              child: Row(
                                children: [
                                  CustomCheckBox(isSelected: isOn, size: 20.sp),
                                  SizedBox(width: 10.sp),
                                  Expanded(
                                    child: Text(
                                      FormatHelper.capitalize(
                                        context.svcDepartmentName(id),
                                      ),
                                      style: StyleText.fontSize14Weight400
                                          .copyWith(color: AppColors.text),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      children: [
                        Expanded(
                          child: customButton(
                            title: S.of(builderContext).Reset,
                            function: () => Navigator.of(dialogContext)
                                .pop(const <String>[]),
                            color: AppColors.secondaryAction,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.onSecondaryAction,
                            ),
                            height: 42.sp,
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        Expanded(
                          child: customButton(
                            title: S.of(builderContext).Apply,
                            function: () =>
                                Navigator.of(dialogContext).pop(picked),
                            color: AppColors.primary,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            height: 42.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
