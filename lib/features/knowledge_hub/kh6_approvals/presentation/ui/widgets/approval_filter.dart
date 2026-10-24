/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: approval_filter.dart
/// Description: Approval filter — Approvals (S6) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/kh_filter_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class ApprovalsFilterDialog extends StatefulWidget {
  const ApprovalsFilterDialog({super.key});

  @override
  State<ApprovalsFilterDialog> createState() => _ApprovalsFilterDialogState();
}

class _ApprovalsFilterDialogState extends State<ApprovalsFilterDialog> {
  String? _selectedStatus;
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

  String? _selectedDeptId;

  @override
  void initState() {
    super.initState();
    _loadInitialFilterValues();
  }

  void _loadInitialFilterValues() {
    final cubit = context.read<ApprovalsCubit>();
    _selectedStatus = cubit.selectedStatus;
    _selectedDocType = cubit.selectedDocumentType;
    _startDate = cubit.selectedStartDate;
    _endDate = cubit.selectedEndDate;
    _selectedDeptId = cubit.selectedDepartmentId;
  }

  List<Map<String, String>> _getDepartmentItems(BuildContext context) {
    final MainCoreDepartmentCubit dept = context
        .read<ApprovalsCubit>()
        .people
        .departments;
    final items = <Map<String, String>>[
      {'key': 'all', 'value': S.of(context).all_departments},
    ];
    for (int i = 0; i < dept.departmentIds.length; i++) {
      items.add({
        'key': dept.departmentIds[i],
        'value': KhLocale.pick(
          context,
          en: dept.departmentsEnglishName[i],
          ar: dept.departmentsArabicName[i],
        ),
      });
    }
    return items;
  }

  // Match the exact document types from creation
  List<Map<String, String>> _getDocumentTypeItems(BuildContext context) {
    return [
      {'key': 'Presentation', 'value': S.of(context).presentation},
      {'key': 'Form', 'value': S.of(context).form},
      {'key': 'Report', 'value': S.of(context).report},
      {'key': 'Letter', 'value': S.of(context).letter},
      {'key': 'Video', 'value': S.of(context).video},
      {'key': 'Recording', 'value': S.of(context).recording},
      {'key': 'Booklet', 'value': S.of(context).booklet},
      {'key': 'WorkShop', 'value': S.of(context).workshop},
      {'key': 'Frame Work', 'value': S.of(context).framework},
      {'key': 'Policy', 'value': S.of(context).policy},
      {'key': 'Mandate', 'value': S.of(context).mandate},
      {'key': 'Guidelines', 'value': S.of(context).guidelines},
      {'key': 'Other', 'value': S.of(context).other},
    ];
  }

  // ✅ Build localized status items
  List<Map<String, String>> _getStatusMenuItems(BuildContext context) {
    return [
      {'key': 'Approved', 'value': S.of(context).approved},
      {'key': 'Pending', 'value': S.of(context).pending},
      {'key': 'Rejected', 'value': S.of(context).rejected},
      {'key': 'Removed', 'value': S.of(context).removed},
      {'key': 'Archive', 'value': S.of(context).archive},
    ];
  }

  void _updateStatus(String? newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
  }

  void _updateDocumentType(String? newDocType) {
    setState(() {
      _selectedDocType = newDocType;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDocType = null;
      _startDate = null;
      _endDate = null;
      _selectedDeptId = null;
    });
  }

  void _applyFilters() {
    final cubit = context.read<ApprovalsCubit>();

    if (ContextExtension(context).isPhone) {
      cubit.selectedDepartmentId =
          (_selectedDeptId == null || _selectedDeptId == 'all')
          ? null
          : _selectedDeptId;
    }

    // ✅ Only pass values if they're actually selected
    cubit.applyFilters(
      documentType: _selectedDocType,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? 350.w : 411.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        padding: EdgeInsets.all(isMobile ? 15.w : 15.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, lightMode),
            SizedBox(height: 15.sp),
            _buildDropdowns(isMobile, lightMode, context),
            SizedBox(height: 15.sp),
            _buildActionButtons(isMobile, lightMode, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool lightMode) {
    // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 15./16./16. row.
    return CustomDialogHeader(
      title: S.of(context).filter,
      icon: 'assets/icons_assets/main_icons_assets/ic_action_filter.svg',
    );
  }

  Widget _buildDropdowns(bool isMobile, bool lightMode, BuildContext context) {
    // ✅ Get localized items
    final statusItems = _getStatusMenuItems(context);
    final docTypeItems = _getDocumentTypeItems(context);

    SizedBox(
      width: isMobile ? double.infinity : null,
      child: KhFilterDropdown(
        value: _selectedStatus,
        items: statusItems,
        onChanged: _updateStatus,
        hint: S.of(context).status,
      ),
    );

    final docTypeDropdown = SizedBox(
      width: isMobile ? double.infinity : null,
      child: KhFilterDropdown(
        value: _selectedDocType,
        items: docTypeItems,
        onChanged: _updateDocumentType,
        hint: S.of(context).document_type,
        maxOverlayHeight: 216.0,
      ),
    );

    final departmentDropdown = SizedBox(
      width: double.infinity,
      child: KhFilterDropdown(
        value: _selectedDeptId,
        items: _getDepartmentItems(context),
        onChanged: (v) => setState(() => _selectedDeptId = v),
        hint: S.of(context).department,
      ),
    );

    return isMobile
        ? Column(
            children: [
              departmentDropdown,
              SizedBox(height: 15.h),
              docTypeDropdown,
            ],
          )
        : Row(children: [Expanded(child: docTypeDropdown)]);
  }

  Widget _buildActionButtons(
    bool isMobile,
    bool lightMode,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).reset,
          function: () {
            _resetFilters();
            context.read<ApprovalsCubit>().resetFilters();
            Navigator.of(context).pop();
          },
          color: AppColors.secondaryAction,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction,
          ),
        ),
        SizedBox(width: 45.w),
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).apply,
          function: _applyFilters,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ],
    );
  }
}
