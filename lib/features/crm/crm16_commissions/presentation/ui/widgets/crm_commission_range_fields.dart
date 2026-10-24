// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_range_fields.dart
// Purpose: Reusable editable range fields for commission package sections
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';

class CrmCommissionRangeFields extends StatelessWidget {
  final List<CrmCommissionTierRange> ranges;
  final bool readOnly;
  final String keyPrefix;
  final AlignmentGeometry addButtonAlignment;
  final VoidCallback onAddRange;
  final ValueChanged<int> onRemoveRange;
  final void Function(int index, String value) onFromChanged;
  final void Function(int index, String value) onToChanged;
  final void Function(int index, String value) onValueChanged;

  const CrmCommissionRangeFields({
    super.key,
    required this.ranges,
    required this.readOnly,
    required this.keyPrefix,
    required this.addButtonAlignment,
    required this.onAddRange,
    required this.onRemoveRange,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          ...List<Widget>.generate(ranges.length, (int index) {
            final CrmCommissionTierRange range = ranges[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.sp),
              child: Row(
                children: <Widget>[
                  _rangeField(
                    key: '$keyPrefix-from-$index',
                    label: 'From',
                    value: range.from,
                    onChanged: (String value) => onFromChanged(index, value),
                  ),
                  SizedBox(width: 12.sp),
                  _rangeField(
                    key: '$keyPrefix-to-$index',
                    label: 'To',
                    value: range.to,
                    onChanged: (String value) => onToChanged(index, value),
                  ),
                  SizedBox(width: 12.sp),
                  _rangeField(
                    key: '$keyPrefix-value-$index',
                    label: 'Commission Value',
                    value: range.value,
                    onChanged: (String value) => onValueChanged(index, value),
                  ),
                  if (!readOnly && ranges.length > 1) ...<Widget>[
                    SizedBox(width: 8.sp),
                    customButtonWithSvg(
                      title: '',
                      function: () => onRemoveRange(index),
                      color: AppColors.red,
                      colorBorder: AppColors.transparent,
                      image: AppAssets.minusCircle,
                      svgColor: AppColors.white,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      textStyle: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.white),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (!readOnly)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: customButtonWithSvg(
                title: 'Range',
                function: onAddRange,
                color: AppColors.blackButton,
                colorBorder: AppColors.transparent,
                image: AppAssets.crmPlusBold,
                svgColor: AppTheme.readableOn(AppColors.blackButton),
                widthImage: 14.sp,
                heightImage: 14.sp,
                textStyle: StyleText.fontSize12Weight400.copyWith(
                    color: AppTheme.readableOn(AppColors.blackButton)),
              ),
            ),
        ],
      );

  Widget _rangeField({
    required String key,
    required String label,
    required double value,
    required ValueChanged<String> onChanged,
  }) =>
      Expanded(
        child: CustomTextField(
          key: ValueKey<String>(key),
          initialValue: value == 0 ? '' : value.toString(),
          label: label,
          hint: 'Text Here',
          enabled: !readOnly,
          fillColor: AppColors.background,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
        ),
      );
}
