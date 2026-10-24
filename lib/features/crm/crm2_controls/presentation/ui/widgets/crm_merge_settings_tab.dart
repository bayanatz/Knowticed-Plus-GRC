// ****************** FILE INFO ******************
// File Name: crm_merge_settings_tab.dart
// Purpose: Settings tab content for CRM Merge Controls (view & edit modes)
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_matching_rule_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmMergeSettingsTab extends StatefulWidget {
  final CrmMergeSettingsModel settings;
  final bool isEditing;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;

  const CrmMergeSettingsTab({
    super.key,
    required this.settings,
    required this.isEditing,
    required this.onStartEdit,
    required this.onCancelEdit,
  });

  @override
  State<CrmMergeSettingsTab> createState() => _CrmMergeSettingsTabState();
}

class _CrmMergeSettingsTabState extends State<CrmMergeSettingsTab> {
  late final TextEditingController _durationController;
  late final TextEditingController _idWeightController;
  late final TextEditingController _fullNameWeightController;
  late final TextEditingController _emailWeightController;
  late final TextEditingController _phoneWeightController;

  late bool _undoEnabled;
  late MergeDurationUnit _durationUnit;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController();
    _idWeightController = TextEditingController();
    _fullNameWeightController = TextEditingController();
    _emailWeightController = TextEditingController();
    _phoneWeightController = TextEditingController();
    _resetForm();
  }

  @override
  void didUpdateWidget(covariant CrmMergeSettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings ||
        oldWidget.isEditing != widget.isEditing) {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _idWeightController.dispose();
    _fullNameWeightController.dispose();
    _emailWeightController.dispose();
    _phoneWeightController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _undoEnabled = widget.settings.undoEnabled;
    _durationUnit = widget.settings.durationUnit;
    _durationController.text = widget.settings.durationValue > 0
        ? widget.settings.durationValue.toString()
        : '';
    _idWeightController.text = _findWeight(widget.settings, 'id') ?? '';
    _fullNameWeightController.text =
        _findWeight(widget.settings, 'full_name') ?? '';
    _emailWeightController.text = _findWeight(widget.settings, 'email') ?? '';
    _phoneWeightController.text = _findWeight(widget.settings, 'phone') ?? '';
  }

  String? _findWeight(CrmMergeSettingsModel settings, String key) {
    for (final CrmMergeMatchingRuleModel rule in settings.matchingRules) {
      if (rule.systemKey == key || rule.fieldId == key) {
        return rule.weight > 0 ? rule.weight.toString() : null;
      }
    }
    return null;
  }

  String _unitLabel(MergeDurationUnit unit) => switch (unit) {
        MergeDurationUnit.minutes => S.current.crmMergeMinutes,
        MergeDurationUnit.hours => S.current.crmMergeHours,
        MergeDurationUnit.days => S.current.crmMergeDays,
        MergeDurationUnit.weeks => S.current.crmMergeWeeks,
        MergeDurationUnit.months => S.current.crmMergeMonths,
        MergeDurationUnit.years => S.current.crmMergeYears,
      };

  Future<void> _handleSave() async {
    final int? duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration < 1) return;

    final List<CrmMergeMatchingRuleModel> rules = <CrmMergeMatchingRuleModel>[
      CrmMergeMatchingRuleModel(
        fieldId: 'id',
        templateId: 'default',
        systemKey: 'id',
        weight: int.tryParse(_idWeightController.text.trim()) ?? 0,
        isIdentity: true,
      ),
      CrmMergeMatchingRuleModel(
        fieldId: 'full_name',
        templateId: 'default',
        systemKey: 'full_name',
        weight: int.tryParse(_fullNameWeightController.text.trim()) ?? 0,
      ),
      CrmMergeMatchingRuleModel(
        fieldId: 'email',
        templateId: 'default',
        systemKey: 'email',
        weight: int.tryParse(_emailWeightController.text.trim()) ?? 0,
      ),
      CrmMergeMatchingRuleModel(
        fieldId: 'phone',
        templateId: 'default',
        systemKey: 'phone',
        weight: int.tryParse(_phoneWeightController.text.trim()) ?? 0,
      ),
    ];

    showLoadingIndicator();
    final bool saved = await context.read<CrmMergeLevelsCubit>().saveSettings(
          undoEnabled: _undoEnabled,
          durationValue: duration,
          durationUnit: _durationUnit,
          matchingRules: rules,
        );
    hideLoadingIndicator();
    if (mounted && saved) widget.onCancelEdit();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditMode();
    }
    return _buildViewMode();
  }

  // ----------------------------------------------------
  // VIEW MODE (Screenshot 1)
  // ----------------------------------------------------
  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Yellow Edit Icon Button (Top Right)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: customButtonWithSvg(
            title: '',
            function: widget.onStartEdit,
            textStyle: StyleText.fontSize14Weight600
                .copyWith(color: AppColors.blackButton),
            color: AppColors.primary,
            colorBorder: AppColors.transparent,
            image: AppAssets.edit,
            width: 38.sp,
            height: 38.sp,
            widthImage: 18.sp,
            heightImage: 18.sp,
            svgColor: AppColors.black,
          ),
        ),
        SizedBox(height: 10.sp),

        // Section 1: General Setting
        CrmSectionCard(
          title: S.current.crmGeneralSetting,
          showHideToggle: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    S.current.crmMergeUndoMode,
                    style: StyleText.fontSize14Weight500,
                  ),
                  DefaultSwitchButton(
                    value: widget.settings.undoEnabled,
                    onChanged: (_) {},
                  ),
                ],
              ),
              SizedBox(height: 14.sp),
              Text(
                S.current.crmMergeDuration,
                style: StyleText.fontSize14Weight500,
              ),
              SizedBox(height: 8.sp),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomTextField(
                      key: ValueKey<String>(
                        'merge-duration-${widget.settings.durationValue}',
                      ),
                      hint: 'Text Here',
                      initialValue: widget.settings.durationValue > 0
                          ? widget.settings.durationValue.toString()
                          : '',
                      readOnly: true,
                      fillColor: AppColors.background,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: CustomDropdown<MergeDurationUnit>(
                      value: widget.settings.durationUnit,
                      enabled: false,
                      hint: S.current.crmMergeUnit,
                      fillColor: AppColors.background,
                      items: MergeDurationUnit.values
                          .map((MergeDurationUnit unit) =>
                              DropdownItem<MergeDurationUnit>(
                                value: unit,
                                label: _unitLabel(unit),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.sp),

        // Section 2: Criteria & Weights Setting
        CrmSectionCard(
          title: S.current.crmMergeCriteriaAndWeights,
          showHideToggle: false,
          child: Column(
            children: <Widget>[
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaId,
                weightController: _idWeightController,
                isReadOnly: true,
                initialWeight: _findWeight(widget.settings, 'id'),
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaFullName,
                weightController: _fullNameWeightController,
                isReadOnly: true,
                initialWeight: _findWeight(widget.settings, 'full_name'),
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaEmail,
                weightController: _emailWeightController,
                isReadOnly: true,
                initialWeight: _findWeight(widget.settings, 'email'),
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaPhone,
                weightController: _phoneWeightController,
                isReadOnly: true,
                initialWeight: _findWeight(widget.settings, 'phone'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // EDIT MODE (Screenshot 2)
  // ----------------------------------------------------
  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Section 1: General Setting
        CrmSectionCard(
          title: S.current.crmGeneralSetting,
          showHideToggle: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    S.current.crmMergeUndoMode,
                    style: StyleText.fontSize14Weight500,
                  ),
                  DefaultSwitchButton(
                    value: _undoEnabled,
                    onChanged: (bool value) =>
                        setState(() => _undoEnabled = value),
                  ),
                ],
              ),
              SizedBox(height: 14.sp),
              Text(
                S.current.crmMergeDuration,
                style: StyleText.fontSize14Weight500,
              ),
              SizedBox(height: 8.sp),
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomTextField(
                      hint: 'Text Here',
                      controller: _durationController,
                      fillColor: AppColors.background,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: CustomDropdown<MergeDurationUnit>(
                      value: _durationUnit,
                      hint: S.current.crmMergeUnit,
                      fillColor: AppColors.background,
                      items: MergeDurationUnit.values
                          .map((MergeDurationUnit unit) =>
                              DropdownItem<MergeDurationUnit>(
                                value: unit,
                                label: _unitLabel(unit),
                              ))
                          .toList(),
                      onChanged: (MergeDurationUnit unit) =>
                          setState(() => _durationUnit = unit),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.sp),

        // Section 2: Criteria & Weights Setting
        CrmSectionCard(
          title: S.current.crmMergeCriteriaAndWeights,
          showHideToggle: false,
          child: Column(
            children: <Widget>[
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaId,
                weightController: _idWeightController,
                isReadOnly: false,
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaFullName,
                weightController: _fullNameWeightController,
                isReadOnly: false,
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaEmail,
                weightController: _emailWeightController,
                isReadOnly: false,
              ),
              SizedBox(height: 14.sp),
              _buildCriteriaRow(
                criteriaName: S.current.crmMergeCriteriaPhone,
                weightController: _phoneWeightController,
                isReadOnly: false,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.sp),

        // Bottom Action Buttons (Discard / Save)
        Row(
          textDirection: TextDirection
              .ltr, // X-73: Cancel left, action right in both languages

          children: <Widget>[
            Expanded(
              child: customButton(
                title: S.current.crmDiscard,
                function: widget.onCancelEdit,
                color: AppColors.grey,
                textColor: AppColors.black,
              ),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: customButton(
                title: S.current.crmSave,
                function: _handleSave,
                color: AppColors.primary,
                textColor: AppColors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCriteriaRow({
    required String criteriaName,
    required TextEditingController weightController,
    required bool isReadOnly,
    String? initialWeight,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.current.crmMergeCriteria,
                style: StyleText.fontSize14Weight500,
              ),
              SizedBox(height: 8.sp),
              CustomTextField(
                hint: criteriaName,
                initialValue: criteriaName,
                readOnly: true,
                fillColor: AppColors.background,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.current.crmMergeWeight,
                style: StyleText.fontSize14Weight500,
              ),
              SizedBox(height: 8.sp),
              if (isReadOnly)
                CustomTextField(
                  hint: 'Text Here',
                  initialValue:
                      initialWeight?.isNotEmpty == true ? initialWeight : null,
                  readOnly: true,
                  fillColor: AppColors.background,
                )
              else
                CustomTextField(
                  hint: 'Text Here',
                  controller: weightController,
                  fillColor: AppColors.background,
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
