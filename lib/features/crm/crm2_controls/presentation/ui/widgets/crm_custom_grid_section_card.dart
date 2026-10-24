// ****************** FILE INFO ******************
// File Name: crm_custom_grid_section_card.dart
// Purpose: Renders a titled card of field switch rows for Custom Grid
// Author: Mohand Adel
// Created At: 10/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/default_switch_button.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_custom_grid_draft_state.dart';

class CrmCustomGridSectionCard extends StatelessWidget {
  final CrmCustomGridFieldGroup group;
  final bool isReadOnly;
  final bool Function(String fieldId) isFieldSelected;
  final void Function(String fieldId, bool enabled)? onToggle;

  const CrmCustomGridSectionCard({
    super.key,
    required this.group,
    required this.isReadOnly,
    required this.isFieldSelected,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (group.fields.isEmpty) {
      return const SizedBox.shrink();
    }

    final String localizedTitle = FormatHelper.localizedString(
      englishName: group.titleEn,
      arabicName: group.titleAr,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedTitle,
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Column(
            children: group.fields
                .map((CrmTemplateFieldModel field) => _buildRow(field))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Function Name: _buildRow
  ///
  /// Purpose: Builds a single field name and switch row
  ///
  /// Parameters:
  /// - field: The template field model
  ///
  /// Returns: Widget
  Widget _buildRow(CrmTemplateFieldModel field) {
    final bool selected = isFieldSelected(field.id);
    final String label = FormatHelper.localizedString(
      englishName: field.nameEn,
      arabicName: field.nameAr,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
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
          if (isReadOnly)
            IgnorePointer(
              child: DefaultSwitchButton(
                value: selected,
                onChanged: (_) {},
              ),
            )
          else
            DefaultSwitchButton(
              value: selected,
              onChanged: (bool val) => onToggle?.call(field.id, val),
            ),
        ],
      ),
    );
  }
}
