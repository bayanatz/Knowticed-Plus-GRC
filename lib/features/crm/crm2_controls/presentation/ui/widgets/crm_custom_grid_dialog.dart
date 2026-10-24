// ****************** FILE INFO ******************
// File Name: crm_custom_grid_dialog.dart
// Purpose: Modal dialog for selecting up to 4 custom grid fields on large screens
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmCustomGridDialog extends StatefulWidget {
  final List<CrmTemplateSectionModel> sections;
  final List<CrmTemplateFieldModel> fields;
  final List<String> initialSelectedFieldIds;
  final Future<bool> Function(List<String> selectedFieldIds) onSave;

  const CrmCustomGridDialog({
    super.key,
    required this.sections,
    required this.fields,
    required this.initialSelectedFieldIds,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CrmTemplateSectionModel> sections,
    required List<CrmTemplateFieldModel> fields,
    required List<String> initialSelectedFieldIds,
    required Future<bool> Function(List<String> selectedFieldIds) onSave,
  }) {
    return showAppDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CrmCustomGridDialog(
        sections: sections,
        fields: fields,
        initialSelectedFieldIds: initialSelectedFieldIds,
        onSave: onSave,
      ),
    );
  }

  @override
  State<CrmCustomGridDialog> createState() => _CrmCustomGridDialogState();
}

class _CrmCustomGridDialogState extends State<CrmCustomGridDialog> {
  late final Set<String> _selectedFieldIds;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedFieldIds = Set<String>.from(widget.initialSelectedFieldIds);
  }

  void _toggleField(String fieldId, bool enabled) {
    if (enabled) {
      if (_selectedFieldIds.length >= 4) {
        CrmControlDialogs.showErrorDialog(
          context: context,
          title: S.current.crmCustomGridLimitReached,
          subtitle: S.current.crmMax4FieldsCanBeSelected,
        );
        return;
      }
      setState(() => _selectedFieldIds.add(fieldId));
    } else {
      setState(() => _selectedFieldIds.remove(fieldId));
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final bool success = await widget.onSave(_selectedFieldIds.toList());
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmTemplateFieldModel> standaloneFields = widget.fields
        .where((f) =>
            !f.isDeleted && (f.sectionId == null || f.sectionId!.isEmpty))
        .toList();

    return Dialog(
      backgroundColor: AppColors.card,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 24.sp),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720.sp,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 16.sp),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (standaloneFields.isNotEmpty) ...[
                        _buildSectionBlock(
                          title: S.current.crmCategoryFields,
                          fields: standaloneFields,
                        ),
                        SizedBox(height: 16.sp),
                      ],
                      for (final CrmTemplateSectionModel section
                          in widget.sections.where((s) => !s.isDeleted)) ...[
                        _buildSectionBlock(
                          title: FormatHelper.localizedString(
                            englishName: section.nameEn,
                            arabicName: section.nameAr,
                          ),
                          fields: widget.fields
                              .where((f) =>
                                  !f.isDeleted && f.sectionId == section.id)
                              .toList(),
                        ),
                        SizedBox(height: 16.sp),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 34.sp,
          height: 34.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: AppAssets.grid,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.textButton,
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        Text(
          S.current.crmCustomGrid,
          style: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.black,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 16.sp,
                color: AppColors.textButton,
              ),
              SizedBox(width: 6.sp),
              Text(
                S.current.crmMax4FieldsCanBeSelected,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBlock({
    required String title,
    required List<CrmTemplateFieldModel> fields,
  }) {
    if (fields.isEmpty) return const SizedBox.shrink();

    final int half = (fields.length / 2).ceil();
    final List<CrmTemplateFieldModel> leftCol = fields.sublist(0, half);
    final List<CrmTemplateFieldModel> rightCol =
        fields.length > half ? fields.sublist(half) : <CrmTemplateFieldModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: leftCol
                      .map((field) => _buildFieldToggleRow(field))
                      .toList(),
                ),
              ),
              SizedBox(width: 24.sp),
              Expanded(
                child: Column(
                  children: rightCol
                      .map((field) => _buildFieldToggleRow(field))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldToggleRow(CrmTemplateFieldModel field) {
    final bool isSelected = _selectedFieldIds.contains(field.id);
    final String label = FormatHelper.localizedString(
      englishName: field.nameEn,
      arabicName: field.nameAr,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.sp),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.sp),
          DefaultSwitchButton(
            value: isSelected,
            onChanged: (val) => _toggleField(field.id, val),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 140.sp,
          height: 40.sp,
          child: customButton(
            title: S.current.crmDiscard,
            color: AppColors.disabledGrey,
            textStyle: StyleText.fontSize14Weight600.copyWith(
              color: AppColors.blackButton,
            ),
            function: () => Navigator.pop(context),
          ),
        ),
        SizedBox(
          width: 140.sp,
          height: 40.sp,
          child: customButton(
            title: S.current.submit,
            color: AppColors.primary,
            textStyle: StyleText.fontSize14Weight600.copyWith(
              color: AppColors.blackButton,
            ),
            function: _handleSubmit,
          ),
        ),
      ],
    );
  }
}
