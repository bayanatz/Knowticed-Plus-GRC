// ****************** FILE INFO ******************
// File Name: crm_templates_filter_dialog.dart
// Purpose: Filter modal dialog for CRM Controls Templates matching design specs with full localization
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class CrmTemplatesFilterDialog extends StatefulWidget {
  final String? initialStatus;
  final DateTime? initialCreationDate;
  final String? initialFieldsCountRange;
  final String? initialCreatedBy;
  final List<String> availableCreators;
  final void Function({
    String? status,
    DateTime? creationDate,
    String? fieldsCountRange,
    String? createdBy,
  }) onApply;

  const CrmTemplatesFilterDialog({
    super.key,
    this.initialStatus,
    this.initialCreationDate,
    this.initialFieldsCountRange,
    this.initialCreatedBy,
    this.availableCreators = const <String>['All'],
    required this.onApply,
  });

  /// Function Name: show
  ///
  /// Purpose: Shows the filter dialog for CRM templates listing
  ///
  /// Parameters:
  /// - context: The BuildContext
  /// - initialStatus: Current active status filter
  /// - initialCreationDate: Current active creation date filter
  /// - initialFieldsCountRange: Current active fields count range filter
  /// - initialCreatedBy: Current active createdBy filter
  /// - availableCreators: List of available template creator names
  /// - onApply: Callback triggered when apply is tapped
  static Future<void> show(
    BuildContext context, {
    String? initialStatus,
    DateTime? initialCreationDate,
    String? initialFieldsCountRange,
    String? initialCreatedBy,
    List<String> availableCreators = const <String>['All'],
    required void Function({
      String? status,
      DateTime? creationDate,
      String? fieldsCountRange,
      String? createdBy,
    }) onApply,
  }) {
    return showAppDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 24.sp),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 620.sp),
          child: CrmTemplatesFilterDialog(
            initialStatus: initialStatus,
            initialCreationDate: initialCreationDate,
            initialFieldsCountRange: initialFieldsCountRange,
            initialCreatedBy: initialCreatedBy,
            availableCreators: availableCreators,
            onApply: onApply,
          ),
        ),
      ),
    );
  }

  @override
  State<CrmTemplatesFilterDialog> createState() =>
      _CrmTemplatesFilterDialogState();
}

class _CrmTemplatesFilterDialogState extends State<CrmTemplatesFilterDialog> {
  String? _status;
  DateTime? _creationDate;
  String? _fieldsCountRange;
  String? _createdBy;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _creationDate = widget.initialCreationDate;
    _fieldsCountRange = widget.initialFieldsCountRange;
    _createdBy = widget.initialCreatedBy;
  }

  /// Function Name: _reset
  ///
  /// Purpose: Resets all filter fields
  void _reset() {
    setState(() {
      _status = null;
      _creationDate = null;
      _fieldsCountRange = null;
      _createdBy = null;
    });
  }

  /// Function Name: _apply
  ///
  /// Purpose: Submits selected filter criteria and closes dialog
  void _apply() {
    widget.onApply(
      status: _status,
      creationDate: _creationDate,
      fieldsCountRange: _fieldsCountRange,
      createdBy: _createdBy,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = kpIsPhoneLayout(context);

    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header: Yellow circle with Filter SVG + Filter title
            // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 36./36./18. row.
            CustomDialogHeader(
                title: S.current.crmFilter, icon: AppAssets.filter),
            SizedBox(height: 24.sp),

            // Form Rows
            if (isMobile) ...<Widget>[
              _buildStatusDropdown(),
              SizedBox(height: 12.sp),
              _buildCreationDatePicker(),
              SizedBox(height: 12.sp),
              _buildFieldsCountDropdown(),
              SizedBox(height: 12.sp),
              _buildCreationByDropdown(),
            ] else ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _buildStatusDropdown()),
                  SizedBox(width: 16.sp),
                  Expanded(child: _buildCreationDatePicker()),
                ],
              ),
              SizedBox(height: 16.sp),
              Row(
                children: <Widget>[
                  Expanded(child: _buildFieldsCountDropdown()),
                  SizedBox(width: 16.sp),
                  Expanded(child: _buildCreationByDropdown()),
                ],
              ),
            ],
            SizedBox(height: 32.sp),

            // Bottom Actions: Reset (left) & Apply (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                customButton(
                  title: S.current.reset,
                  color: AppColors.lightGrey,
                  textColor: AppColors.text,
                  function: _reset,
                ),
                customButton(
                  title: S.current.apply,
                  color: AppColors.primary,
                  textColor: AppColors.text,
                  function: _apply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Function Name: _buildStatusDropdown
  ///
  /// Purpose: Builds the Status dropdown selector with localization
  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      hint: S.current.crmStatus,
      value: _status,
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: 'All', label: S.current.crmAll),
        DropdownItem<String>(
            value: 'Active', label: S.current.crmTemplateActive),
        DropdownItem<String>(
            value: 'Inactive', label: S.current.crmTemplateInactive),
        DropdownItem<String>(
            value: 'Deleted', label: S.current.crmTemplateDeleted),
      ],
      fillColor: AppColors.background,
      onChanged: (String? val) => setState(() => _status = val),
    );
  }

  /// Function Name: _buildCreationDatePicker
  ///
  /// Purpose: Builds the Creation Date calendar date picker with localization
  Widget _buildCreationDatePicker() {
    return CustomDateField(
      hint: S.current.crmCreationDateLabel,
      value: _creationDate,
      fillColor: AppColors.background,
      onChanged: (DateTime? date) => setState(() => _creationDate = date),
    );
  }

  /// Function Name: _buildFieldsCountDropdown
  ///
  /// Purpose: Builds the Number of Fields dropdown selector with localization
  Widget _buildFieldsCountDropdown() {
    return CustomDropdown<String>(
      hint: S.current.crmNumberOfFields,
      value: _fieldsCountRange,
      items: <DropdownItem<String>>[
        DropdownItem<String>(value: 'All', label: S.current.crmAll),
        const DropdownItem<String>(value: '1 - 5', label: '1 - 5'),
        const DropdownItem<String>(value: '6 - 10', label: '6 - 10'),
        const DropdownItem<String>(value: '11 - 20', label: '11 - 20'),
        const DropdownItem<String>(value: '20+', label: '20+'),
      ],
      fillColor: AppColors.background,
      onChanged: (String? val) => setState(() => _fieldsCountRange = val),
    );
  }

  /// Function Name: _buildCreationByDropdown
  ///
  /// Purpose: Builds the Creation By dropdown selector with localization
  Widget _buildCreationByDropdown() {
    final List<String> creators = widget.availableCreators.isNotEmpty
        ? widget.availableCreators
        : const <String>['All'];

    return CustomDropdown<String>(
      hint: S.current.crmCreationBy,
      value: _createdBy,
      items: creators
          .map(
            (c) => DropdownItem<String>(
              value: c,
              label: c == 'All' ? S.current.crmAll : c,
            ),
          )
          .toList(),
      fillColor: AppColors.background,
      onChanged: (String? val) => setState(() => _createdBy = val),
    );
  }
}
