// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_value_rows.dart
// Purpose: Reusable commission value rows for product and service packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';

class CrmCommissionValueRows extends StatelessWidget {
  final List<CrmProductCommission> commissions;
  final String itemLabel;
  final String Function(CrmProductCommission item) categoryNameOf;
  final String Function(CrmProductCommission item) itemNameOf;
  final void Function(int index, String value) onValueChanged;
  final bool readOnly;

  const CrmCommissionValueRows({
    super.key,
    required this.commissions,
    required this.itemLabel,
    required this.categoryNameOf,
    required this.itemNameOf,
    required this.onValueChanged,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: List<Widget>.generate(commissions.length, (int index) {
          final CrmProductCommission item = commissions[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == commissions.length - 1 ? 0 : 12.sp,
            ),
            child: buildResponsiveFields(
              context: context,
              left: CustomTextField(
                initialValue: categoryNameOf(item),
                label: 'Category',
                readOnly: true,
                fillColor: AppColors.background,
              ),
              right: buildResponsiveFields(
                context: context,
                left: CustomTextField(
                  initialValue: itemNameOf(item),
                  label: itemLabel,
                  readOnly: true,
                  fillColor: AppColors.background,
                ),
                right: CustomTextField(
                  key: ValueKey<String>(
                      '$itemLabel-commission-${item.productId}'),
                  initialValue: item.value == 0 ? '' : item.value.toString(),
                  label: 'Commission Value',
                  hint: 'Text Here',
                  enabled: !readOnly,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  fillColor: AppColors.background,
                  onChanged: (String value) => onValueChanged(index, value),
                ),
              ),
            ),
          );
        }),
      );
}
