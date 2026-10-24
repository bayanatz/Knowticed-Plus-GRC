// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_license_domain_fields.dart
// Purpose: License-specific domain and target fields for commission packages
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/presentation/controller/crm_commission_form_state.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';

class CrmLicenseDomainFields extends StatelessWidget {
  final CrmCommissionFormState state;
  final CrmCommissionDomain domain;
  final int index;
  final bool readOnly;
  final ValueChanged<String> onApplyOnChanged;
  final ValueChanged<List<String>> onCategoriesChanged;
  final ValueChanged<List<String>> onLicensesChanged;
  final ValueChanged<String> onBillingCycleChanged;
  final ValueChanged<String> onTargetTypeChanged;
  final ValueChanged<String> onTargetFrequencyChanged;
  final ValueChanged<String> onTargetValueChanged;
  final ValueChanged<String> onCurrencyChanged;

  const CrmLicenseDomainFields({
    super.key,
    required this.state,
    required this.domain,
    required this.index,
    required this.readOnly,
    required this.onApplyOnChanged,
    required this.onCategoriesChanged,
    required this.onLicensesChanged,
    required this.onBillingCycleChanged,
    required this.onTargetTypeChanged,
    required this.onTargetFrequencyChanged,
    required this.onTargetValueChanged,
    required this.onCurrencyChanged,
  });

  bool get _isTiers => state.compensationType == 'Tiers';

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          buildResponsiveFields(
            context: context,
            left: CustomDropdown<String>(
              label: 'Apply on',
              hint: 'Choose',
              value: domain.applyOn,
              enabled: !readOnly,
              fillColor: AppColors.background,
              items: const <DropdownItem<String>>[
                DropdownItem<String>(value: 'Products', label: 'Products'),
                DropdownItem<String>(value: 'Services', label: 'Services'),
                DropdownItem<String>(value: 'License', label: 'License'),
              ],
              onChanged: onApplyOnChanged,
            ),
            right: CustomMultiSelectFilter<String>(
              label: 'Category',
              hint: 'Choose',
              values: domain.categoryIds,
              enabled: !readOnly,
              fillColor: AppColors.background,
              items: state.categories
                  .map((CrmProductCategoryModel item) =>
                      MultiSelectDropdownItem<String>(
                          value: item.id, label: item.nameEn))
                  .toList(),
              onChanged: onCategoriesChanged,
            ),
          ),
          SizedBox(height: 14.sp),
          buildResponsiveFields(
            context: context,
            left: CustomMultiSelectFilter<String>(
              label: 'Licenses',
              hint: 'Choose',
              values: domain.productIds,
              enabled: !readOnly,
              fillColor: AppColors.background,
              items: _licenses
                  .map((CrmProductItemModel item) =>
                      MultiSelectDropdownItem<String>(
                          value: item.id, label: item.nameEn))
                  .toList(),
              onChanged: onLicensesChanged,
            ),
            right: _billingCycleDropdown(),
          ),
          if (!_isTiers) ...<Widget>[
            SizedBox(height: 14.sp),
            buildResponsiveFields(
              context: context,
              left: _targetTypeDropdown(),
              right: _targetFrequencyDropdown(),
            ),
            SizedBox(height: 14.sp),
            buildResponsiveFields(
              context: context,
              left: CustomTextField(
                key: ValueKey<String>('license-target-$index'),
                initialValue: domain.targetValue == 0
                    ? ''
                    : domain.targetValue.toString(),
                label: domain.targetType == 'Count'
                    ? 'Count of Licenses'
                    : 'Target Amount',
                hint: 'Text Here',
                enabled: !readOnly,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                fillColor: AppColors.background,
                onChanged: onTargetValueChanged,
              ),
              right: _currencyDropdown(),
            ),
          ],
        ],
      );

  List<CrmProductItemModel> get _licenses => domain.categoryIds.isEmpty
      ? state.products
      : state.products
          .where((CrmProductItemModel item) =>
              domain.categoryIds.contains(item.categoryId))
          .toList();

  Widget _billingCycleDropdown() => CustomDropdown<String>(
        label: 'Billing Cycle',
        hint: 'Choose',
        value: domain.billingCycle.isEmpty ? null : domain.billingCycle,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Monthly', label: 'Monthly'),
          DropdownItem<String>(value: 'Quarterly', label: 'Quarterly'),
          DropdownItem<String>(value: 'Annually', label: 'Annually'),
          DropdownItem<String>(value: 'Weekly', label: 'Weekly'),
        ],
        onChanged: onBillingCycleChanged,
      );

  Widget _targetTypeDropdown() => CustomDropdown<String>(
        label: 'Target Type',
        hint: 'Choose',
        value: domain.targetType,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Count', label: 'Count'),
          DropdownItem<String>(value: 'Amount', label: 'Amount'),
        ],
        onChanged: onTargetTypeChanged,
      );

  Widget _targetFrequencyDropdown() => CustomDropdown<String>(
        label: 'Target Frequency',
        hint: 'Choose',
        value: domain.frequency,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'Monthly', label: 'Monthly'),
          DropdownItem<String>(value: 'Quarterly', label: 'Quarterly'),
          DropdownItem<String>(value: 'Annually', label: 'Annually'),
          DropdownItem<String>(value: 'Weekly', label: 'Weekly'),
        ],
        onChanged: onTargetFrequencyChanged,
      );

  Widget _currencyDropdown() => CustomDropdown<String>(
        label: 'Currency',
        hint: 'Choose',
        value: domain.currency.isEmpty ? null : domain.currency,
        enabled: !readOnly,
        fillColor: AppColors.background,
        items: const <DropdownItem<String>>[
          DropdownItem<String>(value: 'EGP', label: 'EGP'),
          DropdownItem<String>(value: 'QAR', label: 'QAR'),
          DropdownItem<String>(value: 'SAR', label: 'SAR'),
          DropdownItem<String>(value: 'USD', label: 'USD'),
        ],
        onChanged: onCurrencyChanged,
      );
}
