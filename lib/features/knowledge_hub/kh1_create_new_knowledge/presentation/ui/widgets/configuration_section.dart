/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: configuration_section.dart
/// Description: Widget for document configuration section with owning department dropdown
/// Author: Amr Mesbah
/// Created at: 22/10/2025
/// Updated: Added dropdown for owning department selection with permission check
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';

import 'dart:math' as math;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/select_chip.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/doc_type_drop_menu.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets/date_time_picker.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ConfigurationSection extends StatelessWidget {
  final String dropDownMenuText;
  final String employeeDepartment;
  final bool limitDepartmentAvailability;
  final bool schedulePublishing;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final List<DepartmentModelPro> availableDepartments;
  final Map<String, bool> departmentSelections;
  final CreateKnowledgeModel? submittedDocument;
  final String? selectedOwningDepartmentId;
  final ValueChanged<String?> onDocTypeChanged;
  final ValueChanged<String?> onOwningDepartmentChanged;
  final ValueChanged<bool> onLimitDepartmentToggle;
  final ValueChanged<bool> onSchedulePublishingToggle;
  final ValueChanged<DateTime> onStartDateSelected;
  final ValueChanged<TimeOfDay> onStartTimeSelected;
  final ValueChanged<DateTime> onEndDateSelected;
  final ValueChanged<TimeOfDay> onEndTimeSelected;
  final ValueChanged<String> onDepartmentAdded;
  final ValueChanged<String> onDepartmentRemoved;

  const ConfigurationSection({
    super.key,
    required this.dropDownMenuText,
    required this.employeeDepartment,
    required this.limitDepartmentAvailability,
    required this.schedulePublishing,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.availableDepartments,
    required this.departmentSelections,
    required this.submittedDocument,
    required this.selectedOwningDepartmentId,
    required this.onDocTypeChanged,
    required this.onOwningDepartmentChanged,
    required this.onLimitDepartmentToggle,
    required this.onSchedulePublishingToggle,
    required this.onStartDateSelected,
    required this.onStartTimeSelected,
    required this.onEndDateSelected,
    required this.onEndTimeSelected,
    required this.onDepartmentAdded,
    required this.onDepartmentRemoved,
  });

  // Check if user has permission to select owning department
  bool _hasSelectOwningDepartmentPermission() =>
      KnowledgeHubAccess.canSelectOwningDepartment;

  /// [departmentId]'s name in the UI language, or [employeeDepartment].
  String _departmentName(BuildContext context, String departmentId) {
    final MainCoreDepartmentCubit? departments =
        context.read<CreateKnowledgeCubit>().people.departmentsOrNull;
    if (departments == null) return employeeDepartment;
    final String name = KhLocale.pick(
      context,
      en: departments.getEnglishDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ??
          '',
      ar: departments.getArabicDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ??
          '',
    );
    return name.isEmpty ? employeeDepartment : name;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildDocumentTypeDropdown(context),
            SizedBox(height: 15.h),
            _buildOwningDepartmentField(context, lightMode),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildDocumentTypeDropdown(context)),
                SizedBox(width: 15.w),
                Expanded(
                  child: _buildOwningDepartmentField(context, lightMode),
                ),
              ],
            ),
          ],
          SizedBox(height: 20.h),
          _buildLimitDepartmentSection(context, isMobile, lightMode),
          SizedBox(height: 25.h),
          _buildSchedulePublishingSection(context, isMobile, lightMode),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeDropdown(BuildContext context) {
    String currentDocType = submittedDocument != null
        ? submittedDocument!.currentKnowledgeDocumentType
        : dropDownMenuText;

    return docTypeDropMenu(
      context,
      dropDownMenuText: currentDocType,
      onChanged: onDocTypeChanged,
    );
  }

  // Build owning department field - dropdown if has permission, otherwise read-only
  Widget _buildOwningDepartmentField(BuildContext context, bool lightMode) {
    final hasPermission = _hasSelectOwningDepartmentPermission();

    if (hasPermission) {
      return _buildOwningDepartmentDropdown(context, lightMode);
    } else {
      return _buildOwningDepartmentReadOnly(context, lightMode);
    }
  }

  // Dropdown for owning department (when user has permission)
  Widget _buildOwningDepartmentDropdown(BuildContext context, bool lightMode) {
    // Department items for the dropdown: {"key": departmentId, "value": name
    // in the UI language}. capitalize() leaves Arabic text as it is.
    final List<Map<String, String>> departmentItems = availableDepartments.map((
      dept,
    ) {
      final String displayName = KhLocale.pick(
        context,
        en: dept.departmentName ?? '',
        ar: dept.departmentNameInArabic ?? '',
      );

      return {
        "key": dept.departmentID ?? '',
        "value": displayName.isEmpty
            ? S.of(context).unknown
            : FormatHelper.capitalize(displayName),
      };
    }).toList();

    // Find the current display value for the selected department
    String currentDisplayValue = selectedOwningDepartmentId ?? '';
    if (selectedOwningDepartmentId != null) {
      final selectedDept = departmentItems.firstWhere(
        (item) => item["key"] == selectedOwningDepartmentId,
        orElse: () => {
          "key": selectedOwningDepartmentId!,
          "value": employeeDepartment,
        },
      );
      currentDisplayValue = selectedDept["key"] ?? selectedOwningDepartmentId!;
    }

    // This used to be wrapped in `SizedBox(height: 36)`.
    // With `label` set, CustomDropdown returns a Column of
    // [label, 6sp gap, trigger] — about 63pt — so clamping the whole widget
    // to 36 produced the "BOTTOM OVERFLOWED BY 27 PIXELS" stripe under
    // "Owning Department". `height` sizes the trigger alone, which is what
    // was actually wanted; the label then sizes itself and the Row above
    // keeps both columns aligned.
    //
    // `key: ValueKey(selectedOwningDepartmentId)` removed —
    // same reason as the Document Type dropdown. A key derived from the
    // selected value recreates the dropdown's State on every pick, disposing it
    // while its close animation is still running. See `_removeOverlayEntry` in
    // 1-custom_dropdown.dart.
    return CustomDropdown<String>(
      value: currentDisplayValue,
      items: departmentItems
          .map(
            (e) => DropdownItem<String>(
              value: e['key'] ?? '',
              label: e['value'] ?? '',
            ),
          )
          .toList(),
      onChanged: (v) => onOwningDepartmentChanged(v),
      label: S.of(context).owning_department,
      hint: S.of(context).owning_department,
      height: 36,
    );
  }

  // Read-only field for owning department (when user does NOT have permission)
  Widget _buildOwningDepartmentReadOnly(BuildContext context, bool lightMode) {
    final String displayName = selectedOwningDepartmentId == null
        ? employeeDepartment
        : _departmentName(context, selectedOwningDepartmentId!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).owning_department,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: ScreenUtil().screenWidth,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.background,
          ),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 8.sp,
            vertical: 3.sp,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              // capitalize() leaves Arabic text as it is.
              FormatHelper.capitalize(displayName),
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitDepartmentSection(
    BuildContext context,
    bool isMobile,
    bool lightMode,
  ) {
    return Column(
      children: [
        isMobile
            ? Row(
                children: [
                  Text(
                    S.of(context).limit_department_availability,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.blackButton,
                    ),
                  ),
                  const Spacer(),
                  CustomRtlSwitch(
                    value: limitDepartmentAvailability,
                    onToggle: onLimitDepartmentToggle,
                    activeColor: AppColors.secondaryPrimary,
                    inactiveColor: AppColors.grey,
                    // KH vertical report p.4: not mirrored in Arabic.
                    isRtl: false,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          S.of(context).limit_department_availability,
                          style: StyleText.fontSize14Weight400.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        const Spacer(),
                        CustomRtlSwitch(
                          value: limitDepartmentAvailability,
                          onToggle: onLimitDepartmentToggle,
                          activeColor: AppColors.secondaryPrimary,
                          inactiveColor: AppColors.grey,
                          // KH vertical report p.4: not mirrored in Arabic.
                          isRtl: false,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(width: 15.sp),
                ],
              ),
        if (limitDepartmentAvailability) ...[
          SizedBox(height: 15.h),
          isMobile
              ? _buildDepartmentSelector(context, isMobile, lightMode)
              : Row(
                  children: [
                    Expanded(
                      child: _buildDepartmentSelector(
                        context,
                        isMobile,
                        lightMode,
                      ),
                    ),
                    Expanded(child: Container()),
                    SizedBox(width: 15.sp),
                  ],
                ),
        ],
      ],
    );
  }

  Widget _buildDepartmentSelector(
    BuildContext context,
    bool isMobile,
    bool lightMode,
  ) {
    // Departments are saved by their English name and shown in the UI
    // language (KhLocale.pick — no hand-written language switch).
    final Map<String, String> englishToShown = {};
    final Map<String, String> shownToEnglish = {};
    final List<String> departmentNames = [];

    for (final dept in availableDepartments) {
      final String englishName = dept.departmentName ?? '';
      final String shownName = KhLocale.pick(
        context,
        en: englishName,
        ar: dept.departmentNameInArabic ?? '',
      );
      departmentNames.add(shownName);
      if (englishName.isNotEmpty) {
        englishToShown[englishName] = shownName;
        shownToEnglish[shownName] = englishName;
      }
    }

    final List<String> selectedDepartmentNames = departmentSelections.entries
        .where((entry) => entry.value)
        .map((entry) => englishToShown[entry.key] ?? entry.key)
        .toList();

    return SelectChip(
      title: S.of(context).department,
      departments: departmentNames,
      selectedDepartments: selectedDepartmentNames,
      width: MediaQuery.of(context).size.width - 10.w,
      menuWidth: isMobile ? 310.w : ScreenUtil().screenWidth * 0.429,
      color: AppColors.background,
      singleSelect: false,
      apper: true,
      menuItemHeight: 30.h,
      capitalizeDepartments: true,
      onAdd: (displayName) =>
          onDepartmentAdded(shownToEnglish[displayName] ?? displayName),
      onRemove: (displayName) =>
          onDepartmentRemoved(shownToEnglish[displayName] ?? displayName),
    );
  }

  Widget _buildSchedulePublishingSection(
    BuildContext context,
    bool isMobile,
    bool lightMode,
  ) {
    // On wider screens each part takes the first of two columns.
    Widget halfWidth(Widget child) => isMobile
        ? child
        : Row(
            children: [
              Expanded(child: child),
              const Expanded(child: SizedBox()),
              SizedBox(width: 15.sp),
            ],
          );
    return Column(
      children: [
        halfWidth(_buildScheduleToggle(context)),
        if (schedulePublishing)
          halfWidth(_buildScheduleDates(context, lightMode)),
      ],
    );
  }

  /// "Schedule Publishing" label and switch.
  Widget _buildScheduleToggle(BuildContext context) {
    return Row(
      children: [
        Text(
          S.of(context).schedule_publishing,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        const Spacer(),
        CustomRtlSwitch(
          value: schedulePublishing,
          onToggle: onSchedulePublishingToggle,
          activeColor: AppColors.secondaryPrimary,
          inactiveColor: AppColors.grey,
          // KH vertical report p.4: not mirrored in Arabic.
          isRtl: false,
        ),
      ],
    );
  }

  /// Start and end date / time pickers.
  Widget _buildScheduleDates(BuildContext context, bool lightMode) {
    return Column(
      children: [
        SizedBox(height: 13.h),
        DateTimePicker(
          label: S.of(context).start_date,
          date: startDate,
          time: startTime,
          onDateSelected: onStartDateSelected,
          onTimeSelected: onStartTimeSelected,
          lightMode: lightMode,
          isEndDate: false,
        ),
        SizedBox(height: 15.h),
        DateTimePicker(
          label: S.of(context).end_date,
          date: endDate,
          time: endTime,
          onDateSelected: onEndDateSelected,
          onTimeSelected: onEndTimeSelected,
          lightMode: lightMode,
          isEndDate: true,
          minDate: startDate,
          startDate: startDate,
          startTime: startTime,
        ),
      ],
    );
  }
}

// ✅ Custom RTL Switch Widget with 180-degree rotation support
class CustomRtlSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onToggle;
  final Color activeColor;
  final Color inactiveColor;
  final Color? toggleColor;
  final bool isRtl;
  final double? height;
  final double? width;
  final double? padding;
  final double? borderRadius;
  final double? toggleSize;

  const CustomRtlSwitch({
    super.key,
    required this.value,
    required this.onToggle,
    required this.activeColor,
    required this.inactiveColor,
    this.toggleColor,
    this.isRtl = false,
    this.height,
    this.width,
    this.padding,
    this.borderRadius,
    this.toggleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(isRtl ? math.pi : 0),
      child: FlutterSwitch(
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        toggleColor: toggleColor ?? AppColors.colorWhite,
        height: height ?? 22.sp,
        width: width ?? 38.sp,
        padding: padding ?? 3.sp,
        borderRadius: borderRadius ?? 20.sp,
        toggleSize: toggleSize ?? 16.sp,
        value: value,
        onToggle: onToggle,
      ),
    );
  }
}
