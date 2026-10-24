/// Module: services / sv11_department_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_dialog.dart
/// Purpose: Filter dialog of the department dashboard — departments,
///          statuses and request date.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_view_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class FilterDialogDashBoard {
  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    String? currentDepartment,
    String? currentStatus,
    DateTime? currentDate,
    required Map<String, String> departmentEnToAr,
    required String filterText,
    required String departmentText,
    required String requestDateText,
    required String statusText,
    required String resetText,
    required String applyText,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
  }) async {
    List<String> selectedDepartments =
        (currentDepartment != null && currentDepartment.isNotEmpty)
            ? [currentDepartment]
            : [];
    List<String> selectedStatuses =
        (currentStatus != null && currentStatus.isNotEmpty)
            ? [currentStatus]
            : [];
    DateTime? selectedDate = currentDate;

    final isArabic = context.svcIsArabic;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    const statuses = RequestStatus.all;
    String localizeStatus(String status) => context.svcStatus(status);

    return await showAppDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: AppColors.card,
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: StatefulBuilder(
              builder: (context, setState) {
                final isMobile = ContextExtension(context).isPhone;

                // Department display text
                String deptDisplayText;
                if (selectedDepartments.isEmpty) {
                  deptDisplayText = departmentText;
                } else if (selectedDepartments.length == 1) {
                  final name = selectedDepartments.first;
                  deptDisplayText =
                      isArabic ? (departmentEnToAr[name] ?? name) : name;
                } else {
                  deptDisplayText =
                      '${selectedDepartments.length} ${S.of(context).selected}';
                }

                // Status display text
                String statusDisplayText;
                if (selectedStatuses.isEmpty) {
                  statusDisplayText = statusText;
                } else if (selectedStatuses.length == 1) {
                  statusDisplayText = localizeStatus(selectedStatuses.first);
                } else {
                  statusDisplayText =
                      '${selectedStatuses.length} ${S.of(context).selected}';
                }

                // Department items (localized labels)
                final List<String> departmentItems =
                    departmentEnToAr.entries.map((e) {
                  return isArabic ? e.value : e.key;
                }).toList();

                // Status items (localized labels)
                final List<String> statusItems =
                    statuses.map((s) => localizeStatus(s)).toList();

                // ── Shared widgets ──
                final departmentDropdown = CustomMultiSelectField(
                  items: departmentItems,
                  selectedItems: selectedDepartments.map((engName) {
                    return isArabic
                        ? (departmentEnToAr[engName] ?? engName)
                        : engName;
                  }).toList(),
                  textButton: deptDisplayText,
                  hintText: departmentText,
                  fillColor: AppColors.background,
                  onChanged: (item) {
                    String engName = item;
                    if (isArabic) {
                      engName = departmentEnToAr.entries
                          .firstWhere(
                            (e) => e.value == item,
                            orElse: () => MapEntry(item, item),
                          )
                          .key;
                    }
                    setState(() {
                      if (selectedDepartments.contains(engName)) {
                        selectedDepartments.remove(engName);
                      } else {
                        selectedDepartments.add(engName);
                      }
                    });
                  },
                );

                final dateField = _buildDateField(
                  context: context,
                  selectedDate: selectedDate,
                  hintText: requestDateText,
                  onDatePicked: (val) => setState(() => selectedDate = val),
                );

                final statusDropdown = CustomMultiSelectField(
                  items: statusItems,
                  selectedItems:
                      selectedStatuses.map((s) => localizeStatus(s)).toList(),
                  textButton: statusDisplayText,
                  hintText: statusText,
                  fillColor: AppColors.background,
                  onChanged: (item) {
                    final engStatus = statuses.firstWhere(
                      (s) => localizeStatus(s) == item,
                      orElse: () => item,
                    );
                    setState(() {
                      if (selectedStatuses.contains(engStatus)) {
                        selectedStatuses.remove(engStatus);
                      } else {
                        selectedStatuses.add(engStatus);
                      }
                    });
                  },
                );

                return Container(
                  width: isMobile ? double.infinity : 645.sp,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header ──
                      CustomDialogHeader(
                        title: filterText,
                        icon:
                            "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                      ),
                      SizedBox(height: 15.sp),

                      // ── Filter Fields ──
                      if (isMobile) ...[
                        // ── MOBILE: stacked vertically ──
                        departmentDropdown,
                        SizedBox(height: 12.sp),
                        dateField,
                        SizedBox(height: 12.sp),
                        statusDropdown,
                      ] else ...[
                        // ── TABLET / DESKTOP: rows ──
                        Row(
                          children: [
                            Expanded(child: departmentDropdown),
                            SizedBox(width: 20.sp),
                            Expanded(child: dateField),
                          ],
                        ),
                        SizedBox(height: 15.sp),
                        Row(
                          children: [
                            Expanded(child: statusDropdown),
                            SizedBox(width: 20.sp),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],

                      SizedBox(height: 15.sp),

                      // ── Buttons ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                            title: resetText,
                            function: () {
                              setState(() {
                                selectedDepartments = [];
                                selectedStatuses = [];
                                selectedDate = null;
                              });
                            },
                            color: lightMode
                                ? AppColors.grey
                                : AppColors.mediumGrey,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                            ),
                            height: 38.sp,
                            width: isMobile ? 120.sp : 135.sp,
                          ),
                          customButton(
                            title: applyText,
                            function: () {
                              Navigator.pop(dialogContext, {
                                'department': selectedDepartments.isNotEmpty
                                    ? selectedDepartments.first
                                    : null,
                                'status': selectedStatuses.isNotEmpty
                                    ? selectedStatuses.first
                                    : null,
                                'date': selectedDate,
                                'departments': selectedDepartments,
                                'statuses': selectedStatuses,
                              });
                            },
                            color: AppColors.primary,
                            radius: 8.r,
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            height: 38.sp,
                            width: isMobile ? 120.sp : 135.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Date Field ──
  static Widget _buildDateField({
    required BuildContext context,
    required DateTime? selectedDate,
    required String hintText,
    required ValueChanged<DateTime?> onDatePicked,
  }) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () async {
        final picked = await DatePicker().showDatePicker(
          context,
          selectedDate != null ? [selectedDate] : [],
          selectedDate ?? DateTime.now(),
          CalendarDatePicker2Type.single,
          firstDate: DateTime(2020),
        );
        if (picked != null && picked.isNotEmpty && picked.first != null) {
          onDatePicked(picked.first);
        }
      },
      child: Container(
        height: 38.sp,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // FIXED 9/9/2026 — the calendar glyph sat closer to the trailing
        // edge than the chevron on the dropdown beside it. `CustomDropdown` /
        // `AppMultiSelectDropdown` give their suffix 12 against that edge and
        // their text 12 against the leading one, so 12 here lines both up.
        // Symmetric, so it mirrors on its own: the `Row` below flips with the
        // text direction, putting the calendar on the LEFT in Arabic with the
        // same 12 against that edge.
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(selectedDate)
                    : hintText,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: selectedDate != null
                      ? AppColors.text
                      : AppColors.secondaryText,
                ),
              ),
            ),
            CustomSvgImage.natural(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
              width: 20.sp,
              height: 20.sp,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
