/// Module: services / sv6_services_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: service_requests_filter_dialog.dart
/// Purpose: The phone filter of the "Service requests" page: pick an owning
///          department, Apply, or Reset back to all departments. On a phone
///          the department chips run off the screen, so this gives the same
///          choice in one tap.
/// Author: Amr Mesbah
/// Created at: 01/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Opens the filter and returns the chosen department id ([allKey] when
/// reset), or null when the dialog was dismissed without Apply.
///
/// [departments] maps each department id to its label.
Future<String?> showServiceRequestsFilterDialog({
  required BuildContext context,
  required Map<String, String> departments,
  required String selectedDepartment,
  required String allKey,
}) {
  String? current = selectedDepartment == allKey ? null : selectedDepartment;

  return showAppDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.card,
        child: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Container(
              constraints: BoxConstraints(maxWidth: 645.sp, minWidth: 300.sp),
              padding: EdgeInsets.all(15.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDialogHeader(
                    title: S.of(builderContext).Filter,
                    icon:
                        "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                  ),
                  SizedBox(height: 20.sp),
                  CustomDropdown<String>(
                    value: current,
                    items: departments.entries
                        .map(
                          (d) => DropdownItem<String>(
                            value: d.key,
                            label: FormatHelper.capitalize(d.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() => current = v),
                    fillColor: AppColors.background,
                    hint: S.of(builderContext).department,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 25.sp),
                  Row(
                    children: [
                      Expanded(
                        child: customButton(
                          title: S.of(builderContext).Reset,
                          function: () =>
                              Navigator.of(dialogContext).pop(allKey),
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
                          function: () => Navigator.of(dialogContext)
                              .pop(current ?? allKey),
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
