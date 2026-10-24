// ****************** FILE INFO ******************
// File Name: crm_add_deal_step3_progress.dart
// Purpose: Step 3 (Progress Per Stage) with Settings Edit Mode toggle, 5-column checklist grid, and requirement dropdowns matching Figma design.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_stage_checklist_item_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class _StageConfig {
  final String stageId;
  final String titleEn;
  final String titleAr;
  final List<String> defaultDisplayItems;
  final List<String> dropdownOptions;
  final List<String?> selectedRequirements;

  _StageConfig({
    required this.stageId,
    required this.titleEn,
    required this.titleAr,
    required this.defaultDisplayItems,
    required this.dropdownOptions,
    List<String?>? selectedRequirements,
  }) : selectedRequirements = selectedRequirements ?? <String?>[null];
}

class CrmAddDealStep3Progress extends StatefulWidget {
  final List<CrmDealStageModel>? stages;
  final bool initialEditMode;
  final ValueChanged<bool>? onEditModeChanged;

  const CrmAddDealStep3Progress({
    super.key,
    this.stages,
    this.initialEditMode = false,
    this.onEditModeChanged,
  });

  @override
  State<CrmAddDealStep3Progress> createState() =>
      _CrmAddDealStep3ProgressState();
}

class _CrmAddDealStep3ProgressState extends State<CrmAddDealStep3Progress> {
  bool _editMode = false;
  List<_StageConfig> _configs = <_StageConfig>[];

  @override
  void initState() {
    super.initState();
    _editMode = widget.initialEditMode;
    _populateConfigs();
  }

  @override
  void didUpdateWidget(covariant CrmAddDealStep3Progress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stages != oldWidget.stages) {
      _populateConfigs();
    }
  }

  void _populateConfigs() {
    final List<CrmDealStageModel> activeStages = (widget.stages ??
            <CrmDealStageModel>[])
        .where((CrmDealStageModel s) => s.isActive && !s.isDeleted)
        .toList()
      ..sort((CrmDealStageModel a, CrmDealStageModel b) =>
          a.order.compareTo(b.order));

    if (activeStages.isEmpty) {
      _configs = _defaultConfigs();
      return;
    }

    _configs = activeStages.map((CrmDealStageModel stage) {
      final List<String> displayItems = <String>[];
      final List<String> options = <String>[];

      for (final CrmStageChecklistItemModel item in stage.checklistItems) {
        final String label = FormatHelper.localizedString(
          englishName: item.nameEn,
          arabicName: item.nameAr,
        );
        if (label.isNotEmpty) {
          if (!displayItems.contains(label)) displayItems.add(label);
          if (!options.contains(label)) options.add(label);
        }
      }

      // If no items are configured in Controls, provide standard 10 Required items
      if (displayItems.isEmpty) {
        displayItems.addAll(List<String>.filled(10, 'Required'));
      }
      if (options.isEmpty) {
        options.addAll(<String>[
          'Client Needs Assessment',
          'Budget Confirmation',
          'Technical Proposal Sent',
          'Stakeholder Approval',
          'Contract Draft Review',
          'Final Signature',
        ]);
      }

      return _StageConfig(
        stageId: stage.id,
        titleEn: stage.nameEn.startsWith('Stage')
            ? stage.nameEn
            : 'Stage ${stage.nameEn}',
        titleAr: stage.nameAr.startsWith('مرحلة')
            ? stage.nameAr
            : 'مرحلة ${stage.nameAr}',
        defaultDisplayItems: displayItems,
        dropdownOptions: options,
      );
    }).toList();
  }

  List<_StageConfig> _defaultConfigs() {
    return <_StageConfig>[
      _StageConfig(
        stageId: 'new',
        titleEn: 'Stage New',
        titleAr: 'مرحلة جديدة',
        defaultDisplayItems: List<String>.filled(10, 'Required'),
        dropdownOptions: <String>[
          'Client Needs Assessment',
          'Initial Contact Made',
          'Requirements Gathered',
        ],
      ),
      _StageConfig(
        stageId: 'discovery',
        titleEn: 'Stage Discovery',
        titleAr: 'مرحلة استكشاف',
        defaultDisplayItems: List<String>.filled(10, 'Required'),
        dropdownOptions: <String>[
          'Budget Confirmation',
          'Technical Scope Defined',
          'Decision Maker Identified',
        ],
      ),
      _StageConfig(
        stageId: 'qualified',
        titleEn: 'Stage Qualified',
        titleAr: 'مرحلة مؤهلة',
        defaultDisplayItems: List<String>.filled(10, 'Required'),
        dropdownOptions: <String>[
          'Technical Proposal Sent',
          'Commercial Offer Prepared',
          'Demo Completed',
        ],
      ),
      _StageConfig(
        stageId: 'proposal',
        titleEn: 'Stage Proposal',
        titleAr: 'مرحلة العرض',
        defaultDisplayItems: List<String>.filled(10, 'Required'),
        dropdownOptions: <String>[
          'Stakeholder Approval',
          'Contract Draft Review',
          'Final Signature',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Section 1: Settings Card (Edit Mode Switch) ──────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Settings',
            arabicName: 'الإعدادات',
          ),
          showHideToggle: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                FormatHelper.localizedString(
                  englishName: 'Edit Mode',
                  arabicName: 'وضع التعديل',
                ),
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              DefaultSwitchButton(
                value: _editMode,
                onChanged: (bool val) {
                  setState(() => _editMode = val);
                  widget.onEditModeChanged?.call(val);
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 24.sp),

        // ── Section 2: Stage Cards ───────────────────────────────────────────
        for (int i = 0; i < _configs.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 24.sp),
          _buildStageCard(context, _configs[i]),
        ],
      ],
    );
  }

  Widget _buildStageCard(BuildContext context, _StageConfig config) {
    final String title = FormatHelper.localizedString(
      englishName: config.titleEn,
      arabicName: config.titleAr,
    );

    return CrmSectionCard(
      title: title,
      showHideToggle: true,
      child: _editMode
          ? _buildEditModeContent(context, config)
          : _buildViewModeContent(context, config),
    );
  }

  /// View Mode: 5-column bulleted checklist grid matching Screenshot 1
  Widget _buildViewModeContent(BuildContext context, _StageConfig config) {
    final List<String> items = config.defaultDisplayItems;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 800
            ? 5
            : (constraints.maxWidth > 500 ? 3 : 2);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 28.sp,
            crossAxisSpacing: 8.sp,
            mainAxisSpacing: 8.sp,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 4.sp,
                  height: 4.sp,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    shape: BoxShape.rectangle,
                  ),
                ),
                SizedBox(width: 8.sp),
                Flexible(
                  child: Text(
                    items[index],
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.text,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Edit Mode: Half-width requirement dropdown and + Required button matching Screenshot 2
  Widget _buildEditModeContent(BuildContext context, _StageConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0;
            i < config.selectedRequirements.length;
            i++) ...<Widget>[
          if (i > 0) SizedBox(height: 12.sp),
          buildResponsiveFields(
            context: context,
            left: CustomDropdown<String>(
              label: FormatHelper.localizedString(
                englishName: 'Required',
                arabicName: 'مطلوب',
              ),
              hint: FormatHelper.localizedString(
                englishName: 'Choose',
                arabicName: 'اختر',
              ),
              value: config.selectedRequirements[i],
              items: config.dropdownOptions
                  .map((String opt) =>
                      DropdownItem<String>(value: opt, label: opt))
                  .toList(),
              fillColor: AppColors.background,
              onChanged: (String? val) {
                setState(() => config.selectedRequirements[i] = val);
              },
            ),
            right: const SizedBox.shrink(),
          ),
        ],

        SizedBox(height: 16.sp),

        // + Required Button (black button with white text)
        InkWell(
          onTapDown: (_) => HapticController.medium(),
          onTap: () {
            setState(() {
              config.selectedRequirements.add(null);
            });
          },
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 10.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 6.sp),
                Text(
                  FormatHelper.localizedString(
                    englishName: 'Required',
                    arabicName: 'مطلوب',
                  ),
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
