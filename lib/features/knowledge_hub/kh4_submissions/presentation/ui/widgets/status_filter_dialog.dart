/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: status_filter_dialog.dart
/// Description: Status filter dialog — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/kh_filter_fields.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class StatusFilterDialog extends StatefulWidget {
  const StatusFilterDialog({super.key});

  @override
  State<StatusFilterDialog> createState() => _StatusFilterDialogState();
}

class _StatusFilterDialogState extends State<StatusFilterDialog> {
  String? _selectedStatus;
  String? _selectedDocType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadInitialFilterValues();
  }

  void _loadInitialFilterValues() {
    final cubit = context.read<SubmissionsCubit>();
    _selectedStatus = cubit.selectedStatus;
    _selectedDocType = cubit.selectedDocumentType;
    _startDate = cubit.selectedStartDate;
    _endDate = cubit.selectedEndDate;
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

  // Build localized status items
  List<Map<String, String>> _getStatusMenuItems(BuildContext context) {
    return [
      {'key': 'Published', 'value': S.of(context).published},
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
    });
  }

  void _applyFilters() {
    final cubit = context.read<SubmissionsCubit>();

    // Only pass values if they're actually selected
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

    //  * Phones: the dialog ran edge to edge. It now keeps 20.sp on each side.
    //  * Every field (both dropdowns, both date boxes) is AppColors.background.
    //    The dialog itself was ALSO AppColors.background in dark mode, so the
    //    fields vanished into it; the dialog is now AppColors.card so the
    //    fields read as fields.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.sp : 0),
      child: Material(
        color: AppColors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 655.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.card,
          ),
          padding: EdgeInsets.all(isMobile ? 15.w : 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, lightMode),
              SizedBox(height: 15.sp),
              _buildDropdowns(isMobile, lightMode, context),
              SizedBox(height: 15.sp),
              _buildDateRangeSelectors(lightMode, context),
              SizedBox(height: 15.sp),
              _buildActionButtons(isMobile, lightMode, context),
            ],
          ),
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
    // Get localized items
    final statusItems = _getStatusMenuItems(context);
    final docTypeItems = _getDocumentTypeItems(context);

    // The shared KH filter fields (kh_filter_fields.dart).
    final statusDropdown = SizedBox(
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

    return isMobile
        ? Column(
            children: [
              statusDropdown,
              SizedBox(height: 15.h),
              docTypeDropdown,
            ],
          )
        : Row(
            children: [
              Expanded(child: statusDropdown),
              SizedBox(width: 15.w),
              Expanded(child: docTypeDropdown),
            ],
          );
  }

  Widget _buildDateRangeSelectors(bool lightMode, BuildContext context) {
    return ContextExtension(context).isPhone
        ? Column(
            children: [
              _buildDateSelector(true, lightMode, context),
              SizedBox(height: 15.w),
              _buildDateSelector(false, lightMode, context),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildDateSelector(true, lightMode, context)),
              SizedBox(width: 15.w),
              Expanded(child: _buildDateSelector(false, lightMode, context)),
            ],
          );
  }

  Widget _buildDateSelector(
    bool isStartDate,
    bool lightMode,
    BuildContext context,
  ) {
    final selectedDate = isStartDate ? _startDate : _endDate;
    final hintText =
        // 14/10/2026 — KH report p.1: "Start Date" / "End Date", not
        // "Publish Date:" / "Archive Date".
        isStartDate ? S.of(context).start_date : S.of(context).end_date;

    // Built to the same three rules as the dropdowns above it — see
    // [_kFieldPadding]: no fixed height, 12.sp vertical padding, and the
    // dropdown's own fill colour rather than a hand-picked match for it.
    // The shared KH filter date field.
    return KhFilterDateField(
      value: selectedDate,
      hint: hintText,
      onPicked: (d) => setState(() {
        if (isStartDate) {
          _startDate = d;
        } else {
          _endDate = d;
        }
      }),
    );
  }

  Widget _buildActionButtons(
    bool isMobile,
    bool lightMode,
    BuildContext context,
  ) {
    final reset = customButton(
      height: 38.h,
      width: isMobile ? null : 150.w,
      fullWidth: isMobile,
      title: S.of(context).reset,
      function: () {
        _resetFilters();
        context.read<SubmissionsCubit>().resetFilters();
        Navigator.of(context).pop();
      },
      color: AppColors.secondaryAction, // branding (KH mobile p.6/7/10)
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.onSecondaryAction,
      ),
    );
    final apply = customButton(
      height: 38.h,
      width: isMobile ? null : 150.w,
      fullWidth: isMobile,
      title: S.of(context).apply,
      function: _applyFilters,
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
    );

    // Phones: the dialog is narrower now (20.sp side margins), so the two
    // buttons split the width instead of using fixed widths that could overflow.
    if (isMobile) {
      return Row(
        children: [
          Expanded(child: reset),
          SizedBox(width: 15.sp),
          Expanded(child: apply),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        reset,
        SizedBox(width: 45.w),
        apply,
      ],
    );
  }
}
