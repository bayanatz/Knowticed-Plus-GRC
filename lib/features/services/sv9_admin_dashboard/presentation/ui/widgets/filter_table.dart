/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_table.dart
/// Purpose: Filter dialog of the admin request table — departments,
///          statuses and request date; fields stack on a phone.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_view_multi_select_dropdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class TableFilterDialog extends StatefulWidget {
  final List<String> activeDepartments;
  final List<String> activeStatuses;
  final DateTime? activeDate;

  const TableFilterDialog({
    super.key,
    this.activeDepartments = const [],
    this.activeStatuses = const [],
    this.activeDate,
  });

  @override
  State<TableFilterDialog> createState() => _TableFilterDialogState();

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    List<String> activeDepartments = const [],
    List<String> activeStatuses = const [],
    DateTime? activeDate,
  }) async {
    return await showAppDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TableFilterDialog(
        activeDepartments: activeDepartments,
        activeStatuses: activeStatuses,
        activeDate: activeDate,
      ),
    );
  }
}

class _TableFilterDialogState extends State<TableFilterDialog> {
  List<String> selectedDepartments = [];
  List<String> selectedStatuses = [];
  DateTime? selectedDate;

  late final MainCoreDepartmentCubit _deptController;

  static const List<String> statuses = RequestStatus.all;

  @override
  void initState() {
    super.initState();
    selectedDepartments = List.from(widget.activeDepartments);
    selectedStatuses = List.from(widget.activeStatuses);
    selectedDate = widget.activeDate;
    _deptController = context.read<MainCoreDepartmentCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.svcIsArabic;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    // ✅ Build department items dynamically
    final List<String> departmentItems =
        _deptController.departmentsEnglishName.asMap().entries.map((entry) {
      final engName = entry.value;
      final deptId = _deptController.departmentIds[entry.key];
      if (isArabic) {
        return _deptController.getArabicDepartmentNameFromDepartmentId(
              departmentId: deptId,
            ) ??
            engName;
      }
      return engName;
    }).toList();

    // ✅ Build status items dynamically
    final List<String> statusItems = statuses.map(context.svcStatus).toList();

    // ✅ Department display text
    String deptDisplayText;
    if (selectedDepartments.isEmpty) {
      deptDisplayText = S.of(context).department;
    } else if (selectedDepartments.length == 1) {
      deptDisplayText = isArabic
          ? (_deptController.getArabicDepartmentNameFromDepartmentId(
                departmentId: _deptController.getDepartmentId(
                  selectedDepartments.first,
                ),
              ) ??
              selectedDepartments.first)
          : selectedDepartments.first;
    } else {
      deptDisplayText =
          '${selectedDepartments.length} ${S.of(context).selected}';
    }

    // ✅ Status display text
    String statusDisplayText;
    if (selectedStatuses.isEmpty) {
      statusDisplayText = S.of(context).status;
    } else if (selectedStatuses.length == 1) {
      statusDisplayText = context.svcStatus(selectedStatuses.first);
    } else {
      statusDisplayText =
          '${selectedStatuses.length} ${S.of(context).selected}';
    }

    // ✅ Department multi-select widget
    Widget departmentField = _labeled(
      S.of(context).department,
      CustomMultiSelectField(
        items: departmentItems,
        selectedItems: selectedDepartments.map((engName) {
          if (isArabic) {
            final id = _deptController.getDepartmentId(engName);
            return _deptController.getArabicDepartmentNameFromDepartmentId(
                  departmentId: id,
                ) ??
                engName;
          }
          return engName;
        }).toList(),
        textButton: deptDisplayText,
        hintText: S.of(context).department,
        fillColor: AppColors.background,
        onChanged: (item) {
          String engName = item;
          if (isArabic) {
            engName = _deptController.getDepartmentEnglishNameFromArabicName(
                  arabicName: item,
                ) ??
                item;
          }
          setState(() {
            if (selectedDepartments.contains(engName)) {
              selectedDepartments.remove(engName);
            } else {
              selectedDepartments.add(engName);
            }
          });
        },
      ),
    );

    // ✅ Date picker widget
    Widget dateField = _buildRequestDateField(
      selectedDate: selectedDate,
      onDatePicked: (val) => setState(() => selectedDate = val),
    );

    // ✅ Status multi-select widget
    Widget statusField = _labeled(
      S.of(context).status,
      CustomMultiSelectField(
        items: statusItems,
        selectedItems: selectedStatuses.map(context.svcStatus).toList(),
        textButton: statusDisplayText,
        hintText: S.of(context).status,
        fillColor: AppColors.background,
        onChanged: (item) {
          final engStatus = statuses.firstWhere(
            (s) => context.svcStatus(s) == item,
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
      ),
    );

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Container(
          width: isMobile ? double.infinity : 645.sp,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              _buildHeader(),
              SizedBox(height: 15.sp),

              // ── Fields ──
              if (isMobile) ...[
                // ✅ Mobile: all fields stacked vertically
                departmentField,
                SizedBox(height: 12.sp),
                statusField,
                SizedBox(height: 12.sp),
                dateField,
              ] else ...[
                // ✅ Tablet/Desktop: original row layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: departmentField),
                    SizedBox(width: 20.sp),
                    Expanded(child: dateField),
                  ],
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(child: statusField),
                    SizedBox(width: 20.sp),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],

              SizedBox(height: 15.sp),

              // ── Action Buttons ──
              _buildActionButtons(lightMode, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return CustomDialogHeader(
      title: S.of(context).Filter,
      icon: "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
    );
  }

  Widget _buildRequestDateField({
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDatePicked,
  }) {
    // Bug report p.29/p.30: the app's standard date field + picker, with its
    // title above the box like the other two fields.
    return CustomDateField(
      label: S.of(context).requestDate,
      hint: S.of(context).chooseTheDate,
      value: selectedDate,
      height: 38,
      fillColor: AppColors.background,
      onChanged: (DateTime? d) {
        if (d != null) onDatePicked(d);
      },
    );
  }

  /// Field title above the box — same size, weight and gap as the label
  /// CustomDateField draws, so all three fields line up.
  Widget _labeled(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        SizedBox(height: 6.sp),
        field,
      ],
    );
  }

  Widget _buildActionButtons(bool lightMode, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.of(context).Reset,
          function: () {
            setState(() {
              selectedDepartments = [];
              selectedStatuses = [];
              selectedDate = null;
            });
          },
          color: lightMode ? AppColors.grey : AppColors.mediumGrey,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.text,
          ),
          height: 38.sp,
          width: isMobile ? 120.w : 135.sp,
        ),
        customButton(
          title: S.of(context).Apply,
          function: () {
            Navigator.pop(context, {
              'departments': selectedDepartments,
              'statuses': selectedStatuses,
              'date': selectedDate,
            });
          },
          color: AppColors.primary,
          radius: 8.r,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          height: 38.sp,
          width: isMobile ? 120.w : 135.sp,
        ),
      ],
    );
  }
}
